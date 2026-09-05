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

#[tauri::command]
pub fn get_app_config() -> Result<serde_json::Value, String> {
    let proj_dirs = directories::ProjectDirs::from("com", "peekit", "Peekit")
        .ok_or("Could not determine config path")?;
    let config_path = proj_dirs.config_dir().join("config.json");

    if config_path.exists() {
        let content = std::fs::read_to_string(config_path).map_err(|e| e.to_string())?;
        serde_json::from_str(&content).map_err(|e| e.to_string())
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
    let proj_dirs = directories::ProjectDirs::from("com", "peekit", "Peekit")
        .ok_or("Could not determine config path")?;
    let config_dir = proj_dirs.config_dir();
    std::fs::create_dir_all(config_dir).map_err(|e| e.to_string())?;
    let config_path = config_dir.join("config.json");

    let formatted = serde_json::to_string_pretty(&config).map_err(|e| e.to_string())?;
    std::fs::write(config_path, formatted).map_err(|e| e.to_string())?;
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
