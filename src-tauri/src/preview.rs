use serde::{Deserialize, Serialize};
use std::fs::File;
use std::io::Read;
use std::path::Path;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct FileDimensions {
    pub width: u32,
    pub height: u32,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ArchiveEntry {
    pub name: String,
    pub full_path: String,
    pub size_bytes: u64,
    pub compressed_size_bytes: u64,
    pub is_directory: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct FolderItem {
    pub name: String,
    pub path: String,
    pub is_dir: bool,
    pub size_bytes: u64,
    pub size_formatted: String,
    pub modified: String,
    pub extension: String,
}

#[derive(Debug, Serialize, Deserialize, Clone, Default)]
#[serde(rename_all = "camelCase")]
pub struct FolderStats {
    pub file_count: usize,
    pub folder_count: usize,
    pub total_bytes: u64,
    pub total_formatted: String,
}

#[derive(Debug, Serialize, Deserialize, Clone, Default)]
#[serde(rename_all = "camelCase")]
pub struct FileExtraInfo {
    pub dimensions: Option<FileDimensions>,
    pub duration_seconds: Option<f64>,
    pub line_count: Option<usize>,
    pub archive_entries: Option<Vec<ArchiveEntry>>,
    pub is_cloud_placeholder: Option<bool>,
    pub folder_items: Option<Vec<FolderItem>>,
    pub folder_stats: Option<FolderStats>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct FilePreviewInfo {
    pub path: String,
    pub file_name: String,
    pub extension: String,
    pub size_bytes: u64,
    pub size_formatted: String,
    pub modified: String,
    pub category: String,
    pub mime_type: String,
    pub extra: Option<FileExtraInfo>,
}

pub fn format_bytes(bytes: u64) -> String {
    if bytes == 0 {
        return "0 B".to_string();
    }
    const K: f64 = 1024.0;
    let sizes = ["B", "KB", "MB", "GB", "TB"];
    let i = (bytes as f64).log(K).floor() as usize;
    let i = i.min(sizes.len() - 1);
    let val = (bytes as f64) / K.powi(i as i32);
    format!("{:.1} {}", val, sizes[i])
}

pub fn detect_category(ext: &str) -> &'static str {
    match ext {
        "png" | "jpg" | "jpeg" | "webp" | "gif" | "svg" | "bmp" | "ico" | "avif" | "tiff" | "tif" => "image",
        "mp4" | "webm" | "mkv" | "avi" | "mov" | "wmv" | "flv" | "m4v" => "video",
        "mp3" | "wav" | "ogg" | "flac" | "aac" | "m4a" | "wma" => "audio",
        "pdf" => "pdf",
        "md" | "markdown" | "mdown" | "mkd" => "markdown",
        "zip" => "archive",
        "rs" | "js" | "mjs" | "cjs" | "ts" | "mts" | "cts" | "jsx" | "tsx" | "svelte" | "vue" | "astro" |
        "html" | "htm" | "css" | "scss" | "sass" | "less" | "json" | "jsonc" | "json5" |
        "xml" | "yaml" | "yml" | "toml" | "c" | "cpp" | "cc" | "cxx" | "h" | "hpp" | "hxx" |
        "cs" | "go" | "py" | "pyw" | "rb" | "php" | "java" | "kt" | "kts" | "swift" | "dart" |
        "sh" | "bash" | "zsh" | "fish" | "bat" | "cmd" | "ps1" | "psm1" | "sql" |
        "dockerfile" | "makefile" | "cmake" | "gradle" | "properties" | "lua" | "r" | "scala" | "groovy" |
        "perl" | "pl" | "pm" | "diff" | "patch" | "asm" | "s" | "v" | "sv" | "vhdl" |
        "zig" | "nim" | "erl" | "ex" | "exs" | "clj" | "cljs" | "lisp" | "hs" | "proto" | "graphql" | "gql" => "code",
        "txt" | "log" | "ini" | "cfg" | "conf" | "config" | "env" | "csv" | "tsv" | "nfo" |
        "gitignore" | "gitattributes" | "gitmodules" | "editorconfig" | "npmrc" | "lock" => "text",
        _ => "generic",
    }
}

pub fn read_folder_entries(path_str: &str) -> Result<Vec<FolderItem>, String> {
    let path = Path::new(path_str);
    if !path.exists() {
        return Err("Directory does not exist".to_string());
    }
    if !path.is_dir() {
        return Err("Target path is not a directory".to_string());
    }

    let read_dir = std::fs::read_dir(path).map_err(|e| format!("Cannot read directory: {}", e))?;

    let mut items = Vec::new();
    for entry_res in read_dir {
        if let Ok(entry) = entry_res {
            let entry_path = entry.path();
            let entry_meta = entry.metadata().ok();
            let is_dir = entry_meta.as_ref().map(|m| m.is_dir()).unwrap_or(false);
            let size_bytes = if is_dir {
                0
            } else {
                entry_meta.as_ref().map(|m| m.len()).unwrap_or(0)
            };
            let size_formatted = if is_dir {
                String::new()
            } else {
                format_bytes(size_bytes)
            };
            let name = entry.file_name().to_string_lossy().to_string();
            let extension = if is_dir {
                "<folder>".to_string()
            } else {
                entry_path.extension().and_then(|e| e.to_str()).unwrap_or("").to_lowercase()
            };
            let modified = entry_meta
                .and_then(|m| m.modified().ok())
                .and_then(|t| {
                    let datetime: chrono::DateTime<chrono::Local> = t.into();
                    Some(datetime.format("%Y-%m-%d %H:%M").to_string())
                })
                .unwrap_or_else(|| "Unknown".to_string());

            items.push(FolderItem {
                name,
                path: entry_path.to_string_lossy().to_string(),
                is_dir,
                size_bytes,
                size_formatted,
                modified,
                extension,
            });

            if items.len() >= 1000 {
                break;
            }
        }
    }

    // Sort: directories first, then alphabetical
    items.sort_by(|a, b| {
        if a.is_dir != b.is_dir {
            b.is_dir.cmp(&a.is_dir)
        } else {
            a.name.to_lowercase().cmp(&b.name.to_lowercase())
        }
    });

    Ok(items)
}

pub fn inspect_file(path_str: &str) -> Result<FilePreviewInfo, String> {
    let path = Path::new(path_str);
    if !path.exists() {
        return Err("File does not exist".to_string());
    }

    let metadata = std::fs::metadata(path).map_err(|e| e.to_string())?;

    let file_name = path
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("Unknown")
        .to_string();

    if metadata.is_dir() {
        let items = read_folder_entries(path_str).unwrap_or_default();
        let mut file_count = 0;
        let mut folder_count = 0;
        let mut total_bytes = 0;

        for item in &items {
            if item.is_dir {
                folder_count += 1;
            } else {
                file_count += 1;
                total_bytes += item.size_bytes;
            }
        }

        let stats = FolderStats {
            file_count,
            folder_count,
            total_bytes,
            total_formatted: format_bytes(total_bytes),
        };

        let mut extra = FileExtraInfo::default();
        extra.folder_items = Some(items);
        extra.folder_stats = Some(stats);

        let modified = metadata
            .modified()
            .ok()
            .and_then(|t| {
                let datetime: chrono::DateTime<chrono::Local> = t.into();
                Some(datetime.format("%Y-%m-%d %H:%M").to_string())
            })
            .unwrap_or_else(|| "Unknown".to_string());

        return Ok(FilePreviewInfo {
            path: path_str.to_string(),
            file_name,
            extension: "<folder>".to_string(),
            size_bytes: total_bytes,
            size_formatted: format_bytes(total_bytes),
            modified,
            category: "folder".to_string(),
            mime_type: "inode/directory".to_string(),
            extra: Some(extra),
        });
    }

    let size_bytes = metadata.len();
    let size_formatted = format_bytes(size_bytes);

    let extension = path
        .extension()
        .and_then(|e| e.to_str())
        .unwrap_or("")
        .to_lowercase();

    let mut category = detect_category(&extension).to_string();
    let mut mime_type = mime_guess::from_path(path)
        .first_or_octet_stream()
        .to_string();

    // Cloud placeholder state, needed before any content reads: sniffing a
    // OneDrive/iCloud placeholder would trigger a full download.
    #[cfg(windows)]
    let is_cloud_placeholder = {
        use std::os::windows::fs::MetadataExt;
        let attrs = metadata.file_attributes();
        // 0x00001000 = FILE_ATTRIBUTE_OFFLINE
        // 0x00400000 = FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS
        (attrs & 0x00001000 != 0) || (attrs & 0x00400000 != 0)
    };
    #[cfg(not(windows))]
    let is_cloud_placeholder = false;

    if category == "generic" {
        let lower_name = file_name.to_lowercase();
        if lower_name == "dockerfile"
            || lower_name == "makefile"
            || lower_name == "cmakelists.txt"
            || lower_name == "license"
            || lower_name == "gemfile"
        {
            category = "code".to_string();
        } else if lower_name.starts_with(".env")
            || lower_name.starts_with(".git")
            || lower_name.ends_with("rc")
        {
            category = "text".to_string();
        } else if mime_type.starts_with("text/")
            || mime_type.contains("json")
            || mime_type.contains("xml")
            || mime_type.contains("javascript")
        {
            category = "code".to_string();
        }
    }

    // Content sniffing as the last resort: dotfiles without an extension
    // (.git/config, .ssh/known_hosts) and files with made-up extensions are
    // often plain text even though the name/MIME gives no hint.
    if category == "generic" && !is_cloud_placeholder && sniff_is_text(path) {
        category = "text".to_string();
        mime_type = "text/plain".to_string();
    }

    let modified = metadata
        .modified()
        .ok()
        .and_then(|t| {
            let datetime: chrono::DateTime<chrono::Local> = t.into();
            Some(datetime.format("%Y-%m-%d %H:%M").to_string())
        })
        .unwrap_or_else(|| "Unknown".to_string());

    let mut extra = FileExtraInfo::default();

    // Check Windows attributes for Cloud Placeholders (OneDrive / iCloud)
    #[cfg(windows)]
    {
        use std::os::windows::fs::MetadataExt;
        let attrs = metadata.file_attributes();
        // 0x00001000 = FILE_ATTRIBUTE_OFFLINE
        // 0x00400000 = FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS
        if (attrs & 0x00001000 != 0) || (attrs & 0x00400000 != 0) {
            extra.is_cloud_placeholder = Some(true);
        }
    }

    // Specific category inspectors
    if category == "image" && extra.is_cloud_placeholder != Some(true) {
        if extension == "svg" {
            extra.dimensions = extract_svg_dimensions(path);
        } else if let Ok((w, h)) = image::image_dimensions(path) {
            extra.dimensions = Some(FileDimensions { width: w, height: h });
        }
    } else if category == "archive" && extension == "zip" && extra.is_cloud_placeholder != Some(true) {
        if let Ok(file) = File::open(path) {
            if let Ok(mut archive) = zip::ZipArchive::new(file) {
                let mut entries = Vec::new();
                for i in 0..archive.len().min(500) {
                    if let Ok(item) = archive.by_index(i) {
                        let name = item.name().to_string();
                        let clean_name = name.split('/').filter(|s| !s.is_empty()).last().unwrap_or(&name).to_string();
                        entries.push(ArchiveEntry {
                            name: clean_name,
                            full_path: name.clone(),
                            size_bytes: item.size(),
                            compressed_size_bytes: item.compressed_size(),
                            is_directory: item.is_dir(),
                        });
                    }
                }
                extra.archive_entries = Some(entries);
            }
        }
    }

    Ok(FilePreviewInfo {
        path: path_str.to_string(),
        file_name,
        extension,
        size_bytes,
        size_formatted,
        modified,
        category,
        mime_type,
        extra: Some(extra),
    })
}

pub fn read_file_text_capped(path_str: &str, max_bytes: usize) -> Result<String, String> {
    let path = Path::new(path_str);
    let file = File::open(path).map_err(|e| e.to_string())?;
    let mut buffer = Vec::new();
    let mut take = file.take(max_bytes as u64);
    take.read_to_end(&mut buffer).map_err(|e| e.to_string())?;

    // BOM-aware decode: strip the UTF-8 BOM and decode UTF-16 files properly
    // instead of rendering them as NUL-riddled mojibake.
    if buffer.starts_with(&[0xEF, 0xBB, 0xBF]) {
        return Ok(String::from_utf8_lossy(&buffer[3..]).to_string());
    }
    if buffer.starts_with(&[0xFF, 0xFE]) || buffer.starts_with(&[0xFE, 0xFF]) {
        let little_endian = buffer[0] == 0xFF;
        let units: Vec<u16> = buffer[2..]
            .chunks_exact(2)
            .map(|c| {
                if little_endian {
                    u16::from_le_bytes([c[0], c[1]])
                } else {
                    u16::from_be_bytes([c[0], c[1]])
                }
            })
            .collect();
        return Ok(String::from_utf16_lossy(&units));
    }

    String::from_utf8(buffer)
        .or_else(|e| Ok(String::from_utf8_lossy(e.as_bytes()).to_string()))
}

/// Content sniffing: does the leading part of the file look like plain text?
/// Last resort for files whose name/extension gives no hint (.git/config,
/// .ssh/known_hosts, extensionless LICENSE, made-up extensions) so they
/// preview as text instead of the generic info card. Mirrors git's heuristic
/// (NUL byte => binary) plus a control-character ratio check.
pub fn sniff_is_text(path: &Path) -> bool {
    let mut file = match File::open(path) {
        Ok(f) => f,
        Err(_) => return false,
    };
    let mut buf = vec![0u8; 8192];
    let n = match file.read(&mut buf) {
        Ok(n) => n,
        Err(_) => return false,
    };
    buf.truncate(n);

    // Empty files preview fine as an empty text view.
    if buf.is_empty() {
        return true;
    }

    // Unicode BOMs unambiguously mark text content.
    if buf.starts_with(&[0xEF, 0xBB, 0xBF])
        || buf.starts_with(&[0xFF, 0xFE])
        || buf.starts_with(&[0xFE, 0xFF])
    {
        return true;
    }

    // A NUL byte anywhere in the sample is git's binary heuristic — trust it.
    if buf.contains(&0) {
        return false;
    }

    // Control characters other than common whitespace/escape sequences.
    let controls = buf
        .iter()
        .filter(|&&b| b < 0x20 && !matches!(b, b'\t' | b'\n' | b'\r' | 0x08 | 0x0C | 0x1B))
        .count();
    if controls * 20 > buf.len() {
        return false;
    }

    true
}

pub fn extract_svg_dimensions(path: &Path) -> Option<FileDimensions> {
    let mut file = File::open(path).ok()?;
    let mut buf = vec![0u8; 8192];
    let n = file.read(&mut buf).ok()?;
    let s = String::from_utf8_lossy(&buf[..n]);

    let find_attr = |attr: &str| -> Option<f64> {
        let needle = format!("{}=\"", attr);
        if let Some(pos) = s.find(&needle) {
            let rem = &s[pos + needle.len()..];
            if let Some(end) = rem.find('"') {
                let val_str = &rem[..end];
                let num_str = val_str.trim_end_matches(|c: char| c.is_alphabetic() || c == '%');
                return num_str.parse::<f64>().ok();
            }
        }
        None
    };

    if let (Some(w), Some(h)) = (find_attr("width"), find_attr("height")) {
        if w > 0.0 && h > 0.0 {
            return Some(FileDimensions { width: w as u32, height: h as u32 });
        }
    }

    if let Some(pos) = s.find("viewBox=\"") {
        let rem = &s[pos + 9..];
        if let Some(end) = rem.find('"') {
            let parts: Vec<&str> = rem[..end]
                .split(|c: char| c.is_whitespace() || c == ',')
                .filter(|p| !p.is_empty())
                .collect();
            if parts.len() == 4 {
                if let (Ok(w), Ok(h)) = (parts[2].parse::<f64>(), parts[3].parse::<f64>()) {
                    if w > 0.0 && h > 0.0 {
                        return Some(FileDimensions { width: w as u32, height: h as u32 });
                    }
                }
            }
        }
    }

    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_svg() {
        let path = Path::new("../peekit_icon.svg");
        if path.exists() {
            let dims = extract_svg_dimensions(path);
            assert!(dims.is_some());
            let d = dims.unwrap();
            assert_eq!(d.width, 512);
            assert_eq!(d.height, 512);
        }
    }

    fn temp_file(tag: &str, bytes: &[u8]) -> std::path::PathBuf {
        let p = std::env::temp_dir().join(format!(
            "peekit_test_{}_{}.txt",
            tag,
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        std::fs::write(&p, bytes).unwrap();
        p
    }

    #[test]
    fn test_sniff_real_git_config_is_text() {
        // This repository's own .git/config — the user-reported scenario.
        let path = Path::new("../.git/config");
        if path.exists() {
            assert!(sniff_is_text(path));
            let info = inspect_file(path.to_str().unwrap()).unwrap();
            assert_eq!(info.category, "text");
            assert_eq!(info.mime_type, "text/plain");
        }
    }

    #[test]
    fn test_sniff_text_variants() {
        let cases: Vec<(&str, Vec<u8>)> = vec![
            ("empty", Vec::new()),
            ("plain", b"KEY=value\nOTHER=1\n".to_vec()),
            ("utf8_bom", [b"\xEF\xBB\xBF".as_slice(), b"hello"].concat()),
            ("utf16le_bom", [b"\xFF\xFE".as_slice(), b"h\0i\0".as_slice()].concat()),
            ("cp1251", // invalid UTF-8, but no NUL / few controls → legacy text
             [0xCF, 0xF0, 0xE8, 0xE2, 0xE5, 0xF2, 0x0D, 0x0A].to_vec()),
        ];
        for (tag, bytes) in cases {
            let p = temp_file(tag, &bytes);
            assert!(sniff_is_text(&p), "expected TEXT for case '{}'", tag);
            std::fs::remove_file(&p).ok();
        }
    }

    #[test]
    fn test_sniff_binary_variants() {
        let mut zip_like = b"PK\x03\x04".to_vec();
        zip_like.extend(std::iter::repeat(0u8).take(64)); // deflate stream full of NULs
        let mut exe_like = b"MZ".to_vec();
        exe_like.extend(std::iter::repeat(0u8).take(64));
        let mut random_binary = Vec::new();
        for i in 0..256u16 {
            random_binary.push((i * 7 % 256) as u8); // ~25% control chars, no BOM
        }
        let cases: Vec<(&str, Vec<u8>)> = vec![
            ("zip", zip_like),
            ("exe", exe_like),
            ("random", random_binary),
            ("controls_no_nul", vec![0x01u8; 100]), // dense control chars, no NUL
        ];
        for (tag, bytes) in cases {
            let p = temp_file(tag, &bytes);
            assert!(!sniff_is_text(&p), "expected BINARY for case '{}'", tag);
            std::fs::remove_file(&p).ok();
        }
    }

    #[test]
    fn test_inspect_category_for_extensionless_text() {
        // "config" with no extension inside a temp dir (like .git/config).
        let dir = std::env::temp_dir().join(format!("peekit_test_dir_{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let cfg = dir.join("config");
        std::fs::write(&cfg, b"[core]\n\trepositoryformatversion = 0\n").unwrap();

        let info = inspect_file(cfg.to_str().unwrap()).unwrap();
        assert_eq!(info.category, "text");

        // Binary lookalike ("index" like .git/index) must stay generic.
        let idx = dir.join("index");
        let mut bin = b"DIRC".to_vec();
        bin.extend(std::iter::repeat(0u8).take(64));
        std::fs::write(&idx, &bin).unwrap();
        let info = inspect_file(idx.to_str().unwrap()).unwrap();
        assert_eq!(info.category, "generic");

        std::fs::remove_dir_all(&dir).ok();
    }

    #[test]
    fn test_read_text_utf16le_bom() {
        let mut bytes = b"\xFF\xFE".to_vec();
        for unit in "hello = world".encode_utf16() {
            bytes.extend_from_slice(&unit.to_le_bytes());
        }
        let p = temp_file("utf16read", &bytes);
        let text = read_file_text_capped(p.to_str().unwrap(), 1024 * 1024).unwrap();
        assert_eq!(text, "hello = world");
        std::fs::remove_file(&p).ok();
    }
}
