export type FileCategory =
  | 'image'
  | 'video'
  | 'audio'
  | 'pdf'
  | 'code'
  | 'markdown'
  | 'archive'
  | 'text'
  | 'generic';

export interface ArchiveEntry {
  name: string;
  fullPath: string;
  sizeBytes: number;
  compressedSizeBytes: number;
  isDirectory: boolean;
}

export interface FileDimensions {
  width: number;
  height: number;
}

export interface FileExtraInfo {
  dimensions?: FileDimensions;
  durationSeconds?: number;
  lineCount?: number;
  archiveEntries?: ArchiveEntry[];
  isCloudPlaceholder?: boolean;
}

export interface FilePreviewInfo {
  path: string;
  fileName: string;
  extension: string;
  sizeBytes: number;
  sizeFormatted: string;
  modified: string;
  category: FileCategory;
  mimeType: string;
  extra?: FileExtraInfo;
}

export type AppTheme = 'dark' | 'light' | 'system';
export type AppLanguage = 'ru' | 'en';

export interface AppSettings {
  language: AppLanguage;
  theme: AppTheme;
  autostart: boolean;
  closeOnFocusLoss: boolean;
  autoplayMedia: boolean;
  volume: number;
  stayOnTop: boolean;
  disabledPlugins?: string[];
}

export interface PluginManifest {
  id: string;
  name: string;
  version: string;
  author?: string;
  description?: string;
  extensions: string[];
  entry: string;
  minPeekitVersion?: string;
  permissions?: string[];
}

export interface PluginInfo {
  manifest: PluginManifest;
  rootPath: string;
  isEnabled: boolean;
}

export interface RegistryPlugin {
  id: string;
  name: string;
  version: string;
  author?: string;
  description?: string;
  category?: string;
  extensions: string[];
  entry?: string;
  min_peekit_version?: string;
  download_url: string;
  github_release_url?: string;
  size_kb?: string | number;
  sha256?: string;
  icon?: string;
  homepage?: string;
}

