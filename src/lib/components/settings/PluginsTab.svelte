<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import type { AppLanguage, RegistryPlugin } from '$lib/types';
  import { t } from '$lib/i18n';
  import { pluginRegistry } from '$lib/stores/plugins.svelte';
  import { open } from '@tauri-apps/plugin-dialog';

  export let lang: AppLanguage = 'ru';
  export let initialSubtab: 'installed' | 'store' = 'installed';

  let subtab: 'installed' | 'store' = initialSubtab;
  let prevInitialSubtab = initialSubtab;

  $: if (initialSubtab !== prevInitialSubtab) {
    prevInitialSubtab = initialSubtab;
    subtab = initialSubtab;
    if (subtab === 'store' && onlinePlugins.length === 0 && !isLoadingCatalog) {
      loadCatalog();
    }
  }

  let installMessage = '';
  let installError = '';
  let fileInput: HTMLInputElement;

  // Store state
  let onlinePlugins: RegistryPlugin[] = [];
  let isLoadingCatalog = false;
  let catalogError = '';
  let searchQuery = '';
  let selectedCategory = 'all';
  let installingPluginId: string | null = null;
  let confirmingUninstallId: string | null = null;

  async function loadCatalog() {
    isLoadingCatalog = true;
    catalogError = '';
    try {
      onlinePlugins = await pluginRegistry.fetchOnlineCatalog();
    } catch (e: any) {
      catalogError = e?.message || t('store_failed_load', lang);
    } finally {
      isLoadingCatalog = false;
    }
  }

  let pollInterval: any;
  let handleWindowFocus: () => void;

  onMount(() => {
    pluginRegistry.loadPlugins();
    if (subtab === 'store') {
      loadCatalog();
    }

    handleWindowFocus = () => {
      pluginRegistry.loadPlugins();
    };
    window.addEventListener('focus', handleWindowFocus);

    // Auto-sync polling every 1.5s while Plugins tab is open
    pollInterval = setInterval(() => {
      pluginRegistry.loadPlugins();
    }, 1500);
  });

  onDestroy(() => {
    if (typeof window !== 'undefined' && handleWindowFocus) {
      window.removeEventListener('focus', handleWindowFocus);
    }
    if (pollInterval) {
      clearInterval(pollInterval);
    }
  });

  function handleOpenFolder() {
    pluginRegistry.openPluginsFolder();
  }

  function handleRefresh() {
    pluginRegistry.loadPlugins();
    if (subtab === 'store') {
      loadCatalog();
    }
  }

  async function handleFileChange(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files[0]) {
      const file = input.files[0];
      const filePath = (file as any).path;
      if (filePath) {
        try {
          const info = await pluginRegistry.installPluginPackage(filePath);
          installMessage = `${t('plugins_installed_success', lang)} (${info.manifest.name})`;
          setTimeout(() => { installMessage = ''; }, 4000);
        } catch (e: any) {
          installError = e?.toString() || 'Ошибка установки';
          setTimeout(() => { installError = ''; }, 5000);
        }
      }
    }
    input.value = '';
  }

  async function handleInstallPkit() {
    installMessage = '';
    installError = '';
    try {
      const selected = await open({
        multiple: false,
        filters: [{
          name: 'PeekIt Plugin (.pkit, .zip)',
          extensions: ['pkit', 'zip']
        }]
      });

      if (selected && typeof selected === 'string') {
        const info = await pluginRegistry.installPluginPackage(selected);
        installMessage = `${t('plugins_installed_success', lang)} (${info.manifest.name})`;
        setTimeout(() => { installMessage = ''; }, 4000);
      }
    } catch (e: any) {
      console.warn('Dialog plugin open failed, checking fallback:', e);
      if (fileInput) {
        fileInput.click();
      } else {
        installError = e?.toString() || 'Ошибка установки';
        setTimeout(() => { installError = ''; }, 5000);
      }
    }
  }

  async function handleInstallFromStore(plugin: RegistryPlugin) {
    installError = '';
    installMessage = '';
    installingPluginId = plugin.id;
    try {
      const fallbackUrls: string[] = [
        plugin.github_release_url,
        `https://raw.githubusercontent.com/kobaltgit/peekit-plugins/main/dist/${plugin.id}-${plugin.version}.pkit`
      ].filter((u): u is string => Boolean(u));

      const info = await pluginRegistry.installPluginFromUrl(plugin.download_url, plugin.sha256, fallbackUrls);
      installMessage = `${t('plugins_installed_success', lang)} (${info.manifest.name})`;
      setTimeout(() => { installMessage = ''; }, 4000);
    } catch (e: any) {
      installError = e?.message || e?.toString() || 'Ошибка установки';
      setTimeout(() => { installError = ''; }, 6000);
    } finally {
      installingPluginId = null;
    }
  }

  async function handleUninstallPlugin(id: string, name: string) {
    try {
      await pluginRegistry.uninstallPlugin(id);
      confirmingUninstallId = null;
      installMessage = lang === 'ru' ? `Плагин «${name}» удален` : `Plugin "${name}" uninstalled`;
      setTimeout(() => { installMessage = ''; }, 4000);
    } catch (e: any) {
      installError = e?.message || e?.toString() || 'Ошибка удаления плагина';
      setTimeout(() => { installError = ''; }, 5000);
    }
  }

  function getPluginStatus(plugin: RegistryPlugin) {
    const installed = pluginRegistry.plugins.find(p => p.manifest.id === plugin.id);
    if (!installed) {
      return { isInstalled: false, hasUpdate: false, installedVersion: null };
    }
    const hasUpdate = installed.manifest.version !== plugin.version;
    return { isInstalled: true, hasUpdate, installedVersion: installed.manifest.version };
  }

  const categories = [
    { id: 'all', labelRu: 'Все', labelEn: 'All' },
    { id: 'graphics', labelRu: 'Графика', labelEn: 'Graphics' },
    { id: '3d', labelRu: '3D', labelEn: '3D' },
    { id: 'document', labelRu: 'Документы', labelEn: 'Documents' },
    { id: 'font', labelRu: 'Шрифты', labelEn: 'Fonts' },
    { id: 'spreadsheet', labelRu: 'Таблицы', labelEn: 'Sheets' },
  ];

  function getEffectiveCategory(plugin: RegistryPlugin): string {
    if (plugin.category) return plugin.category.toLowerCase();
    const exts = (plugin.extensions || []).map(e => e.toLowerCase());
    const id = (plugin.id || '').toLowerCase();

    if (exts.some(e => ['.stl', '.obj', '.gltf', '.glb', '.ply', '.3d'].includes(e)) || id.includes('3d')) {
      return '3d';
    }
    if (exts.some(e => ['.psd', '.psb', '.ai', '.eps', '.svg'].includes(e)) || id.includes('psd') || id.includes('ai') || id.includes('eps')) {
      return 'graphics';
    }
    if (exts.some(e => ['.ttf', '.otf', '.woff', '.woff2'].includes(e)) || id.includes('font')) {
      return 'font';
    }
    if (exts.some(e => ['.xlsx', '.xls', '.csv', '.tsv', '.ods'].includes(e)) || id.includes('sheet')) {
      return 'spreadsheet';
    }
    if (exts.some(e => ['.pptx', '.ppt', '.docx', '.doc', '.epub', '.fb2', '.pdf'].includes(e)) || id.includes('docx') || id.includes('ebook') || id.includes('slides')) {
      return 'document';
    }
    return 'other';
  }

  function getCategoryLabel(category: string, currentLang: AppLanguage): string {
    switch (category) {
      case 'graphics':
        return currentLang === 'ru' ? 'ГРАФИКА' : 'GRAPHICS';
      case '3d':
        return '3D';
      case 'document':
        return currentLang === 'ru' ? 'ДОКУМЕНТЫ' : 'DOCS';
      case 'font':
        return currentLang === 'ru' ? 'ШРИФТЫ' : 'FONTS';
      case 'spreadsheet':
        return currentLang === 'ru' ? 'ТАБЛИЦЫ' : 'SHEETS';
      default:
        return currentLang === 'ru' ? 'ПЛАГИН' : 'PLUGIN';
    }
  }

  $: filteredCatalog = onlinePlugins.filter(plugin => {
    const effectiveCat = getEffectiveCategory(plugin);
    // Category match
    if (selectedCategory !== 'all') {
      if (effectiveCat !== selectedCategory) {
        return false;
      }
    }
    // Search query match
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim();
      const inName = plugin.name.toLowerCase().includes(q);
      const inDesc = (plugin.description || '').toLowerCase().includes(q);
      const inAuthor = (plugin.author || '').toLowerCase().includes(q);
      const inExts = plugin.extensions.some(ext => ext.toLowerCase().includes(q));
      if (!inName && !inDesc && !inAuthor && !inExts) {
        return false;
      }
    }
    return true;
  });

  function getCategoryColor(category?: string): { bg: string; text: string; border: string } {
    switch ((category || '').toLowerCase()) {
      case 'graphics':
        return { bg: 'rgba(249, 115, 22, 0.12)', text: '#f97316', border: 'rgba(249, 115, 22, 0.25)' };
      case '3d':
        return { bg: 'rgba(6, 182, 212, 0.12)', text: '#06b6d4', border: 'rgba(6, 182, 212, 0.25)' };
      case 'document':
        return { bg: 'rgba(59, 130, 246, 0.12)', text: '#3b82f6', border: 'rgba(59, 130, 246, 0.25)' };
      case 'font':
        return { bg: 'rgba(168, 85, 247, 0.12)', text: '#a855f7', border: 'rgba(168, 85, 247, 0.25)' };
      case 'spreadsheet':
        return { bg: 'rgba(16, 185, 129, 0.12)', text: '#10b981', border: 'rgba(16, 185, 129, 0.25)' };
      default:
        return { bg: 'rgba(100, 116, 139, 0.12)', text: 'var(--text-muted)', border: 'rgba(100, 116, 139, 0.25)' };
    }
  }
</script>

<input
  bind:this={fileInput}
  type="file"
  accept=".pkit,.zip"
  style="display: none;"
  on:change={handleFileChange}
/>

<div class="plugins-tab">
  <!-- Subtab Switcher -->
  <div class="subtabs-bar">
    <button
      class="subtab-btn {subtab === 'installed' ? 'active' : ''}"
      on:click={() => (subtab = 'installed')}
    >
      <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
        <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
        <line x1="12" y1="22.08" x2="12" y2="12" />
      </svg>
      <span>{t('plugins_subtab_installed', lang)}</span>
      <span class="badge-num">{pluginRegistry.plugins.length}</span>
    </button>

    <button
      class="subtab-btn {subtab === 'store' ? 'active' : ''}"
      on:click={() => {
        subtab = 'store';
        if (onlinePlugins.length === 0 && !isLoadingCatalog) {
          loadCatalog();
        }
      }}
    >
      <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="9" cy="21" r="1" />
        <circle cx="20" cy="21" r="1" />
        <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
      </svg>
      <span>{t('plugins_subtab_store', lang)}</span>
      {#if onlinePlugins.length > 0}
        <span class="badge-num store-badge">{onlinePlugins.length}</span>
      {/if}
    </button>
  </div>

  {#if installMessage}
    <div class="status-banner success">{installMessage}</div>
  {/if}
  {#if installError}
    <div class="status-banner error">{installError}</div>
  {/if}

  <!-- INSTALLED SUBTAB -->
  {#if subtab === 'installed'}
    <div class="installed-view">
      <div class="tab-toolbar">
        <div class="tab-desc">{t('plugins_desc', lang)}</div>

        <div class="toolbar-actions">
          <button class="action-btn primary full-width" on:click={handleInstallPkit} title={t('plugins_install_btn', lang)}>
            <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            <span>{t('plugins_install_btn', lang)}</span>
          </button>

          <div class="sub-actions">
            <button class="action-btn folder-btn" on:click={handleOpenFolder} title={t('plugins_open_folder', lang)}>
              <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
              </svg>
              <span>{t('plugins_open_folder', lang)}</span>
            </button>

            <button class="action-btn refresh-btn" on:click={handleRefresh} title={t('plugins_refresh', lang)}>
              <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="23 4 23 10 17 10" />
                <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10" />
              </svg>
              <span>{lang === 'ru' ? 'Обновить' : 'Refresh'}</span>
            </button>
          </div>
        </div>
      </div>

      <div class="plugins-list">
        {#if pluginRegistry.isLoading}
          <div class="plugins-loading">
            <div class="spinner"></div>
          </div>
        {:else if pluginRegistry.plugins.length === 0}
          <div class="plugins-empty">
            <div class="empty-icon">🧩</div>
            <p>{t('plugins_empty', lang)}</p>
            <button class="action-btn primary" on:click={() => { subtab = 'store'; loadCatalog(); }}>
              <span>{t('plugins_subtab_store', lang)}</span>
            </button>
          </div>
        {:else}
          {#each pluginRegistry.plugins as plugin (plugin.manifest.id)}
            <div class="plugin-card {plugin.isEnabled ? '' : 'disabled'}">
              <div class="plugin-header">
                <div class="plugin-info">
                  <div class="plugin-title-row">
                    <span class="plugin-name">{plugin.manifest.name}</span>
                    <span class="plugin-version">v{plugin.manifest.version}</span>
                    {#if plugin.manifest.author}
                      <span class="plugin-author">@{plugin.manifest.author}</span>
                    {/if}
                  </div>
                  {#if plugin.manifest.description}
                    <div class="plugin-desc">{plugin.manifest.description}</div>
                  {/if}
                </div>

                <div class="plugin-card-actions">
                  {#if confirmingUninstallId === plugin.manifest.id}
                    <div class="uninstall-confirm-box">
                      <button
                        class="btn-confirm-delete"
                        on:click={() => handleUninstallPlugin(plugin.manifest.id, plugin.manifest.name)}
                        title={lang === 'ru' ? 'Подтвердить удаление' : 'Confirm delete'}
                      >
                        {lang === 'ru' ? 'Удалить?' : 'Delete?'}
                      </button>
                      <button
                        class="btn-cancel-delete"
                        on:click={() => (confirmingUninstallId = null)}
                        title={lang === 'ru' ? 'Отмена' : 'Cancel'}
                      >
                        &times;
                      </button>
                    </div>
                  {:else}
                    <button
                      class="btn-uninstall-plugin"
                      on:click={() => (confirmingUninstallId = plugin.manifest.id)}
                      title={lang === 'ru' ? 'Удалить плагин' : 'Uninstall plugin'}
                    >
                      <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="3 6 5 6 21 6" />
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                      </svg>
                    </button>
                  {/if}

                  <label class="switch" title={plugin.isEnabled ? (lang === 'ru' ? 'Отключить' : 'Disable') : (lang === 'ru' ? 'Включить' : 'Enable')}>
                    <input
                      type="checkbox"
                      checked={plugin.isEnabled}
                      on:change={() => pluginRegistry.togglePlugin(plugin.manifest.id, !plugin.isEnabled)}
                    />
                    <span class="slider"></span>
                  </label>
                </div>
              </div>

              <div class="plugin-footer">
                <span class="ext-label">{t('plugins_extensions', lang)}:</span>
                <div class="ext-chips">
                  {#each plugin.manifest.extensions as ext}
                    <span class="ext-chip">{ext}</span>
                  {/each}
                </div>
              </div>
            </div>
          {/each}
        {/if}
      </div>
    </div>

  <!-- STORE SUBTAB -->
  {:else if subtab === 'store'}
    <div class="store-view">
      <!-- Search & Filters -->
      <div class="store-header">
        <div class="search-box">
          <svg class="search-icon" viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>
          <input
            type="text"
            placeholder={t('store_search_placeholder', lang)}
            bind:value={searchQuery}
            class="search-input"
          />
          {#if searchQuery}
            <button class="clear-search-btn" on:click={() => (searchQuery = '')}>&times;</button>
          {/if}
          <button class="action-btn refresh-btn icon-only" on:click={loadCatalog} title={t('plugins_refresh', lang)}>
            <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="23 4 23 10 17 10" />
              <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10" />
            </svg>
          </button>
        </div>

        <div class="category-pills">
          {#each categories as cat}
            <button
              class="cat-pill {selectedCategory === cat.id ? 'active' : ''}"
              on:click={() => (selectedCategory = cat.id)}
            >
              {lang === 'ru' ? cat.labelRu : cat.labelEn}
            </button>
          {/each}
        </div>
      </div>

      <!-- Catalog List -->
      <div class="store-list">
        {#if isLoadingCatalog}
          <div class="plugins-loading">
            <div class="spinner"></div>
          </div>
        {:else if catalogError}
          <div class="store-error-state">
            <svg viewBox="0 0 24 24" width="32" height="32" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10" />
              <line x1="12" y1="8" x2="12" y2="12" />
              <line x1="12" y1="16" x2="12.01" y2="16" />
            </svg>
            <p>{catalogError}</p>
            <button class="action-btn primary" on:click={loadCatalog}>
              <span>{lang === 'ru' ? 'Повторить попытку' : 'Retry'}</span>
            </button>
          </div>
        {:else if filteredCatalog.length === 0}
          <div class="plugins-empty">
            <div class="empty-icon">🔍</div>
            <p>{t('store_empty', lang)}</p>
          </div>
        {:else}
          <div class="catalog-grid">
            {#each filteredCatalog as item (item.id)}
              {@const status = getPluginStatus(item)}
              {@const effectiveCat = getEffectiveCategory(item)}
              {@const catStyle = getCategoryColor(effectiveCat)}
              <div class="catalog-card">
                <div class="card-main-row">
                  <!-- Category Icon Box -->
                  <div
                    class="card-icon-box"
                    style="background: {catStyle.bg}; color: {catStyle.text}; border-color: {catStyle.border};"
                  >
                    {#if effectiveCat === '3d'}
                      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
                        <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
                        <line x1="12" y1="22.08" x2="12" y2="12" />
                      </svg>
                    {:else if effectiveCat === 'graphics'}
                      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
                        <polygon points="12 2 2 7 12 12 22 7 12 2" />
                        <polyline points="2 17 12 22 22 17" />
                        <polyline points="2 12 12 17 22 12" />
                      </svg>
                    {:else if effectiveCat === 'font'}
                      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="4 7 4 4 20 4 20 7" />
                        <line x1="9" y1="20" x2="15" y2="20" />
                        <line x1="12" y1="4" x2="12" y2="20" />
                      </svg>
                    {:else if effectiveCat === 'spreadsheet'}
                      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="3" width="18" height="18" rx="2" />
                        <line x1="3" y1="9" x2="21" y2="9" />
                        <line x1="3" y1="15" x2="21" y2="15" />
                        <line x1="9" y1="3" x2="9" y2="21" />
                        <line x1="15" y1="3" x2="15" y2="21" />
                      </svg>
                    {:else}
                      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                        <polyline points="14 2 14 8 20 8" />
                        <line x1="16" y1="13" x2="8" y2="13" />
                        <line x1="16" y1="17" x2="8" y2="17" />
                      </svg>
                    {/if}
                  </div>

                  <!-- Details -->
                  <div class="card-details">
                    <div class="card-title-row">
                      <span class="card-name">{item.name}</span>
                      <div class="card-badges">
                        <span
                          class="card-cat-badge"
                          style="background: {catStyle.bg}; color: {catStyle.text}; border-color: {catStyle.border};"
                        >
                          {getCategoryLabel(effectiveCat, lang)}
                        </span>
                        <span class="card-ver-badge">v{item.version}</span>
                      </div>
                    </div>

                    {#if item.author}
                      <div class="card-author">@{item.author}</div>
                    {/if}

                    {#if item.description}
                      <div class="card-desc">{item.description}</div>
                    {/if}
                  </div>
                </div>

                <!-- Footer with Extensions and Action Button -->
                <div class="card-footer-row">
                  <div class="card-meta">
                    <div class="ext-chips">
                      {#each item.extensions as ext}
                        <span class="ext-chip">{ext}</span>
                      {/each}
                    </div>
                    {#if item.size_kb}
                      <span class="size-text">{item.size_kb} KB</span>
                    {/if}
                  </div>

                  <div class="card-action">
                    {#if installingPluginId === item.id}
                      <button class="store-btn loading" disabled>
                        <div class="mini-spinner"></div>
                        <span>{t('store_installing', lang)}</span>
                      </button>
                    {:else if status.isInstalled && !status.hasUpdate}
                      <button class="store-btn installed" disabled>
                        <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5">
                          <polyline points="20 6 9 17 4 12" />
                        </svg>
                        <span>{t('store_installed', lang)}</span>
                      </button>
                    {:else if status.hasUpdate}
                      <button class="store-btn update" on:click={() => handleInstallFromStore(item)}>
                        <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2">
                          <polyline points="23 4 23 10 17 10" />
                          <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10" />
                        </svg>
                        <span>{t('store_update', lang)}</span>
                      </button>
                    {:else}
                      <button class="store-btn install" on:click={() => handleInstallFromStore(item)}>
                        <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2">
                          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                          <polyline points="7 10 12 15 17 10" />
                          <line x1="12" y1="15" x2="12" y2="3" />
                        </svg>
                        <span>{t('store_install', lang)}</span>
                      </button>
                    {/if}
                  </div>
                </div>
              </div>
            {/each}
          </div>
        {/if}
      </div>
    </div>
  {/if}
</div>

<style>
  .plugins-tab {
    display: flex;
    flex-direction: column;
    gap: 14px;
  }

  /* Subtabs Bar */
  .subtabs-bar {
    display: flex;
    gap: 6px;
    background: var(--bg-card);
    padding: 4px;
    border-radius: 8px;
    border: 1px solid var(--border-color);
  }

  .subtab-btn {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    padding: 6px 12px;
    background: transparent;
    border: none;
    border-radius: 6px;
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.15s ease;
  }

  .subtab-btn:hover {
    color: var(--text-main);
    background: var(--bg-hover);
  }

  .subtab-btn.active {
    background: var(--bg-subtle);
    color: var(--text-main);
    font-weight: 600;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .badge-num {
    font-size: 10px;
    font-weight: 600;
    padding: 1px 6px;
    border-radius: 10px;
    background: var(--bg-hover);
    color: var(--text-muted);
  }

  .subtab-btn.active .badge-num {
    background: rgba(59, 130, 246, 0.15);
    color: var(--accent);
  }

  .store-badge {
    background: rgba(16, 185, 129, 0.15) !important;
    color: #10b981 !important;
  }

  /* Toolbar */
  .tab-toolbar {
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding-bottom: 12px;
    border-bottom: 1px solid var(--border-color);
  }

  .tab-desc {
    font-size: 12px;
    color: var(--text-muted);
    line-height: 1.4;
  }

  .toolbar-actions {
    display: flex;
    flex-direction: column;
    gap: 8px;
    width: 100%;
  }

  .sub-actions {
    display: flex;
    gap: 8px;
    width: 100%;
  }

  .action-btn.full-width {
    width: 100%;
    justify-content: center;
    padding: 8px 14px;
    font-size: 13px;
  }

  .action-btn.folder-btn {
    flex: 1;
    justify-content: center;
  }

  .action-btn.refresh-btn {
    justify-content: center;
    padding: 6px 12px;
  }

  .action-btn.icon-only {
    padding: 6px 8px;
  }

  .action-btn {
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    color: var(--text-main);
    padding: 6px 12px;
    border-radius: 6px;
    font-size: 12px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
    transition: all 0.15s ease;
  }

  .action-btn:hover {
    background: var(--bg-hover);
    border-color: var(--text-muted);
  }

  .action-btn.primary {
    background: var(--accent, #3b82f6);
    color: #ffffff;
    border-color: var(--accent, #3b82f6);
    font-weight: 500;
  }

  .action-btn.primary:hover {
    filter: brightness(1.1);
  }

  .status-banner {
    padding: 8px 12px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 500;
  }

  .status-banner.success {
    background: rgba(16, 185, 129, 0.15);
    border: 1px solid rgba(16, 185, 129, 0.3);
    color: #10b981;
  }

  .status-banner.error {
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid rgba(239, 68, 68, 0.3);
    color: #ef4444;
  }

  /* Installed List */
  .plugins-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
    max-height: 290px;
    overflow-y: auto;
    padding-right: 4px;
    margin-top: 10px;
  }

  .plugin-card {
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 12px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    transition: all 0.2s ease;
  }

  .plugin-card:hover {
    border-color: var(--border-hover);
  }

  .plugin-card.disabled {
    opacity: 0.6;
    filter: grayscale(0.4);
  }

  .plugin-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
  }

  .plugin-card-actions {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-shrink: 0;
  }

  .btn-uninstall-plugin {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 26px;
    height: 26px;
    background: transparent;
    border: 1px solid transparent;
    border-radius: 6px;
    color: var(--text-muted);
    cursor: pointer;
    transition: all 0.15s ease;
  }

  .btn-uninstall-plugin:hover {
    background: rgba(239, 68, 68, 0.12);
    border-color: rgba(239, 68, 68, 0.3);
    color: #ef4444;
  }

  .uninstall-confirm-box {
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .btn-confirm-delete {
    background: #ef4444;
    color: #ffffff;
    border: none;
    border-radius: 4px;
    padding: 3px 8px;
    font-size: 11px;
    font-weight: 600;
    cursor: pointer;
    transition: filter 0.15s ease;
  }

  .btn-confirm-delete:hover {
    filter: brightness(1.15);
  }

  .btn-cancel-delete {
    background: var(--bg-hover);
    color: var(--text-muted);
    border: 1px solid var(--border-color);
    border-radius: 4px;
    padding: 1px 6px;
    font-size: 13px;
    line-height: 1.2;
    cursor: pointer;
  }

  .btn-cancel-delete:hover {
    color: var(--text-main);
  }

  .plugin-info {
    display: flex;
    flex-direction: column;
    gap: 4px;
    min-width: 0;
  }

  .plugin-title-row {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
  }

  .plugin-name {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-main);
  }

  .plugin-version {
    font-size: 10px;
    background: rgba(59, 130, 246, 0.12);
    color: var(--accent);
    padding: 1px 6px;
    border-radius: 4px;
    font-family: 'JetBrains Mono', monospace;
    font-weight: 600;
  }

  .plugin-author {
    font-size: 11px;
    color: var(--text-muted);
  }

  .plugin-desc {
    font-size: 11px;
    color: var(--text-muted);
    line-height: 1.4;
  }

  .plugin-footer {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 4px;
  }

  .ext-label {
    font-size: 11px;
    color: var(--text-dim);
  }

  .ext-chips {
    display: flex;
    align-items: center;
    gap: 4px;
    flex-wrap: wrap;
  }

  .ext-chip {
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    font-size: 10px;
    font-family: 'JetBrains Mono', monospace;
    padding: 1px 5px;
    border-radius: 4px;
    color: var(--text-main);
  }

  /* STORE VIEW STYLES */
  .store-view {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .store-header {
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding-bottom: 8px;
    border-bottom: 1px solid var(--border-color);
  }

  .search-box {
    display: flex;
    align-items: center;
    gap: 6px;
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    border-radius: 6px;
    padding: 2px 6px 2px 10px;
  }

  .search-icon {
    color: var(--text-muted);
    flex-shrink: 0;
  }

  .search-input {
    flex: 1;
    background: transparent;
    border: none;
    outline: none;
    color: var(--text-main);
    font-size: 12px;
    padding: 4px 0;
  }

  .search-input::placeholder {
    color: var(--text-muted);
  }

  .clear-search-btn {
    background: transparent;
    border: none;
    color: var(--text-muted);
    font-size: 16px;
    cursor: pointer;
    padding: 0 4px;
  }

  .category-pills {
    display: flex;
    align-items: center;
    gap: 6px;
    overflow-x: auto;
    padding-bottom: 2px;
  }

  .cat-pill {
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    border-radius: 14px;
    padding: 3px 10px;
    font-size: 11px;
    color: var(--text-muted);
    cursor: pointer;
    white-space: nowrap;
    transition: all 0.15s ease;
  }

  .cat-pill:hover {
    color: var(--text-main);
    background: var(--bg-hover);
  }

  .cat-pill.active {
    background: var(--accent);
    color: #ffffff;
    border-color: var(--accent);
    font-weight: 500;
  }

  .store-list {
    max-height: 290px;
    overflow-y: auto;
    padding-right: 4px;
  }

  .catalog-grid {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .catalog-card {
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 12px;
    display: flex;
    flex-direction: column;
    gap: 10px;
    transition: all 0.2s ease;
  }

  .catalog-card:hover {
    border-color: var(--border-hover);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  }

  .card-main-row {
    display: flex;
    align-items: flex-start;
    gap: 12px;
  }

  .card-icon-box {
    width: 38px;
    height: 38px;
    border-radius: 8px;
    border: 1px solid transparent;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .card-details {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    gap: 3px;
  }

  .card-title-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
  }

  .card-name {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-main);
  }

  .card-badges {
    display: flex;
    align-items: center;
    gap: 5px;
  }

  .card-cat-badge {
    font-size: 9px;
    font-weight: 700;
    padding: 1px 5px;
    border-radius: 4px;
    border: 1px solid transparent;
    letter-spacing: 0.5px;
  }

  .card-ver-badge {
    font-size: 10px;
    background: rgba(59, 130, 246, 0.12);
    color: var(--accent);
    padding: 1px 5px;
    border-radius: 4px;
    font-family: 'JetBrains Mono', monospace;
    font-weight: 600;
  }

  .card-author {
    font-size: 11px;
    color: var(--text-muted);
  }

  .card-desc {
    font-size: 11px;
    color: var(--text-muted);
    line-height: 1.35;
    margin-top: 2px;
  }

  .card-footer-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    padding-top: 6px;
    border-top: 1px solid var(--border-color);
  }

  .card-meta {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
    min-width: 0;
  }

  .size-text {
    font-size: 10px;
    color: var(--text-dim);
  }

  .card-action {
    flex-shrink: 0;
  }

  .store-btn {
    display: flex;
    align-items: center;
    gap: 5px;
    padding: 5px 12px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.15s ease;
    border: 1px solid transparent;
  }

  .store-btn.install {
    background: var(--accent);
    color: #ffffff;
  }

  .store-btn.install:hover {
    filter: brightness(1.1);
  }

  .store-btn.update {
    background: #10b981;
    color: #ffffff;
  }

  .store-btn.update:hover {
    filter: brightness(1.1);
  }

  .store-btn.installed {
    background: var(--bg-card);
    border-color: var(--border-color);
    color: var(--text-muted);
    cursor: default;
    opacity: 0.85;
  }

  .store-btn.loading {
    background: var(--bg-hover);
    color: var(--text-muted);
    cursor: wait;
  }

  .mini-spinner {
    width: 12px;
    height: 12px;
    border: 2px solid var(--border-color);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }

  .store-error-state {
    padding: 30px 16px;
    text-align: center;
    color: #ef4444;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    font-size: 12px;
  }

  .plugins-empty {
    padding: 32px 16px;
    text-align: center;
    color: var(--text-muted);
    font-size: 12px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
  }

  .empty-icon {
    font-size: 32px;
  }

  .plugins-loading {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 30px;
  }

  .spinner {
    width: 24px;
    height: 24px;
    border: 2px solid var(--border-color);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  /* Switch Toggle */
  .switch {
    position: relative;
    display: inline-block;
    width: 36px;
    height: 20px;
    flex-shrink: 0;
  }

  .switch input {
    opacity: 0;
    width: 0;
    height: 0;
  }

  .slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: var(--border-color);
    transition: 0.2s;
    border-radius: 20px;
  }

  .slider:before {
    position: absolute;
    content: "";
    height: 14px;
    width: 14px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: 0.2s;
    border-radius: 50%;
  }

  input:checked + .slider {
    background-color: var(--accent);
  }

  input:checked + .slider:before {
    transform: translateX(16px);
  }
</style>
