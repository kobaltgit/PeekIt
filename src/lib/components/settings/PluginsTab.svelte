<script lang="ts">
  import type { AppLanguage } from '$lib/types';
  import { t } from '$lib/i18n';
  import { pluginRegistry } from '$lib/stores/plugins.svelte';

  export let lang: AppLanguage = 'ru';

  function handleOpenFolder() {
    pluginRegistry.openPluginsFolder();
  }

  function handleRefresh() {
    pluginRegistry.loadPlugins();
  }
</script>

<div class="plugins-tab">
  <div class="tab-toolbar">
    <div class="toolbar-text">
      <div class="tab-desc">{t('plugins_desc', lang)}</div>
    </div>
    <div class="toolbar-actions">
      <button class="action-btn" on:click={handleOpenFolder} title={t('plugins_open_folder', lang)}>
        <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
        </svg>
        <span>{t('plugins_open_folder', lang)}</span>
      </button>

      <button class="action-btn icon-only" on:click={handleRefresh} title={t('plugins_refresh', lang)}>
        <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="23 4 23 10 17 10" />
          <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10" />
        </svg>
      </button>
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

            <label class="switch" title={plugin.isEnabled ? 'Отключить' : 'Включить'}>
              <input
                type="checkbox"
                checked={plugin.isEnabled}
                on:change={() => pluginRegistry.togglePlugin(plugin.manifest.id, !plugin.isEnabled)}
              />
              <span class="slider"></span>
            </label>
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

<style>
  .plugins-tab {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .tab-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding-bottom: 12px;
    border-bottom: 1px solid var(--border-color);
  }

  .tab-desc {
    font-size: 12px;
    color: var(--text-muted);
  }

  .toolbar-actions {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-shrink: 0;
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
    border-color: var(--accent);
    color: var(--accent);
  }

  .action-btn.icon-only {
    padding: 6px 8px;
  }

  .plugins-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
    max-height: 280px;
    overflow-y: auto;
    padding-right: 4px;
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
