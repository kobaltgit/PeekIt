import { invoke } from '@tauri-apps/api/core';
import type { PluginInfo } from '$lib/types';

class PluginRegistry {
  plugins = $state<PluginInfo[]>([]);
  isLoading = $state(false);
  error = $state<string | null>(null);

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

  async uninstallPlugin(id: string) {
    try {
      await invoke('uninstall_plugin', { id });
      await this.loadPlugins();
    } catch (e: any) {
      console.error('[PluginRegistry] Failed to uninstall plugin:', e);
      throw e;
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
    const timestamp = Date.now();
    const urls = [
      `https://kobaltgit.github.io/peekit-plugins/registry.json?t=${timestamp}`,
      `https://raw.githubusercontent.com/kobaltgit/peekit-plugins/main/registry.json?t=${timestamp}`
    ];

    for (const u of urls) {
      try {
        const resp = await fetch(u, { cache: 'no-cache' });
        if (resp.ok) {
          const contentType = resp.headers.get('content-type') || '';
          if (contentType.includes('text/html')) {
            continue; // Not JSON (e.g. 404 page)
          }
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

  async installPluginFromUrl(downloadUrl: string, expectedSha256?: string, fallbackUrls: string[] = []): Promise<PluginInfo> {
    const candidateUrls = [downloadUrl, ...fallbackUrls].filter(Boolean);
    let lastError: any = null;
    let lastMismatchDetails = '';

    for (const url of candidateUrls) {
      try {
        const response = await fetch(`${url}${url.includes('?') ? '&' : '?'}t=${Date.now()}`);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }

        const contentType = response.headers.get('content-type') || '';
        if (contentType.includes('text/html')) {
          throw new Error('Файл не найден (404)');
        }

        const arrayBuffer = await response.arrayBuffer();
        if (arrayBuffer.byteLength < 50) {
          throw new Error('Некорректный размер пакета');
        }

        // Verify SHA-256
        if (expectedSha256) {
          const hashBuffer = await crypto.subtle.digest('SHA-256', arrayBuffer);
          const hashArray = Array.from(new Uint8Array(hashBuffer));
          const computedSha = hashArray.map(b => b.toString(16).padStart(2, '0')).join('').toLowerCase();
          const targetSha = expectedSha256.trim().toLowerCase();

          if (computedSha !== targetSha) {
            lastMismatchDetails = `Ожидалось: ${targetSha.slice(0, 10)}..., получено: ${computedSha.slice(0, 10)}...`;
            console.warn(`[PluginRegistry] SHA-256 mismatch for ${url}:`, { targetSha, computedSha });
            continue; // Try next candidate URL
          }
        }

        // Verified! Install bytes
        const bytes = Array.from(new Uint8Array(arrayBuffer));
        const installed = await invoke<PluginInfo>('install_plugin_bytes', { bytes });
        await this.loadPlugins();
        return installed;
      } catch (err: any) {
        lastError = err;
        console.warn(`[PluginRegistry] Failed download from ${url}:`, err);
      }
    }

    if (lastMismatchDetails) {
      throw new Error(`Контрольная сумма SHA-256 не совпадает! (${lastMismatchDetails})`);
    }
    throw new Error(lastError?.message || 'Не удалось загрузить пакет плагина');
  }
}

export const pluginRegistry = new PluginRegistry();
