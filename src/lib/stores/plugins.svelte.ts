import { invoke } from '@tauri-apps/api/core';
import type { PluginInfo } from '$lib/types';

class PluginRegistry {
  plugins: PluginInfo[] = [];
  isLoading = false;
  error: string | null = null;

  async loadPlugins() {
    this.isLoading = true;
    this.error = null;
    try {
      const list = await invoke<PluginInfo[]>('get_installed_plugins');
      this.plugins = list || [];
    } catch (e: any) {
      this.error = e?.toString() || 'Failed to load plugins';
      console.error('[PluginRegistry] Failed to load plugins:', e);
    } finally {
      this.isLoading = false;
    }
  }

  findPluginForFile(extension: string): PluginInfo | undefined {
    let norm = (extension || '').trim().toLowerCase();
    if (!norm.startsWith('.')) norm = '.' + norm;
    return this.plugins.find(
      p => p.isEnabled && p.manifest.extensions.some(e => e.toLowerCase() === norm)
    );
  }

  async togglePlugin(id: string, enabled: boolean) {
    try {
      await invoke('set_plugin_enabled', { id, enabled });
      this.plugins = this.plugins.map(p =>
        p.manifest.id === id ? { ...p, isEnabled: enabled } : p
      );
    } catch (e: any) {
      console.error('[PluginRegistry] Failed to toggle plugin:', e);
    }
  }

  async openPluginsFolder() {
    try {
      await invoke('open_plugins_folder');
    } catch (e: any) {
      console.error('[PluginRegistry] Failed to open plugins folder:', e);
    }
  }

  async installPluginPackage(packagePath: string): Promise<PluginInfo> {
    const installed = await invoke<PluginInfo>('install_plugin', { packagePath });
    await this.loadPlugins();
    return installed;
  }
}

export const pluginRegistry = new PluginRegistry();
