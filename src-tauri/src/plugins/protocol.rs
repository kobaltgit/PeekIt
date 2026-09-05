use std::borrow::Cow;
use std::fs;
use tauri::http::{header, Response, StatusCode};
use crate::plugins::scanner::find_plugin_dir;

fn error_response(status: StatusCode, msg: &'static [u8]) -> Response<Cow<'static, [u8]>> {
    Response::builder()
        .status(status)
        .header(header::CONTENT_TYPE, "text/plain")
        .header(header::ACCESS_CONTROL_ALLOW_ORIGIN, "*")
        .body(Cow::Borrowed(msg))
        .unwrap_or_else(|_| {
            Response::builder()
                .status(StatusCode::INTERNAL_SERVER_ERROR)
                .body(Cow::Borrowed(&[][..]))
                .unwrap()
        })
}

/// Handles requests to the custom `plugin-asset://` URI scheme.
/// Formats supported:
/// - plugin-asset://<plugin-id>/<relative-path>
/// - plugin-asset://localhost/<plugin-id>/<relative-path>
pub fn handle_plugin_asset_request(
    request: &tauri::http::Request<Vec<u8>>,
) -> Response<Cow<'static, [u8]>> {
    let uri = request.uri();
    let host = uri.host().unwrap_or("");
    let raw_path = uri.path();

    // Determine plugin_id and relative_path
    let (plugin_id, rel_path) = if !host.is_empty()
        && host != "localhost"
        && !host.ends_with(".localhost")
    {
        (host, raw_path.trim_start_matches('/'))
    } else {
        let trimmed = raw_path.trim_start_matches('/');
        if let Some((id, rest)) = trimmed.split_once('/') {
            (id, rest)
        } else {
            (trimmed, "index.html")
        }
    };

    if plugin_id.is_empty() || plugin_id.contains("..") || plugin_id.contains('\\') || plugin_id.contains('/') {
        return error_response(StatusCode::BAD_REQUEST, b"Invalid plugin ID");
    }

    // Locate the plugin directory on disk
    let plugin_root = match find_plugin_dir(plugin_id) {
        Some(dir) => dir,
        None => {
            crate::log_debug(&format!("[PluginProtocol] Plugin '{}' not found", plugin_id));
            return error_response(StatusCode::NOT_FOUND, b"Plugin not found");
        }
    };

    let canon_root = match plugin_root.canonicalize() {
        Ok(c) => c,
        Err(e) => {
            crate::log_debug(&format!("[PluginProtocol] Canonicalize error for {:?}: {}", plugin_root, e));
            return error_response(StatusCode::INTERNAL_SERVER_ERROR, b"Internal directory error");
        }
    };

    // Percent-decode the relative path (handling %20, etc.)
    let decoded_path = percent_decode(rel_path);
    let clean_rel_path = if decoded_path.is_empty() { "index.html" } else { &decoded_path };

    // Resolve target path and verify Path Traversal protection
    let target_path = canon_root.join(clean_rel_path);
    let canon_target = match target_path.canonicalize() {
        Ok(c) => c,
        Err(_) => {
            crate::log_debug(&format!("[PluginProtocol] File not found: {:?}", target_path));
            return error_response(StatusCode::NOT_FOUND, b"Asset not found");
        }
    };

    // STRICT CHECK: target must be inside canon_root
    if !canon_target.starts_with(&canon_root) {
        crate::log_debug(&format!(
            "[PluginProtocol] PATH TRAVERSAL BLOCKED! Attempt to access '{:?}' outside '{:?}'",
            canon_target, canon_root
        ));
        return error_response(StatusCode::FORBIDDEN, b"Forbidden: Path traversal detected");
    }

    if !canon_target.is_file() {
        return error_response(StatusCode::NOT_FOUND, b"Not a file");
    }

    // Read the file content
    let content = match fs::read(&canon_target) {
        Ok(bytes) => bytes,
        Err(e) => {
            crate::log_debug(&format!("[PluginProtocol] Read error for {:?}: {}", canon_target, e));
            return error_response(StatusCode::INTERNAL_SERVER_ERROR, b"Failed to read file");
        }
    };

    // Guess MIME type
    let mime_type = mime_guess::from_path(&canon_target)
        .first_or_octet_stream()
        .to_string();

    Response::builder()
        .status(StatusCode::OK)
        .header(header::CONTENT_TYPE, mime_type)
        .header(header::ACCESS_CONTROL_ALLOW_ORIGIN, "*")
        .header("X-Content-Type-Options", "nosniff")
        .body(Cow::Owned(content))
        .unwrap_or_else(|_| error_response(StatusCode::INTERNAL_SERVER_ERROR, b"Failed to build response"))
}

/// Simple percent decoder for URI paths.
fn percent_decode(input: &str) -> String {
    let mut bytes = Vec::new();
    let mut chars = input.bytes();
    while let Some(b) = chars.next() {
        if b == b'%' {
            let h1 = chars.next();
            let h2 = chars.next();
            if let (Some(c1), Some(c2)) = (h1, h2) {
                let hex_str = [c1, c2];
                if let Ok(val) = std::str::from_utf8(&hex_str) {
                    if let Ok(byte_val) = u8::from_str_radix(val, 16) {
                        bytes.push(byte_val);
                        continue;
                    }
                }
                bytes.push(b'%');
                bytes.push(c1);
                bytes.push(c2);
            } else {
                bytes.push(b'%');
            }
        } else {
            bytes.push(b);
        }
    }
    String::from_utf8_lossy(&bytes).to_string()
}
