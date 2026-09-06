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

  async fetchOnlineCatalog(): Promise<import('$lib/types').RegistryPlugin[]> {
    const urls = [
      'https://kobaltgit.github.io/peekit-plugins/registry.json',
      'https://raw.githubusercontent.com/kobaltgit/peekit-plugins/main/registry.json'
    ];

    for (const u of urls) {
      try {
        const resp = await fetch(u, { cache: 'no-cache' });
        if (resp.ok) {
          const data = await resp.json();
          if (data && Array.isArray(data.plugins)) {
            return data.plugins;
          }
        }
      } catch (err) {
        console.warn(`[PluginRegistry] Failed to fetch catalog from ${u}:`, err);
      }
    }
    throw new Error('Каталог плагинов временно недоступен в сети');
  }

  async installPluginFromUrl(downloadUrl: string, expectedSha256?: string): Promise<PluginInfo> {
    const response = await fetch(downloadUrl);
    if (!response.ok) {
      throw new Error(`Ошибка загрузки: HTTP ${response.status}`);
    }
    const arrayBuffer = await response.arrayBuffer();

    if (expectedSha256) {
      const hashBuffer = await crypto.subtle.digest('SHA-256', arrayBuffer);
      const hashArray = Array.from(new Uint8Array(hashBuffer));
      const computedSha = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
      if (computedSha.toLowerCase() !== expectedSha256.toLowerCase()) {
        throw new Error(`Контрольная сумма SHA-256 не совпадает!`);
      }
    }

    const bytes = Array.from(new Uint8Array(arrayBuffer));
    const installed = await invoke<PluginInfo>('install_plugin_bytes', { bytes });
    await this.loadPlugins();
    return installed;
  }
}

export const pluginRegistry = new PluginRegistry();
