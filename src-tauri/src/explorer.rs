#[cfg(windows)]
use windows::{
    core::*,
    Win32::Foundation::*,
    Win32::System::Com::*,
    Win32::UI::Shell::*,
    Win32::UI::WindowsAndMessaging::*,
};

#[cfg(windows)]
pub fn is_explorer_or_desktop_active() -> bool {
    unsafe {
        let hwnd = GetForegroundWindow();
        if hwnd.0 == (0 as _) {
            return false;
        }

        let mut class_name = [0u16; 256];
        let len = GetClassNameW(hwnd, &mut class_name);
        let class_str = if len > 0 {
            String::from_utf16_lossy(&class_name[..len as usize])
        } else {
            String::new()
        };

        crate::log_debug(&format!("is_explorer_check: hwnd={:?}, class='{}'", hwnd, class_str));

        if class_str == "Shell_TrayWnd" || class_str == "Shell_SecondaryTrayWnd" {
            return false;
        }
        if matches!(
            class_str.as_str(),
            "CabinetWClass" | "Progman" | "WorkerW" | "#32770"
        ) {
            return true;
        }

        let root = GetAncestor(hwnd, GA_ROOT);
        if root.0 != (0 as _) && root.0 != hwnd.0 {
            let mut root_class = [0u16; 256];
            let r_len = GetClassNameW(root, &mut root_class);
            if r_len > 0 {
                let r_class_str = String::from_utf16_lossy(&root_class[..r_len as usize]);
                crate::log_debug(&format!("is_explorer_check: root={:?}, class='{}'", root, r_class_str));
                if r_class_str == "Shell_TrayWnd" || r_class_str == "Shell_SecondaryTrayWnd" {
                    return false;
                }
                if matches!(r_class_str.as_str(), "CabinetWClass" | "Progman" | "WorkerW") {
                    return true;
                }
            }
        }

        // Check if process is explorer.exe
        let mut pid = 0u32;
        GetWindowThreadProcessId(hwnd, Some(&mut pid));
        if pid > 0 {
            if let Ok(process) = windows::Win32::System::Threading::OpenProcess(
                windows::Win32::System::Threading::PROCESS_QUERY_LIMITED_INFORMATION,
                false,
                pid,
            ) {
                let mut path_buf = [0u16; 1024];
                let mut path_len = path_buf.len() as u32;
                if windows::Win32::System::Threading::QueryFullProcessImageNameW(
                    process,
                    windows::Win32::System::Threading::PROCESS_NAME_FORMAT(0),
                    PWSTR(path_buf.as_mut_ptr()),
                    &mut path_len,
                ).is_ok() {
                    let exe_path = String::from_utf16_lossy(&path_buf[..path_len as usize]).to_lowercase();
                    let is_exp = exe_path.ends_with("\\explorer.exe");
                    crate::log_debug(&format!("process_check: pid={}, path='{}', is_exp={}", pid, exe_path, is_exp));
                    let _ = CloseHandle(process);
                    return is_exp;
                }
                let _ = CloseHandle(process);
            }
        }

        false
    }
}

#[cfg(windows)]
pub fn is_user_typing_text() -> bool {
    unsafe {
        let mut gui_info = GUITHREADINFO {
            cbSize: std::mem::size_of::<GUITHREADINFO>() as u32,
            ..Default::default()
        };

        if GetGUIThreadInfo(0, &mut gui_info).is_ok() {
            let focus_hwnd = gui_info.hwndFocus;
            if focus_hwnd.0 != (0 as _) {
                let mut class_name = [0u16; 256];
                let len = GetClassNameW(focus_hwnd, &mut class_name);
                let class_str = if len > 0 {
                    String::from_utf16_lossy(&class_name[..len as usize])
                } else {
                    String::new()
                };

                crate::log_debug(&format!("focus_control: hwnd={:?}, class='{}'", focus_hwnd, class_str));

                let class_lower = class_str.to_lowercase();
                if class_lower.contains("edit")
                    || class_lower.contains("richedit")
                    || class_lower.contains("search")
                    || class_lower.contains("textbox")
                {
                    return true;
                }
            }
        }
        false
    }
}

#[cfg(windows)]
unsafe fn get_all_files_from_dispatch(disp: &IDispatch) -> Vec<String> {
    let mut files = Vec::new();
    if let Ok(service_provider) = disp.cast::<IServiceProvider>() {
        if let Ok(shell_browser) = service_provider.QueryService::<IShellBrowser>(&SID_STopLevelBrowser) {
            if let Ok(shell_view) = shell_browser.QueryActiveShellView() {
                if let Ok(folder_view) = shell_view.cast::<IFolderView>() {
                    if let Ok(item_array) = folder_view.Items::<IShellItemArray>(SVGIO_SELECTION) {
                        let count = item_array.GetCount().unwrap_or(0);
                        for i in 0..count {
                            if let Ok(shell_item) = item_array.GetItemAt(i) {
                                if let Ok(name_ptr) = shell_item.GetDisplayName(SIGDN_FILESYSPATH) {
                                    if let Ok(path) = name_ptr.to_string() {
                                        files.push(path);
                                    }
                                    CoTaskMemFree(Some(name_ptr.0 as _));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    files
}

#[cfg(windows)]
#[allow(dead_code)]
unsafe fn get_file_from_dispatch(disp: &IDispatch) -> Option<String> {
    get_all_files_from_dispatch(disp).into_iter().next()
}

#[cfg(windows)]
unsafe fn get_desktop_selected_files() -> Vec<String> {
    let shell_windows: Result<IShellWindows> =
        CoCreateInstance(&ShellWindows, None, CLSCTX_ALL);

    if let Ok(windows) = shell_windows {
        let mut disp_hwnd = 0i32;
        let desktop_disp = windows.FindWindowSW(
            &VARIANT::from(0i32),
            &VARIANT::default(),
            SWC_DESKTOP,
            &mut disp_hwnd,
            SWFO_NEEDDISPATCH,
        );
        if let Ok(disp) = desktop_disp {
            return get_all_files_from_dispatch(&disp);
        }
    }
    Vec::new()
}

#[cfg(windows)]
#[allow(dead_code)]
unsafe fn get_desktop_selected_file() -> Option<String> {
    get_desktop_selected_files().into_iter().next()
}

#[cfg(windows)]
pub fn get_selected_file_paths() -> Vec<String> {
    unsafe {
        let _ = CoInitializeEx(None, COINIT_APARTMENTTHREADED);

        let fg_hwnd = GetForegroundWindow();
        if fg_hwnd.0 == (0 as _) {
            return Vec::new();
        }

        let root_hwnd = GetAncestor(fg_hwnd, GA_ROOT);
        let target_hwnd = if root_hwnd.0 != (0 as _) { root_hwnd } else { fg_hwnd };

        let mut class_name = [0u16; 256];
        let len = GetClassNameW(target_hwnd, &mut class_name);
        let class_str = if len > 0 {
            String::from_utf16_lossy(&class_name[..len as usize])
        } else {
            String::new()
        };

        if class_str == "Progman" || class_str == "WorkerW" {
            return get_desktop_selected_files();
        }

        let mut title_buf = [0u16; 256];
        let t_len = GetWindowTextW(target_hwnd, &mut title_buf);
        let fg_title = if t_len > 0 {
            String::from_utf16_lossy(&title_buf[..t_len as usize]).to_lowercase()
        } else {
            String::new()
        };

        let shell_windows: Result<IShellWindows> =
            CoCreateInstance(&ShellWindows, None, CLSCTX_ALL);

        match shell_windows {
            Ok(windows) => {
                let count = windows.Count().unwrap_or(0);
                crate::log_debug(&format!(
                    "get_selected_paths: target_hwnd={:?}, class='{}', title='{}', shell_windows_count={}",
                    target_hwnd, class_str, fg_title, count
                ));

                let mut title_match_files: Vec<String> = Vec::new();
                let mut fallback_files: Vec<String> = Vec::new();

                for i in 0..count {
                    if let Ok(dispatch) = windows.Item(&VARIANT::from(i)) {
                        let mut is_hwnd_match = false;
                        let mut loc_name = String::new();

                        if let Ok(wb2) = dispatch.cast::<IWebBrowser2>() {
                            if let Ok(wb_hwnd) = wb2.HWND() {
                                if wb_hwnd.0 == target_hwnd.0 as isize || wb_hwnd.0 == fg_hwnd.0 as isize {
                                    is_hwnd_match = true;
                                }
                            }
                            loc_name = wb2.LocationName()
                                .map(|b| b.to_string().to_lowercase())
                                .unwrap_or_default();
                        }

                        let files = get_all_files_from_dispatch(&dispatch);
                        if !files.is_empty() {
                            crate::log_debug(&format!(
                                "item {}: is_hwnd_match={}, loc='{}', count={}",
                                i, is_hwnd_match, loc_name, files.len()
                            ));

                            if is_hwnd_match {
                                crate::log_debug(&format!("Exact HWND match! Returning {} files", files.len()));
                                return files;
                            }

                            if title_match_files.is_empty() && !loc_name.is_empty() && !fg_title.is_empty() {
                                if fg_title.contains(&loc_name) || loc_name.contains(&fg_title) {
                                    title_match_files = files.clone();
                                }
                            }

                            if fallback_files.is_empty() {
                                fallback_files = files;
                            }
                        }
                    }
                }

                if !title_match_files.is_empty() {
                    return title_match_files;
                }

                if !fallback_files.is_empty() {
                    return fallback_files;
                }
            }
            Err(e) => {
                crate::log_debug(&format!("CoCreateInstance(ShellWindows) error: {:?}", e));
            }
        }

        get_desktop_selected_files()
    }
}

#[cfg(windows)]
#[allow(dead_code)]
pub fn get_selected_file_path() -> Option<String> {
    get_selected_file_paths().into_iter().next()
}

#[cfg(windows)]
pub fn navigate_adjacent_in_explorer(direction: &str) -> Option<String> {
    unsafe {
        let _ = CoInitializeEx(None, COINIT_APARTMENTTHREADED);

        let target_hwnd = crate::hook::get_last_explorer_hwnd();

        let shell_windows: Result<IShellWindows> =
            CoCreateInstance(&ShellWindows, None, CLSCTX_ALL);

        let windows = shell_windows.ok()?;
        let count = windows.Count().unwrap_or(0);

        for i in 0..count {
            if let Ok(dispatch) = windows.Item(&VARIANT::from(i)) {
                let mut is_target = false;
                if let Ok(wb2) = dispatch.cast::<IWebBrowser2>() {
                    if let Ok(wb_hwnd) = wb2.HWND() {
                        if let Some(th) = target_hwnd {
                            if wb_hwnd.0 == th {
                                is_target = true;
                            }
                        } else {
                            is_target = true;
                        }
                    }
                }

                if is_target {
                    if let Ok(service_provider) = dispatch.cast::<IServiceProvider>() {
                        if let Ok(shell_browser) = service_provider.QueryService::<IShellBrowser>(&SID_STopLevelBrowser) {
                            if let Ok(shell_view) = shell_browser.QueryActiveShellView() {
                                if let Ok(folder_view) = shell_view.cast::<IFolderView>() {
                                    let focused_idx = folder_view.GetFocusedItem().unwrap_or(0);
                                    let total_count = folder_view.ItemCount(_SVGIO(0)).unwrap_or(0);

                                    crate::log_debug(&format!(
                                        "navigate_adjacent: focused_idx={}, total_count={}, dir={}",
                                        focused_idx, total_count, direction
                                    ));

                                    if total_count > 0 {
                                        let new_idx = match direction {
                                            "ArrowDown" | "ArrowRight" => {
                                                if focused_idx < total_count - 1 {
                                                    focused_idx + 1
                                                } else {
                                                    focused_idx
                                                }
                                            }
                                            "ArrowUp" | "ArrowLeft" => {
                                                if focused_idx > 0 {
                                                    focused_idx - 1
                                                } else {
                                                    0
                                                }
                                            }
                                            _ => focused_idx,
                                        };

                                        // Select and focus the new item (0x1d = SVSI_SELECT | SVSI_FOCUSED | SVSI_DESELECTOTHERS | SVSI_ENSUREVISIBLE)
                                        let _ = folder_view.SelectItem(new_idx, 0x1d);

                                        // Query newly selected item
                                        if let Ok(item_array) = folder_view.Items::<IShellItemArray>(SVGIO_SELECTION) {
                                            if item_array.GetCount().unwrap_or(0) > 0 {
                                                if let Ok(shell_item) = item_array.GetItemAt(0) {
                                                    if let Ok(name_ptr) = shell_item.GetDisplayName(SIGDN_FILESYSPATH) {
                                                        let path = name_ptr.to_string().ok();
                                                        CoTaskMemFree(Some(name_ptr.0 as _));
                                                        crate::log_debug(&format!("navigate_adjacent succeeded: {:?}", path));
                                                        return path;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    None
}

#[cfg(not(windows))]
pub fn is_explorer_or_desktop_active() -> bool {
    false
}

#[cfg(not(windows))]
pub fn is_user_typing_text() -> bool {
    false
}

#[cfg(not(windows))]
pub fn get_selected_file_paths() -> Vec<String> {
    Vec::new()
}

#[cfg(not(windows))]
pub fn get_selected_file_path() -> Option<String> {
    None
}

#[cfg(not(windows))]
pub fn navigate_adjacent_in_explorer(_direction: &str) -> Option<String> {
    None
}
