mod commands;
mod explorer;
mod hook;
mod plugins;
mod preview;

use tauri::{
    menu::{Menu, MenuItem},
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

pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
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
        ])
        .setup(|app| {
            crate::log_debug("setup starting");

            let icon = if let Some(icon) = app.default_window_icon().cloned() {
                icon
            } else {
                let img = image::load_from_memory(include_bytes!("../icons/32x32.png")).unwrap().to_rgba8();
                tauri::image::Image::new_owned(img.into_raw(), 32, 32)
            };

            // Setup System Tray
            let quit_i = MenuItem::with_id(app, "quit", "Выход (Quit)", true, None::<&str>)?;
            let settings_i = MenuItem::with_id(app, "settings", "Параметры (Settings)", true, None::<&str>)?;
            let menu = Menu::with_items(app, &[&settings_i, &quit_i])?;

            let tray = TrayIconBuilder::with_id("main_tray")
                .icon(icon)
                .menu(&menu)
                .tooltip("Peekit - Мгновенный просмотр по Пробелу")
                .on_menu_event(|app, event| match event.id.as_ref() {
                    "quit" => {
                        crate::log_debug("Quit menu clicked");
                        std::process::exit(0);
                    }
                    "settings" => {
                        crate::log_debug("Settings menu clicked");
                        if let Some(window) = app.get_webview_window("main") {
                            let _ = window.emit("open_settings", ());
                            let _ = app.emit("open_settings", ());
                            let _ = window.unminimize();
                            let _ = window.show();
                            let _ = window.set_focus();
                            #[cfg(windows)]
                            if let Ok(hwnd) = window.hwnd() {
                                unsafe {
                                    let _ = windows::Win32::UI::WindowsAndMessaging::SetForegroundWindow(windows::Win32::Foundation::HWND(hwnd.0));
                                }
                            }
                        }
                    }
                    _ => {}
                })
                .on_tray_icon_event(|tray, event| {
                    if let TrayIconEvent::Click { button, .. } = event {
                        if button == tauri::tray::MouseButton::Left {
                            let app = tray.app_handle();
                            if let Some(window) = app.get_webview_window("main") {
                                if window.is_visible().unwrap_or(false) {
                                    let _ = window.hide();
                                } else {
                                    let _ = window.show();
                                    let _ = window.set_focus();
                                    #[cfg(windows)]
                                    if let Ok(hwnd) = window.hwnd() {
                                        unsafe {
                                            let _ = windows::Win32::UI::WindowsAndMessaging::SetForegroundWindow(windows::Win32::Foundation::HWND(hwnd.0));
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
                .build(app)?;

            crate::log_debug(&format!("Tray created: id={:?}", tray.id()));

            // Start global Spacebar hook on main thread
            hook::start_hook(app.handle().clone());

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
