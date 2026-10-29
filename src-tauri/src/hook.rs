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
static WATCHER_ACTIVE: AtomicBool = AtomicBool::new(false);
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

/// Shows (or refreshes) the preview for `selected_files` and focuses the window.
#[cfg(windows)]
fn show_preview(app: &AppHandle, window: &tauri::WebviewWindow, selected_files: Vec<String>) {
    let path = selected_files[0].clone();
    *CURRENT_PREVIEW_PATH.lock() = Some(path.clone());
    crate::log_debug(&format!("Worker thread got {} files, active: {}", selected_files.len(), path));
    let _ = app.emit("preview_file", &path);
    let _ = app.emit("preview_group", serde_json::json!({
        "files": selected_files,
        "index": 0
    }));
    let _ = window.unminimize();
    let show_res = window.show();
    let focus_res = window.set_focus();
    #[cfg(windows)]
    if let Ok(hwnd) = window.hwnd() {
        unsafe {
            let _ = SetForegroundWindow(HWND(hwnd.0));
        }
    }
    crate::log_debug(&format!("window.show: {:?}, set_focus: {:?}", show_res, focus_res));

    ensure_preview_watcher(app.clone());
}

/// Raises the window in z-order without stealing keyboard focus
/// (QuickLook-style: the preview floats up, the Explorer keeps focus).
#[cfg(windows)]
fn raise_without_activation(window: &tauri::WebviewWindow) {
    use windows::Win32::UI::WindowsAndMessaging::{SetWindowPos, SWP_NOACTIVATE, SWP_NOMOVE, SWP_NOSIZE};
    if let Ok(hwnd) = window.hwnd() {
        unsafe {
            let _ = SetWindowPos(
                HWND(hwnd.0),
                HWND_TOPMOST,
                0,
                0,
                0,
                0,
                SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE,
            );
            let _ = SetWindowPos(
                HWND(hwnd.0),
                HWND_NOTOPMOST,
                0,
                0,
                0,
                0,
                SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE,
            );
        }
    }
}

/// QuickLook-style live preview: while the preview window is open, watch the
/// Explorer selection and refresh the preview automatically as soon as the
/// user clicks another file — no Space press needed. The window is raised
/// without activation, so the Explorer keeps keyboard focus.
#[cfg(windows)]
fn ensure_preview_watcher(app: AppHandle) {
    if WATCHER_ACTIVE.swap(true, Ordering::SeqCst) {
        return;
    }

    std::thread::spawn(move || {
        crate::log_debug("Preview watcher started");
        loop {
            std::thread::sleep(std::time::Duration::from_millis(350));
            let Some(window) = app.get_webview_window("main") else { break };
            if !window.is_visible().unwrap_or(false) {
                break;
            }

            // While the user is looking at the preview itself, nothing to follow.
            let focused = window
                .hwnd()
                .map(|h| unsafe { h.0 == GetForegroundWindow().0 })
                .unwrap_or(false);
            if focused || !crate::explorer::is_explorer_or_desktop_active() {
                continue;
            }

            let fg = unsafe { GetForegroundWindow() };
            *LAST_EXPLORER_HWND.lock() = Some(fg.0 as isize);
            let selected_files = crate::explorer::get_selected_file_paths_for(Some(fg.0 as isize));
            let Some(path) = selected_files.first().cloned() else { continue };

            let is_new = {
                let cur = CURRENT_PREVIEW_PATH.lock();
                cur.as_deref() != Some(path.as_str())
            };
            if !is_new {
                continue;
            }

            crate::log_debug(&format!("[Watcher] Selection changed -> live preview: {}", path));
            *CURRENT_PREVIEW_PATH.lock() = Some(path.clone());
            let _ = app.emit("preview_file", &path);
            let _ = app.emit("preview_group", serde_json::json!({
                "files": selected_files,
                "index": 0
            }));
            raise_without_activation(&window);
        }
        crate::log_debug("Preview watcher stopped");
        WATCHER_ACTIVE.store(false, Ordering::SeqCst);
    });
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

                        let fg_hwnd = GetForegroundWindow();
                        let is_peekit_focused = window.hwnd().map(|h| h.0 == fg_hwnd.0).unwrap_or(false);

                        crate::log_debug(&format!(
                            "Peekit window state: visible={}, is_focused={}, fg_hwnd={:?}",
                            is_visible, is_peekit_focused, fg_hwnd
                        ));

                        // Check if Explorer or Desktop is active
                        let is_exp = crate::explorer::is_explorer_or_desktop_active();
                        crate::log_debug(&format!("is_explorer_or_desktop_active = {}", is_exp));

                        if is_visible {
                            // While the preview is open, Space belongs to Peekit:
                            // it refreshes, re-opens or closes the window.
                            if !is_exp && !is_peekit_focused {
                                // Focus is in an unrelated app — let Space through untouched.
                                return CallNextHookEx(None, n_code, w_param, l_param);
                            }

                            if is_exp {
                                *LAST_EXPLORER_HWND.lock() = Some(fg_hwnd.0 as isize);

                                // Check if user is typing text (renaming or search)
                                let is_typing = crate::explorer::is_user_typing_text();
                                crate::log_debug(&format!("is_user_typing_text = {}", is_typing));

                                if is_typing {
                                    return CallNextHookEx(None, n_code, w_param, l_param);
                                }
                            }

                        // Remember which window owns the selection and query it on a
                        // worker thread: the Explorer window that was active when Space
                        // was pressed, or the last remembered one when Peekit itself
                        // owns the foreground.
                        let target_hwnd: Option<isize> = if is_exp {
                            Some(fg_hwnd.0 as isize)
                        } else {
                            get_last_explorer_hwnd()
                        };
                        let app_clone = app.clone();
                        let window_clone = window.clone();
                        std::thread::spawn(move || {
                            let selected_files = match target_hwnd {
                                Some(hwnd) => crate::explorer::get_selected_file_paths_for(Some(hwnd)),
                                None => Vec::new(),
                            };
                            let still_focused = window_clone
                                .hwnd()
                                .map(|h| unsafe { h.0 == GetForegroundWindow().0 })
                                .unwrap_or(false);

                                match selected_files.first() {
                                    Some(path) => {
                                        let path = path.clone();
                                        let is_same_file = {
                                            let cur = CURRENT_PREVIEW_PATH.lock();
                                            if let Some(ref c) = *cur {
                                                c == &path
                                            } else {
                                                false
                                            }
                                        };

                                        // Same file -> toggle close! (documented Space
                                        // behavior: open/close the preview)
                                        if is_same_file {
                                            crate::log_debug(&format!("Same file '{}' toggled off -> hiding window", path));
                                            hide_and_reset(&app_clone, &window_clone);
                                            return;
                                        }

                                        // Different file -> open/refresh preview!
                                        show_preview(&app_clone, &window_clone, selected_files);
                                    }
                                    None => {
                                        crate::log_debug("Worker thread: no file selected in Explorer");
                                        // Only an explicit toggle on the focused window closes
                                        // it; an empty or unstable selection must never yank
                                        // the preview away (COM hiccups right after a click).
                                        if still_focused && window_clone.is_visible().unwrap_or(false) {
                                            hide_and_reset(&app_clone, &window_clone);
                                        }
                                    }
                                }
                            });

                            return LRESULT(1); // Suppress Space while preview is open
                        }

                        if is_exp {
                            *LAST_EXPLORER_HWND.lock() = Some(fg_hwnd.0 as isize);

                            // Check if user is typing text (renaming or search)
                            let is_typing = crate::explorer::is_user_typing_text();
                            crate::log_debug(&format!("is_user_typing_text = {}", is_typing));

                            if is_typing {
                                return CallNextHookEx(None, n_code, w_param, l_param);
                            }

                            // Query Explorer COM on worker thread
                            let target_hwnd = fg_hwnd.0 as isize;
                            let app_clone = app.clone();
                            let window_clone = window.clone();
                            std::thread::spawn(move || {
                                let selected_files = crate::explorer::get_selected_file_paths_for(Some(target_hwnd));
                                if !selected_files.is_empty() {
                                    show_preview(&app_clone, &window_clone, selected_files);
                                } else {
                                    crate::log_debug("Worker thread: no file selected in Explorer");
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
