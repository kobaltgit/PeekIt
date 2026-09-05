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

#[derive(Debug, Serialize, Deserialize, Clone, Default)]
#[serde(rename_all = "camelCase")]
pub struct FileExtraInfo {
    pub dimensions: Option<FileDimensions>,
    pub duration_seconds: Option<f64>,
    pub line_count: Option<usize>,
    pub archive_entries: Option<Vec<ArchiveEntry>>,
    pub is_cloud_placeholder: Option<bool>,
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

pub fn inspect_file(path_str: &str) -> Result<FilePreviewInfo, String> {
    let path = Path::new(path_str);
    if !path.exists() {
        return Err("File does not exist".to_string());
    }

    let metadata = std::fs::metadata(path).map_err(|e| e.to_string())?;
    let size_bytes = metadata.len();
    let size_formatted = format_bytes(size_bytes);

    let file_name = path
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("Unknown")
        .to_string();

    let extension = path
        .extension()
        .and_then(|e| e.to_str())
        .unwrap_or("")
        .to_lowercase();

    let mut category = detect_category(&extension).to_string();
    let mime_type = mime_guess::from_path(path)
        .first_or_octet_stream()
        .to_string();

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

    String::from_utf8(buffer)
        .or_else(|e| Ok(String::from_utf8_lossy(e.as_bytes()).to_string()))
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
}
