use std::sync::atomic::{AtomicBool, Ordering};
use tauri::{AppHandle, Emitter, Manager};

#[cfg(windows)]
use windows::{
    Win32::Foundation::*,
    Win32::UI::Input::KeyboardAndMouse::*,
    Win32::UI::WindowsAndMessaging::*,
};

static IS_SPACE_DOWN: AtomicBool = AtomicBool::new(false);
static HOOK_ACTIVE: AtomicBool = AtomicBool::new(false);
static CURRENT_PREVIEW_PATH: parking_lot::Mutex<Option<String>> = parking_lot::Mutex::new(None);
#[cfg(windows)]
static LAST_EXPLORER_HWND: parking_lot::Mutex<Option<isize>> = parking_lot::Mutex::new(None);

#[cfg(windows)]
static mut APP_HANDLE_RAW: Option<AppHandle> = None;
#[cfg(windows)]
static mut HOOK_HANDLE: Option<HHOOK> = None;

#[allow(dead_code)]
pub fn reset_preview_path() {
    *CURRENT_PREVIEW_PATH.lock() = None;
}

pub fn get_last_explorer_hwnd() -> Option<isize> {
    #[cfg(windows)]
    {
        *LAST_EXPLORER_HWND.lock()
    }
    #[cfg(not(windows))]
    {
        None
    }
}

pub fn set_current_preview_path(path: &str) {
    *CURRENT_PREVIEW_PATH.lock() = Some(path.to_string());
}

pub fn hide_and_reset(app: &AppHandle, window: &tauri::WebviewWindow) {
    crate::log_debug("hide_and_reset called");
    IS_SPACE_DOWN.store(false, Ordering::SeqCst);
    *CURRENT_PREVIEW_PATH.lock() = None;
    let _ = app.emit("close_preview", ());
    let _ = window.emit("close_preview", ());
    let _ = window.hide();

    #[cfg(windows)]
    {
        if let Some(raw_hwnd) = *LAST_EXPLORER_HWND.lock() {
            let hwnd = HWND(raw_hwnd as *mut std::ffi::c_void);
            unsafe {
                if IsWindow(hwnd).as_bool() {
                    let _ = SetForegroundWindow(hwnd);
                    crate::log_debug(&format!("Restored foreground focus to Explorer HWND: {:?}", hwnd));
                }
            }
        }
    }
}

#[cfg(windows)]
pub fn start_hook(app: AppHandle) {
    if HOOK_ACTIVE.swap(true, Ordering::SeqCst) {
        return;
    }

    unsafe {
        APP_HANDLE_RAW = Some(app);

        let hmodule = windows::Win32::System::LibraryLoader::GetModuleHandleW(None).unwrap_or_default();
        let hinstance = HINSTANCE(hmodule.0);

        let hook_id = SetWindowsHookExW(
            WH_KEYBOARD_LL,
            Some(low_level_keyboard_proc),
            hinstance,
            0,
        );

        match hook_id {
            Ok(hook) => {
                crate::log_debug(&format!("start_hook (main thread): successfully installed hook_id={:?}", hook));
                HOOK_HANDLE = Some(hook);
            }
            Err(e) => {
                crate::log_debug(&format!("start_hook ERROR: {:?}", e));
            }
        }
    }
}

#[cfg(windows)]
unsafe extern "system" fn low_level_keyboard_proc(
    n_code: i32,
    w_param: WPARAM,
    l_param: LPARAM,
) -> LRESULT {
    if n_code >= 0 {
        let kbd_struct = *(l_param.0 as *const KBDLLHOOKSTRUCT);
        let vk_code = kbd_struct.vkCode as u16;

        let is_key_down = w_param.0 == WM_KEYDOWN as usize || w_param.0 == WM_SYSKEYDOWN as usize;
        let is_key_up = w_param.0 == WM_KEYUP as usize || w_param.0 == WM_SYSKEYUP as usize;

        if vk_code == VK_SPACE.0 {
            if is_key_up {
                crate::log_debug("Space key UP event intercepted!");
                IS_SPACE_DOWN.store(false, Ordering::SeqCst);
            } else if is_key_down {
                crate::log_debug("Space key DOWN event intercepted!");

                if let Some(ref app) = APP_HANDLE_RAW {
                    if let Some(window) = app.get_webview_window("main") {
                        let is_visible = window.is_visible().unwrap_or(false);

                        // If window is NOT visible, any previous IS_SPACE_DOWN state is stale!
                        if !is_visible {
                            IS_SPACE_DOWN.store(false, Ordering::SeqCst);
                        }

                        // Prevent auto-repeat spam
                        if IS_SPACE_DOWN.swap(true, Ordering::SeqCst) {
                            return CallNextHookEx(None, n_code, w_param, l_param);
                        }

                        // If Peekit window is focused and visible, Space toggles/closes it
                        let fg_hwnd = GetForegroundWindow();
                        let is_peekit_focused = window.hwnd().map(|h| h.0 == fg_hwnd.0).unwrap_or(false);

                        crate::log_debug(&format!(
                            "Peekit window state: visible={}, is_focused={}, fg_hwnd={:?}",
                            is_visible, is_peekit_focused, fg_hwnd
                        ));

                        if is_peekit_focused && is_visible {
                            hide_and_reset(app, &window);
                            return LRESULT(1); // Suppress Space
                        }

                        // Check if Explorer or Desktop is active
                        let is_exp = crate::explorer::is_explorer_or_desktop_active();
                        crate::log_debug(&format!("is_explorer_or_desktop_active = {}", is_exp));

                        if is_exp {
                            *LAST_EXPLORER_HWND.lock() = Some(fg_hwnd.0 as isize);

                            // Check if user is typing text (renaming or search)
                            let is_typing = crate::explorer::is_user_typing_text();
                            crate::log_debug(&format!("is_user_typing_text = {}", is_typing));

                            if is_typing {
                                return CallNextHookEx(None, n_code, w_param, l_param);
                            }

                            // Query Explorer COM on worker thread
                            let app_clone = app.clone();
                            let window_clone = window.clone();
                            std::thread::spawn(move || {
                                let selected_files = crate::explorer::get_selected_file_paths();
                                if !selected_files.is_empty() {
                                    let path = selected_files[0].clone();
                                    let is_same_file = {
                                        let cur = CURRENT_PREVIEW_PATH.lock();
                                        if let Some(ref c) = *cur {
                                            c == &path
                                        } else {
                                            false
                                        }
                                    };

                                    let is_vis = window_clone.is_visible().unwrap_or(false);

                                    // If window is visible and user pressed Space on the SAME file -> toggle close!
                                    if is_vis && is_same_file {
                                        crate::log_debug(&format!("Same file '{}' toggled off -> hiding window", path));
                                        hide_and_reset(&app_clone, &window_clone);
                                        return;
                                    }

                                    // Otherwise, preview this file!
                                    *CURRENT_PREVIEW_PATH.lock() = Some(path.clone());
                                    crate::log_debug(&format!("Worker thread got {} files, active: {}", selected_files.len(), path));
                                    let _ = app_clone.emit("preview_file", &path);
                                    let _ = app_clone.emit("preview_group", serde_json::json!({
                                        "files": selected_files,
                                        "index": 0
                                    }));
                                    let _ = window_clone.unminimize();
                                    let show_res = window_clone.show();
                                    let focus_res = window_clone.set_focus();
                                    #[cfg(windows)]
                                    if let Ok(hwnd) = window_clone.hwnd() {
                                        unsafe {
                                            let _ = SetForegroundWindow(HWND(hwnd.0));
                                        }
                                    }
                                    crate::log_debug(&format!("window.show: {:?}, set_focus: {:?}", show_res, focus_res));
                                } else {
                                    crate::log_debug("Worker thread: no file selected in Explorer");
                                    if window_clone.is_visible().unwrap_or(false) {
                                        hide_and_reset(&app_clone, &window_clone);
                                    }
                                }
                            });

                            return LRESULT(1); // Suppress Space in Explorer
                        }
                    }
                }
            }
        } else if vk_code == VK_ESCAPE.0 && is_key_down {
            crate::log_debug("Escape key DOWN event intercepted!");
            IS_SPACE_DOWN.store(false, Ordering::SeqCst);
            if let Some(ref app) = APP_HANDLE_RAW {
                if let Some(window) = app.get_webview_window("main") {
                    if window.is_visible().unwrap_or(false) {
                        hide_and_reset(app, &window);
                        return LRESULT(1); // Suppress Esc so explorer doesn't lose focus
                    }
                }
            }
        } else if is_key_down {
            // Any other key down means user is navigating or typing
            IS_SPACE_DOWN.store(false, Ordering::SeqCst);
        }
    }

    CallNextHookEx(None, n_code, w_param, l_param)
}

#[cfg(not(windows))]
pub fn start_hook(_app: AppHandle) {}
