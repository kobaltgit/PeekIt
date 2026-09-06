use std::process::Command;
use tauri::{AppHandle, Emitter, Manager};
use crate::preview::{inspect_file, read_file_text_capped, FilePreviewInfo};

#[tauri::command]
pub fn get_file_info(path: String) -> Result<FilePreviewInfo, String> {
    inspect_file(&path)
}

#[tauri::command]
pub fn read_text_content(path: String) -> Result<String, String> {
    // Read up to 2MB for instant responsive preview
    read_file_text_capped(&path, 2 * 1024 * 1024)
}

#[tauri::command]
pub fn log_frontend(msg: String) {
    crate::log_debug(&format!("[Frontend] {}", msg));
}

#[tauri::command]
pub fn open_with_default_app(path: String) -> Result<(), String> {
    #[cfg(windows)]
    {
        Command::new("explorer")
            .arg(&path)
            .spawn()
            .map_err(|e| e.to_string())?;
    }
    Ok(())
}

#[tauri::command]
pub fn reveal_in_explorer(path: String) -> Result<(), String> {
    #[cfg(windows)]
    {
        Command::new("explorer")
            .arg("/select,")
            .arg(&path)
            .spawn()
            .map_err(|e| e.to_string())?;
    }
    Ok(())
}

#[tauri::command]
pub fn toggle_pin_window(app: AppHandle, pin: bool) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("main") {
        window.set_always_on_top(pin).map_err(|e| e.to_string())?;
    }
    Ok(())
}

#[tauri::command]
pub fn hide_preview_window(app: AppHandle) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("main") {
        crate::hook::hide_and_reset(&app, &window);
    }
    Ok(())
}

fn get_config_path() -> Result<std::path::PathBuf, String> {
    if let Ok(exe) = std::env::current_exe() {
        if let Some(exe_dir) = exe.parent() {
            if exe_dir.join("portable.txt").exists() {
                return Ok(exe_dir.join("config.json"));
            }
        }
    }
    let proj_dirs = directories::ProjectDirs::from("com", "peekit", "Peekit")
        .ok_or("Could not determine config path")?;
    let config_dir = proj_dirs.config_dir();
    let _ = std::fs::create_dir_all(config_dir);
    Ok(config_dir.join("config.json"))
}

#[tauri::command]
pub fn get_app_config() -> Result<serde_json::Value, String> {
    let config_path = get_config_path()?;

    if config_path.exists() {
        let content = std::fs::read_to_string(&config_path).map_err(|e| e.to_string())?;
        let mut val: serde_json::Value = serde_json::from_str(&content).map_err(|e| e.to_string())?;
        let defaults = serde_json::json!({
            "language": "ru",
            "theme": "dark",
            "autostart": true,
            "closeOnFocusLoss": false,
            "autoplayMedia": true,
            "volume": 0.8,
            "stayOnTop": false
        });
        if let (Some(val_obj), Some(def_obj)) = (val.as_object_mut(), defaults.as_object()) {
            for (k, v) in def_obj {
                if !val_obj.contains_key(k) {
                    val_obj.insert(k.clone(), v.clone());
                }
            }
        }
        Ok(val)
    } else {
        Ok(serde_json::json!({
            "language": "ru",
            "theme": "dark",
            "autostart": true,
            "closeOnFocusLoss": false,
            "autoplayMedia": true,
            "volume": 0.8,
            "stayOnTop": false
        }))
    }
}

#[tauri::command]
pub fn save_app_config(config: serde_json::Value) -> Result<(), String> {
    let config_path = get_config_path()?;
    if let Some(parent) = config_path.parent() {
        let _ = std::fs::create_dir_all(parent);
    }

    let mut merged: serde_json::Value = if config_path.exists() {
        let content = std::fs::read_to_string(&config_path).unwrap_or_default();
        serde_json::from_str(&content).unwrap_or_else(|_| serde_json::json!({}))
    } else {
        serde_json::json!({})
    };

    if let (Some(dest), Some(src)) = (merged.as_object_mut(), config.as_object()) {
        for (k, v) in src {
            dest.insert(k.clone(), v.clone());
        }
    } else {
        merged = config;
    }

    let formatted = serde_json::to_string_pretty(&merged).map_err(|e| e.to_string())?;
    std::fs::write(&config_path, formatted).map_err(|e| e.to_string())?;
    crate::log_debug(&format!("Saved app config to {:?}", config_path));
    Ok(())
}

#[tauri::command]
pub fn navigate_adjacent_file(app: AppHandle, direction: String) -> Result<Option<String>, String> {
    #[cfg(windows)]
    {
        if let Some(new_path) = crate::explorer::navigate_adjacent_in_explorer(&direction) {
            crate::hook::set_current_preview_path(&new_path);
            let _ = app.emit("preview_file", &new_path);
            return Ok(Some(new_path));
        }
    }
    let _ = (app, direction);
    Ok(None)
}

#[tauri::command]
pub fn get_installed_plugins() -> Result<Vec<crate::plugins::manifest::PluginInfo>, String> {
    let disabled_ids: Vec<String> = match get_app_config() {
        Ok(val) => val
            .get("disabledPlugins")
            .and_then(|v| v.as_array())
            .map(|arr| {
                arr.iter()
                    .filter_map(|x| x.as_str().map(|s| s.to_string()))
                    .collect()
            })
            .unwrap_or_default(),
        Err(_) => Vec::new(),
    };

    Ok(crate::plugins::scanner::scan_plugins(&disabled_ids))
}

#[tauri::command]
pub fn open_plugins_folder() -> Result<(), String> {
    let plugins_dir = crate::plugins::scanner::ensure_plugins_dir()?;
    #[cfg(windows)]
    {
        Command::new("explorer")
            .arg(&plugins_dir)
            .spawn()
            .map_err(|e| e.to_string())?;
    }
    #[cfg(not(windows))]
    {
        let _ = plugins_dir;
    }
    Ok(())
}

#[tauri::command]
pub fn read_binary_for_plugin(path: String) -> Result<Vec<u8>, String> {
    let p = std::path::Path::new(&path);
    if !p.exists() {
        return Err(format!("File '{}' not found", path));
    }
    std::fs::read(p).map_err(|e| format!("Failed to read file: {}", e))
}

#[tauri::command]
pub fn set_plugin_enabled(id: String, enabled: bool) -> Result<(), String> {
    let mut config = get_app_config().unwrap_or_else(|_| serde_json::json!({}));
    let mut disabled: Vec<String> = config
        .get("disabledPlugins")
        .and_then(|v| v.as_array())
        .map(|arr| {
            arr.iter()
                .filter_map(|x| x.as_str().map(|s| s.to_string()))
                .collect()
        })
        .unwrap_or_default();

    if enabled {
        disabled.retain(|item| item != &id);
    } else if !disabled.contains(&id) {
        disabled.push(id);
    }

    if let Some(obj) = config.as_object_mut() {
        obj.insert("disabledPlugins".to_string(), serde_json::json!(disabled));
    }

    save_app_config(config)
}

#[tauri::command]
pub fn install_plugin(package_path: String) -> Result<crate::plugins::manifest::PluginInfo, String> {
    let p = std::path::Path::new(&package_path);
    crate::plugins::scanner::install_plugin_package(p)
}

#[tauri::command]
pub fn install_plugin_bytes(bytes: Vec<u8>) -> Result<crate::plugins::manifest::PluginInfo, String> {
    let temp_dir = std::env::temp_dir();
    let temp_path = temp_dir.join(format!(
        "peekit_install_{}.pkit",
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis()
    ));
    std::fs::write(&temp_path, &bytes).map_err(|e| format!("Failed to write temp package: {}", e))?;
    let res = crate::plugins::scanner::install_plugin_package(&temp_path);
    let _ = std::fs::remove_file(&temp_path);
    res
}


