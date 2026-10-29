mod commands;
mod explorer;
mod hook;
mod plugins;
mod preview;
pub mod updater;

use tauri::{
    menu::{Menu, MenuItem, PredefinedMenuItem},
    tray::{TrayIconBuilder, TrayIconEvent},
    Emitter, Manager,
};

pub fn log_debug(msg: &str) {
    use std::io::Write;
    let log_path = if let Ok(exe) = std::env::current_exe() {
        if let Some(parent) = exe.parent() {
            parent.join("peekit_debug.log")
        } else {
            std::path::PathBuf::from("peekit_debug.log")
        }
    } else {
        std::path::PathBuf::from("peekit_debug.log")
    };
    if let Ok(mut f) = std::fs::OpenOptions::new().create(true).append(true).open(&log_path) {
        let now = chrono::Local::now().format("%H:%M:%S%.3f");
        let _ = writeln!(f, "[{}] {}", now, msg);
    }
    let dev_log = std::path::Path::new("d:\\Projects\\active\\PeekIt\\output\\peekit_debug.log");
    if dev_log.parent().map(|p| p.exists()).unwrap_or(false) && dev_log != log_path {
        if let Ok(mut f) = std::fs::OpenOptions::new().create(true).append(true).open(dev_log) {
            let now = chrono::Local::now().format("%H:%M:%S%.3f");
            let _ = writeln!(f, "[{}] {}", now, msg);
        }
    }
}

fn read_config_language() -> String {
    crate::commands::get_app_config()
        .ok()
        .and_then(|c| c.get("language").and_then(|v| v.as_str()).map(|s| s.to_string()))
        .unwrap_or_else(|| "ru".to_string())
}

fn tray_labels(lang: &str) -> (String, String, String, String) {
    match lang {
        "en" => ("Plugin Store".into(), "Settings".into(), "About".into(), "Quit".into()),
        "zh" => ("插件商店".into(), "设置".into(), "关于".into(), "退出".into()),
        _ => ("Магазин плагинов (Store)".into(), "Параметры (Settings)".into(), "О программе (About)".into(), "Выход (Quit)".into()),
    }
}

/// Builds the tray menu with localized labels.
fn build_tray_menu(app: &tauri::AppHandle) -> tauri::Result<tauri::menu::Menu<tauri::Wry>> {
    let lang = read_config_language();
    let (label_store, label_settings, label_about, label_quit) = tray_labels(&lang);
    let title_str = format!("Peekit v{}", env!("CARGO_PKG_VERSION"));
    let title_i = MenuItem::with_id(app, "title", &title_str, false, None::<&str>)?;
    let sep1 = PredefinedMenuItem::separator(app)?;
    let marketplace_i = MenuItem::with_id(app, "marketplace", &label_store, true, None::<&str>)?;
    let settings_i = MenuItem::with_id(app, "settings", &label_settings, true, None::<&str>)?;
    let about_i = MenuItem::with_id(app, "about", &label_about, true, None::<&str>)?;
    let sep2 = PredefinedMenuItem::separator(app)?;
    let quit_i = MenuItem::with_id(app, "quit", &label_quit, true, None::<&str>)?;
    Menu::with_items(app, &[&title_i, &sep1, &marketplace_i, &settings_i, &about_i, &sep2, &quit_i])
}

/// Re-applies the tray menu labels after the user changes the UI language
/// (called from save_app_config; no restart needed anymore).
pub fn apply_tray_language(app: &tauri::AppHandle) {
    if let Some(tray) = app.tray_by_id("peekit-tray") {
        match build_tray_menu(app) {
            Ok(menu) => {
                let _ = tray.set_menu(Some(menu));
                crate::log_debug("Tray menu language updated");
            }
            Err(e) => crate::log_debug(&format!("apply_tray_language failed: {:?}", e)),
        }
    }
}

pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_autostart::init(
            tauri_plugin_autostart::MacosLauncher::LaunchAgent,
            Some(vec![]),
        ))
        .register_uri_scheme_protocol("plugin-asset", |_app, request| {
            plugins::protocol::handle_plugin_asset_request(&request)
        })
        .invoke_handler(tauri::generate_handler![
            commands::get_file_info,
            commands::read_text_content,
            commands::open_with_default_app,
            commands::reveal_in_explorer,
            commands::toggle_pin_window,
            commands::hide_preview_window,
            commands::get_app_config,
            commands::save_app_config,
            commands::navigate_adjacent_file,
            commands::log_frontend,
            commands::get_installed_plugins,
            commands::open_plugins_folder,
            commands::read_binary_for_plugin,
            commands::set_plugin_enabled,
            commands::install_plugin,
            commands::install_plugin_bytes,
            commands::uninstall_plugin,
            commands::read_folder_entries,
            commands::check_for_updates,
            commands::save_file_dialog_for_plugin,
            commands::start_drag_window,
            commands::toggle_maximize_window,
            commands::is_window_maximized,
        ])
        .setup(move |app| {
            crate::log_debug("setup starting");

            // Check command line arguments for .pkit files (double-click from Windows Explorer)
            for arg in std::env::args().skip(1) {
                if arg.to_lowercase().ends_with(".pkit") {
                    let p = std::path::PathBuf::from(&arg);
                    if p.exists() {
                        crate::log_debug(&format!("Found .pkit argument on startup: {:?}", p));
                        match crate::plugins::scanner::install_plugin_package(&p) {
                            Ok(info) => {
                                crate::log_debug(&format!("[PKit] Successfully installed plugin '{}'", info.manifest.name));
                            }
                            Err(e) => {
                                crate::log_debug(&format!("[PKit] Failed to install package: {}", e));
                            }
                        }
                    }
                }
            }

            let icon = if let Some(icon) = app.default_window_icon().cloned() {
                icon
            } else {
                let img = image::load_from_memory(include_bytes!("../icons/32x32.png")).unwrap().to_rgba8();
                tauri::image::Image::new_owned(img.into_raw(), 32, 32)
            };

            // Setup System Tray
            let menu = build_tray_menu(app.handle())?;

            let open_dialog_tab = |app: &tauri::AppHandle, payload: serde_json::Value| {
                if let Some(window) = app.get_webview_window("main") {
                    let _ = window.emit("open_settings", payload.clone());
                    let _ = app.emit("open_settings", payload);
                    let _ = window.unminimize();
                    let _ = window.show();
                    let _ = window.set_focus();
                }
            };

            let tray = TrayIconBuilder::with_id("peekit-tray")
                .icon(icon)
                .menu(&menu)
                .show_menu_on_left_click(false)
                .on_menu_event(move |app, event| {
                    crate::log_debug(&format!("Tray menu event: {:?}", event.id()));
                    match event.id().as_ref() {
                        "settings" => {
                            crate::log_debug("Settings menu clicked");
                            open_dialog_tab(app, serde_json::json!({ "tab": "general" }));
                        }
                        "marketplace" => {
                            crate::log_debug("Marketplace menu clicked");
                            open_dialog_tab(app, serde_json::json!({ "tab": "plugins", "subtab": "store" }));
                        }
                        "about" => {
                            crate::log_debug("About menu clicked");
                            open_dialog_tab(app, serde_json::json!({ "tab": "about" }));
                        }
                        "quit" => {
                            crate::log_debug("Quit clicked -> exiting process");
                            std::process::exit(0);
                        }
                        _ => {}
                    }
                })
                .on_tray_icon_event(|tray, event| {
                    if let TrayIconEvent::Click { button: tauri::tray::MouseButton::Left, .. } = event {
                        crate::log_debug("Tray left-clicked");
                        let app = tray.app_handle();
                        if let Some(window) = app.get_webview_window("main") {
                            let _ = window.emit("open_settings", serde_json::json!({ "tab": "general" }));
                            let _ = app.emit("open_settings", serde_json::json!({ "tab": "general" }));
                            let _ = window.unminimize();
                            let _ = window.show();
                            let _ = window.set_focus();
                        }
                    }
                })
                .build(app)?;

            crate::log_debug(&format!("Tray created: id={:?}", tray.id()));

            // Start global Spacebar hook on main thread
            hook::start_hook(app.handle().clone());

            // Start background updater thread
            updater::start_background_updater(app.handle().clone());

            crate::log_debug("setup completed successfully");
            Ok(())
        })
        .build(tauri::generate_context!())
        .expect("error while building Peekit application")
        .run(|_app_handle, event| match event {
            tauri::RunEvent::ExitRequested { api, .. } => {
                crate::log_debug("ExitRequested -> preventing exit");
                api.prevent_exit();
            }
            tauri::RunEvent::WindowEvent { label, event, .. } => {
                if let tauri::WindowEvent::CloseRequested { api, .. } = event {
                    crate::log_debug(&format!("CloseRequested on window {} -> preventing close", label));
                    api.prevent_close();
                }
            }
            _ => {}
        });
}
