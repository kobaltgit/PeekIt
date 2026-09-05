import type { AppLanguage, AppTheme } from '$lib/types';

export interface PeekitInitPayload {
  filePath: string;
  fileName: string;
  fileSize: number;
  sizeFormatted: string;
  extension: string;
  theme: AppTheme;
  language: AppLanguage;
}

export interface PeekitDataResponsePayload {
  data: ArrayBuffer | null;
  error?: string;
}

export interface PeekitResizePayload {
  width: number;
  height: number;
}

export type HostToPluginMessage =
  | { type: 'PEEKIT_INIT'; payload: PeekitInitPayload }
  | { type: 'PEEKIT_DATA_RESPONSE'; payload: PeekitDataResponsePayload }
  | { type: 'PEEKIT_THEME_CHANGED'; payload: { theme: AppTheme } };

export type PluginToHostMessage =
  | { type: 'PEEKIT_READY' }
  | { type: 'PEEKIT_REQUEST_DATA' }
  | { type: 'PEEKIT_RESIZE'; payload: PeekitResizePayload }
  | { type: 'PEEKIT_ERROR'; payload: { message: string } };

export const PEEKIT_MSG_SOURCE = 'peekit-host';
export const PEEKIT_PLUGIN_SOURCE = 'peekit-plugin';
