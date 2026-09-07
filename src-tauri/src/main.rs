// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

#[cfg(windows)]
fn ensure_single_instance() -> Option<windows::Win32::Foundation::HANDLE> {
    use windows::core::w;
    use windows::Win32::Foundation::{GetLastError, ERROR_ALREADY_EXISTS};
    use windows::Win32::System::Threading::CreateMutexW;

    unsafe {
        let handle = CreateMutexW(None, true, w!("Local\\PeekIt_SingleInstance_Mutex")).ok()?;
        if GetLastError() == ERROR_ALREADY_EXISTS {
            peekit_lib::log_debug("Another instance of PeekIt is already running. Exiting.");
            std::process::exit(0);
        }
        Some(handle)
    }
}

fn main() {
    std::panic::set_hook(Box::new(|info| {
        peekit_lib::log_debug(&format!("CRITICAL PANIC: {:?}", info));
    }));

    #[cfg(windows)]
    let _mutex = ensure_single_instance();

    peekit_lib::run();
}
