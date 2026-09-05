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
}
