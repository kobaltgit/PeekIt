use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PluginManifest {
    pub id: String,
    pub name: String,
    pub version: String,
    #[serde(default)]
    pub author: Option<String>,
    #[serde(default)]
    pub description: Option<String>,
    pub extensions: Vec<String>,
    pub entry: String,
    #[serde(default)]
    pub min_peekit_version: Option<String>,
    #[serde(default)]
    pub permissions: Vec<String>,
}

impl PluginManifest {
    /// Validates the manifest fields and normalizes file extensions.
    pub fn validate_and_normalize(&mut self) -> Result<(), String> {
        if self.id.trim().is_empty() {
            return Err("Plugin 'id' cannot be empty".to_string());
        }
        if self.name.trim().is_empty() {
            return Err("Plugin 'name' cannot be empty".to_string());
        }
        if self.entry.trim().is_empty() {
            return Err("Plugin 'entry' cannot be empty".to_string());
        }
        // Entry must not contain path traversal characters
        if self.entry.contains("..") || self.entry.starts_with('/') || self.entry.starts_with('\\') {
            return Err(format!("Invalid entry point '{}': path traversal or absolute paths are not allowed", self.entry));
        }

        // Normalize extensions to lowercase with leading dot
        let mut normalized_exts = Vec::new();
        for ext in &self.extensions {
            let trimmed = ext.trim().to_lowercase();
            if !trimmed.is_empty() {
                let formatted = if trimmed.starts_with('.') {
                    trimmed
                } else {
                    format!(".{}", trimmed)
                };
                if !normalized_exts.contains(&formatted) {
                    normalized_exts.push(formatted);
                }
            }
        }
        self.extensions = normalized_exts;

        Ok(())
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PluginInfo {
    pub manifest: PluginManifest,
    pub root_path: String,
    pub is_enabled: bool,
}
