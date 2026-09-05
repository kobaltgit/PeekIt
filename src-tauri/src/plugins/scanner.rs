use std::fs;
use std::path::{Path, PathBuf};
use crate::plugins::manifest::{PluginInfo, PluginManifest};

/// Resolves candidate directories where bundled or local plugins might reside.
fn get_candidate_plugin_dirs() -> Vec<PathBuf> {
    let mut candidates = Vec::new();
    if let Ok(exe_path) = std::env::current_exe() {
        if let Some(exe_dir) = exe_path.parent() {
            candidates.push(exe_dir.join("plugins"));
            candidates.push(exe_dir.join("_up_").join("plugins"));
            candidates.push(exe_dir.join("resources").join("plugins"));
            candidates.push(exe_dir.join("resources").join("_up_").join("plugins"));
        }
    }
    candidates.push(PathBuf::from("./plugins"));
    candidates
}

/// Resolves the base plugins directory, honoring portable mode if active.
pub fn get_plugins_dir() -> PathBuf {
    // 1. Check local directory next to executable (portable mode or unpacked local)
    if let Ok(exe_path) = std::env::current_exe() {
        if let Some(exe_dir) = exe_path.parent() {
            let local_plugins = exe_dir.join("plugins");
            let up_plugins = exe_dir.join("_up_").join("plugins");
            let portable_marker = exe_dir.join("portable.txt");
            if portable_marker.exists() || local_plugins.exists() {
                return local_plugins;
            }
            if up_plugins.exists() {
                return local_plugins;
            }
        }
    }

    // 2. Check current working directory for local development (e.g. ./plugins)
    let cwd_plugins = Path::new("./plugins");
    if cwd_plugins.exists() {
        if let Ok(canon) = cwd_plugins.canonicalize() {
            return canon;
        }
        return cwd_plugins.to_path_buf();
    }

    // 3. Fallback to %APPDATA%/Peekit/plugins
    if let Some(proj_dirs) = directories::ProjectDirs::from("com", "peekit", "Peekit") {
        proj_dirs.config_dir().join("plugins")
    } else {
        PathBuf::from("./plugins")
    }
}

fn copy_dir_all(src: &Path, dst: &Path) -> std::io::Result<()> {
    fs::create_dir_all(dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let file_type = entry.file_type()?;
        if file_type.is_dir() {
            copy_dir_all(&entry.path(), &dst.join(entry.file_name()))?;
        } else {
            fs::copy(entry.path(), dst.join(entry.file_name()))?;
        }
    }
    Ok(())
}

/// Ensures the plugins directory exists and returns its path.
pub fn ensure_plugins_dir() -> Result<PathBuf, String> {
    let dir = get_plugins_dir();
    if !dir.exists() {
        fs::create_dir_all(&dir).map_err(|e| format!("Failed to create plugins dir '{:?}': {}", dir, e))?;
    }

    // Check if _up_\plugins exists next to exe and copy to exe\plugins if needed
    if let Ok(exe_path) = std::env::current_exe() {
        if let Some(exe_dir) = exe_path.parent() {
            let up_plugins = exe_dir.join("_up_").join("plugins");
            let local_plugins = exe_dir.join("plugins");
            if up_plugins.exists() && (!local_plugins.exists() || dir == local_plugins) {
                let _ = copy_dir_all(&up_plugins, &local_plugins);
            }
        }
    }

    // Seed/update default plugins from bundled resources into target dir
    for candidate in get_candidate_plugin_dirs() {
        if candidate.exists() && candidate != dir {
            if let Ok(entries) = fs::read_dir(&candidate) {
                for entry in entries.flatten() {
                    if entry.path().is_dir() {
                        let name = entry.file_name();
                        let target_plugin_dir = dir.join(&name);
                        let _ = copy_dir_all(&entry.path(), &target_plugin_dir);
                    }
                }
            }
        }
    }

    Ok(dir)
}

fn find_plugin_in(dir: &Path, plugin_id: &str) -> Option<PathBuf> {
    if !dir.exists() {
        return None;
    }
    let entries = fs::read_dir(dir).ok()?;
    for entry in entries.flatten() {
        let path = entry.path();
        if path.is_dir() {
            let manifest_path = path.join("manifest.json");
            if manifest_path.exists() {
                if let Ok(content) = fs::read_to_string(&manifest_path) {
                    if let Ok(manifest) = serde_json::from_str::<PluginManifest>(&content) {
                        if manifest.id == plugin_id {
                            return Some(path);
                        }
                    }
                }
            }
        }
    }
    None
}

/// Finds the root directory for a specific plugin ID.
pub fn find_plugin_dir(plugin_id: &str) -> Option<PathBuf> {
    let primary_dir = get_plugins_dir();
    if let Some(p) = find_plugin_in(&primary_dir, plugin_id) {
        return Some(p);
    }
    for cand in get_candidate_plugin_dirs() {
        if cand != primary_dir {
            if let Some(p) = find_plugin_in(&cand, plugin_id) {
                return Some(p);
            }
        }
    }
    None
}

/// Scans the plugins directory and returns all valid, loaded plugins.
pub fn scan_plugins(disabled_plugin_ids: &[String]) -> Vec<PluginInfo> {
    let mut plugins: Vec<PluginInfo> = Vec::new();
    let mut seen_ids = std::collections::HashSet::new();

    let plugins_dir = match ensure_plugins_dir() {
        Ok(dir) => dir,
        Err(e) => {
            crate::log_debug(&format!("[PluginScanner] Error ensuring plugins dir: {}", e));
            return plugins;
        }
    };

    crate::log_debug(&format!("[PluginScanner] Primary directory: {:?}", plugins_dir));

    let mut dirs_to_scan = vec![plugins_dir];
    for cand in get_candidate_plugin_dirs() {
        if !dirs_to_scan.contains(&cand) && cand.exists() {
            dirs_to_scan.push(cand);
        }
    }

    for dir in dirs_to_scan {
        if let Ok(entries) = fs::read_dir(&dir) {
            for entry in entries.flatten() {
                let path = entry.path();
                if path.is_dir() {
                    let manifest_path = path.join("manifest.json");
                    if manifest_path.exists() && manifest_path.is_file() {
                        if let Ok(content) = fs::read_to_string(&manifest_path) {
                            if let Ok(mut manifest) = serde_json::from_str::<PluginManifest>(&content) {
                                if manifest.validate_and_normalize().is_err() {
                                    continue;
                                }
                                if seen_ids.contains(&manifest.id) {
                                    continue;
                                }
                                let entry_path = path.join(&manifest.entry);
                                if !entry_path.exists() {
                                    continue;
                                }
                                seen_ids.insert(manifest.id.clone());
                                let is_enabled = !disabled_plugin_ids.contains(&manifest.id);
                                let root_path_str = path.to_string_lossy().to_string();

                                crate::log_debug(&format!(
                                    "[PluginScanner] Loaded plugin '{}' v{} ({:?}) enabled={} from {:?}",
                                    manifest.name, manifest.version, manifest.extensions, is_enabled, path
                                ));

                                plugins.push(PluginInfo {
                                    manifest,
                                    root_path: root_path_str,
                                    is_enabled,
                                });
                            }
                        }
                    }
                }
            }
        }
    }

    plugins
}

/// Installs a .pkit (or .zip) plugin package into the active plugins directory.
pub fn install_plugin_package(package_path: &Path) -> Result<PluginInfo, String> {
    if !package_path.exists() {
        return Err(format!("Package file not found: {:?}", package_path));
    }

    let file = fs::File::open(package_path)
        .map_err(|e| format!("Failed to open package file: {}", e))?;
    let mut archive = zip::ZipArchive::new(file)
        .map_err(|e| format!("Failed to read ZIP archive: {}", e))?;

    // Find manifest.json in archive (either at root or in top-level directory)
    let mut manifest_index = None;
    let mut prefix_to_strip = String::new();

    for i in 0..archive.len() {
        let entry = archive.by_index(i).map_err(|e| e.to_string())?;
        let name = entry.name().replace('\\', "/");
        if name == "manifest.json" {
            manifest_index = Some(i);
            prefix_to_strip = String::new();
            break;
        } else if name.ends_with("/manifest.json") && name.matches('/').count() == 1 {
            manifest_index = Some(i);
            let parts: Vec<&str> = name.split('/').collect();
            prefix_to_strip = format!("{}/", parts[0]);
            break;
        }
    }

    let manifest_idx = manifest_index.ok_or_else(|| "Invalid plugin package: manifest.json not found in archive".to_string())?;

    // Parse manifest to get plugin id and name
    let manifest: PluginManifest = {
        let mut manifest_file = archive.by_index(manifest_idx).map_err(|e| e.to_string())?;
        let mut content = String::new();
        std::io::Read::read_to_string(&mut manifest_file, &mut content).map_err(|e| e.to_string())?;
        serde_json::from_str(&content).map_err(|e| format!("Failed to parse manifest.json: {}", e))?
    };

    let plugin_id = manifest.id.clone();
    let plugins_dir = ensure_plugins_dir()?;
    let target_dir = plugins_dir.join(&plugin_id);

    if target_dir.exists() {
        let _ = fs::remove_dir_all(&target_dir);
    }
    fs::create_dir_all(&target_dir)
        .map_err(|e| format!("Failed to create plugin target dir {:?}: {}", target_dir, e))?;

    // Extract files into target_dir
    for i in 0..archive.len() {
        let mut entry = archive.by_index(i).map_err(|e| e.to_string())?;
        let raw_name = entry.name().replace('\\', "/");

        let rel_name = if !prefix_to_strip.is_empty() && raw_name.starts_with(&prefix_to_strip) {
            &raw_name[prefix_to_strip.len()..]
        } else {
            &raw_name
        };

        if rel_name.is_empty() {
            continue;
        }

        let out_path = target_dir.join(rel_name);

        if entry.is_dir() {
            fs::create_dir_all(&out_path).map_err(|e| e.to_string())?;
        } else {
            if let Some(parent) = out_path.parent() {
                if !parent.exists() {
                    fs::create_dir_all(parent).map_err(|e| e.to_string())?;
                }
            }
            let mut out_file = fs::File::create(&out_path)
                .map_err(|e| format!("Failed to create file {:?}: {}", out_path, e))?;
            std::io::copy(&mut entry, &mut out_file)
                .map_err(|e| format!("Failed to write file {:?}: {}", out_path, e))?;
        }
    }

    crate::log_debug(&format!("[PluginScanner] Successfully installed plugin '{}' ({}) into {:?}", manifest.name, manifest.id, target_dir));

    Ok(PluginInfo {
        manifest,
        root_path: target_dir.to_string_lossy().to_string(),
        is_enabled: true,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_scan_plugins_discovers_font_plugin() {
        let plugins = scan_plugins(&[]);
        println!("Found plugins count: {}", plugins.len());
        for p in &plugins {
            println!("Plugin: id={}, name={}, extensions={:?}", p.manifest.id, p.manifest.name, p.manifest.extensions);
        }
        let font_plugin = plugins.iter().find(|p| p.manifest.id == "com.peekit.font-viewer");
        assert!(font_plugin.is_some(), "Expected com.peekit.font-viewer to be discovered");
        let p = font_plugin.unwrap();
        assert!(p.manifest.extensions.contains(&".ttf".to_string()));
    }
}
