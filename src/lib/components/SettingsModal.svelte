<script lang="ts">
  import type { AppSettings, AppLanguage, AppTheme, UpdateCheckResult } from '../types';
  import { t } from '../i18n';
  import PluginsTab from './settings/PluginsTab.svelte';
  import { openUrl } from '@tauri-apps/plugin-opener';
  import { pluginRegistry } from '$lib/stores/plugins.svelte';
  import { invoke } from '@tauri-apps/api/core';
  import { listen } from '@tauri-apps/api/event';
  import { onMount, onDestroy } from 'svelte';

  export let settings: AppSettings;
  export let isOpen: boolean = false;
  export let initialTab: 'general' | 'appearance' | 'plugins' | 'about' = 'general';
  export let initialSubtab: 'installed' | 'store' = 'installed';
  export let onClose: () => void;
  export let onSave: (updated: AppSettings) => void;

  let localSettings: AppSettings = { ...settings };
  let activeTab: 'general' | 'appearance' | 'plugins' | 'about' = initialTab;

  let isCheckingUpdates = false;
  let updateResult: UpdateCheckResult | null = null;
  let updateError: string | null = null;
  let unlistenUpdate: (() => void) | null = null;

  let wasOpen = false;
  $: if (isOpen && !wasOpen) {
    localSettings = { ...settings };
    if (initialTab) {
      activeTab = initialTab;
    }
  }
  $: wasOpen = isOpen;

  $: if (isOpen && activeTab === 'plugins') {
    pluginRegistry.loadPlugins();
  }

  onMount(async () => {
    try {
      unlistenUpdate = await listen<UpdateCheckResult>('update-status', (event) => {
        updateResult = event.payload;
      });
    } catch (e) {
      console.warn('[Updater] Failed to attach listener', e);
    }
  });

  onDestroy(() => {
    if (unlistenUpdate) unlistenUpdate();
  });

  async function handleCheckUpdates(force: boolean = true) {
    if (isCheckingUpdates) return;
    isCheckingUpdates = true;
    updateError = null;
    try {
      updateResult = await invoke<UpdateCheckResult>('check_for_updates', { force });
    } catch (e: any) {
      updateError = String(e || t('update_error', localSettings.language));
    } finally {
      isCheckingUpdates = false;
    }
  }

  async function openLink(url: string) {
    try {
      await openUrl(url);
    } catch (e) {
      window.open(url, '_blank');
    }
  }

  function saveAndClose() {
    onSave({ ...localSettings });
    onClose();
  }
</script>

{#if isOpen}
  <div class="modal-backdrop" on:click={onClose} on:keydown={(e) => { if (e.key === 'Escape') onClose(); }} role="presentation">
    <div class="modal-dialog" on:click|stopPropagation on:keydown|stopPropagation role="dialog" aria-modal="true" tabindex="-1">
      <div class="modal-header">
        <div class="modal-title">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="3" />
            <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z" />
          </svg>
          <span>{t('settings_title', localSettings.language)}</span>
        </div>
        <button class="btn-close" on:click={onClose}>&times;</button>
      </div>

      <div class="tabs-bar">
        <button
          class="tab-link {activeTab === 'general' ? 'active' : ''}"
          on:click={() => (activeTab = 'general')}
        >
          {t('general_tab', localSettings.language)}
        </button>
        <button
          class="tab-link {activeTab === 'appearance' ? 'active' : ''}"
          on:click={() => (activeTab = 'appearance')}
        >
          {t('appearance_tab', localSettings.language)}
        </button>
        <button
          class="tab-link {activeTab === 'plugins' ? 'active' : ''}"
          on:click={() => (activeTab = 'plugins')}
        >
          {t('plugins_tab', localSettings.language)}
        </button>
        <button
          class="tab-link {activeTab === 'about' ? 'active' : ''}"
          on:click={() => (activeTab = 'about')}
        >
          <span>{t('about_tab', localSettings.language)}</span>
          {#if updateResult?.has_update}
            <span class="tab-badge-dot"></span>
          {/if}
        </button>
      </div>

      <div class="modal-body">
        {#if activeTab === 'general'}
          <div class="setting-item">
            <label class="setting-label" for="setting-language">{t('language', localSettings.language)}</label>
            <select id="setting-language" bind:value={localSettings.language} class="setting-select">
              <option value="ru">Русский (RU)</option>
              <option value="en">English (EN)</option>
            </select>
          </div>

          <div class="setting-item-check">
            <input type="checkbox" id="autostart" bind:checked={localSettings.autostart} />
            <label for="autostart">{t('autostart', localSettings.language)}</label>
          </div>

          <div class="setting-item-check">
            <input type="checkbox" id="closeBlur" bind:checked={localSettings.closeOnFocusLoss} />
            <label for="closeBlur">{t('close_on_blur', localSettings.language)}</label>
          </div>

          <div class="setting-item-check">
            <input type="checkbox" id="autoplay" bind:checked={localSettings.autoplayMedia} />
            <label for="autoplay">{t('autoplay_media', localSettings.language)}</label>
          </div>

          <div class="setting-item-check">
            <input type="checkbox" id="stayOnTop" bind:checked={localSettings.stayOnTop} />
            <label for="stayOnTop">{t('stay_on_top', localSettings.language)}</label>
          </div>

          <div class="hotkeys-box">
            <h4>{t('hotkeys_title', localSettings.language)}</h4>
            <ul>
              <li>{t('hotkey_space', localSettings.language)}</li>
              <li>{t('hotkey_esc', localSettings.language)}</li>
              <li>{t('hotkey_arrows', localSettings.language)}</li>
              <li>{t('hotkey_enter', localSettings.language)}</li>
            </ul>
          </div>
        {:else if activeTab === 'appearance'}
          <div class="setting-item">
            <span class="setting-label">{t('theme', localSettings.language)}</span>
            <div class="theme-picker" role="group" aria-label={t('theme', localSettings.language)}>
              <button
                class="theme-opt {localSettings.theme === 'dark' ? 'selected' : ''}"
                on:click={() => (localSettings.theme = 'dark')}
              >
                {t('theme_dark', localSettings.language)}
              </button>
              <button
                class="theme-opt {localSettings.theme === 'light' ? 'selected' : ''}"
                on:click={() => (localSettings.theme = 'light')}
              >
                {t('theme_light', localSettings.language)}
              </button>
              <button
                class="theme-opt {localSettings.theme === 'system' ? 'selected' : ''}"
                on:click={() => (localSettings.theme = 'system')}
              >
                {t('theme_system', localSettings.language)}
              </button>
            </div>
          </div>
        {:else if activeTab === 'plugins'}
          <PluginsTab lang={localSettings.language} initialSubtab={initialSubtab} />
        {:else if activeTab === 'about'}
          <div class="about-section">
            <h3>Peekit v1.3.1</h3>
            <p class="about-desc">{t('app_subtitle', localSettings.language)}</p>
            <p class="about-tech">Rust (Win32 COM) + Tauri v2 + Svelte 5</p>
            <p class="about-author">{t('author', localSettings.language)}</p>

            <!-- Updater Box -->
            <div class="updater-box">
              <div class="updater-header">
                <div class="updater-status">
                  {#if isCheckingUpdates}
                    <span class="status-dot pulse"></span>
                    <span class="status-msg">{t('checking_updates', localSettings.language)}</span>
                  {:else if updateResult?.has_update}
                    <span class="status-dot update-available"></span>
                    <span class="status-msg update-available-text">{t('updates_available', localSettings.language)}: v{updateResult.latest_version}</span>
                  {:else if updateResult && !updateResult.has_update}
                    <span class="status-dot up-to-date"></span>
                    <span class="status-msg up-to-date-text">{t('updates_latest', localSettings.language)}</span>
                  {:else}
                    <span class="status-dot idle"></span>
                    <span class="status-msg">{t('version', localSettings.language)} 1.3.1</span>
                  {/if}
                </div>

                <button 
                  class="btn-check-updates" 
                  on:click={() => handleCheckUpdates(true)} 
                  disabled={isCheckingUpdates}
                  title={t('check_updates', localSettings.language)}
                >
                  <svg class="{isCheckingUpdates ? 'spin-icon' : ''}" viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"/>
                  </svg>
                  <span>{t('check_updates', localSettings.language)}</span>
                </button>
              </div>

              {#if updateError}
                <div class="updater-error">{updateError}</div>
              {/if}

              {#if updateResult?.has_update}
                <div class="updater-card">
                  <div class="updater-card-header">
                    <span class="card-badge">v{updateResult.latest_version}</span>
                    <span class="card-title">{t('updates_available', localSettings.language)}</span>
                  </div>

                  <div class="updater-card-actions">
                    {#if updateResult.setup_url}
                      <button class="btn-update-download primary" on:click={() => openLink(updateResult!.setup_url!)}>
                        <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
                          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                          <polyline points="7 10 12 15 17 10" />
                          <line x1="12" y1="15" x2="12" y2="3" />
                        </svg>
                        <span>{t('download_setup', localSettings.language)}</span>
                      </button>
                    {/if}

                    {#if updateResult.portable_url}
                      <button class="btn-update-download secondary" on:click={() => openLink(updateResult!.portable_url!)}>
                        <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
                          <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
                        </svg>
                        <span>{t('download_portable', localSettings.language)}</span>
                      </button>
                    {/if}
                  </div>

                  {#if updateResult.release_url}
                    <button class="btn-release-notes" on:click={() => openLink(updateResult!.release_url)}>
                      {t('view_release_notes', localSettings.language)}
                    </button>
                  {/if}
                </div>
              {/if}

              <div class="updater-auto-row">
                <input type="checkbox" id="autoCheckUpdates" bind:checked={localSettings.auto_check_updates} />
                <label for="autoCheckUpdates">
                  <span class="auto-title">{t('auto_check_updates', localSettings.language)}</span>
                  <span class="auto-desc">{t('auto_check_updates_desc', localSettings.language)}</span>
                </label>
              </div>
            </div>
            <div class="about-links">
              <button class="link-btn" on:click={() => openLink('https://github.com/kobaltgit/peekit')}>
                <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22" />
                </svg>
                <span>{t('github_link', localSettings.language)}</span>
              </button>

              <button class="link-btn" on:click={() => openLink('https://kobaltgit.github.io/PeekIt/')}>
                <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="12" cy="12" r="10" />
                  <line x1="2" y1="12" x2="22" y2="12" />
                  <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
                </svg>
                <span>{t('website_link', localSettings.language)}</span>
              </button>

              <button class="link-btn" on:click={() => openLink('https://kobaltgit.github.io/peekit-plugins/')}>
                <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
                  <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
                  <line x1="12" y1="22.08" x2="12" y2="12" />
                </svg>
                <span>{t('plugins_repo_link', localSettings.language)}</span>
              </button>
            </div>
          </div>
        {/if}
      </div>

      <div class="modal-footer">
        <button class="btn-cancel" on:click={onClose}>{t('close_settings', localSettings.language)}</button>
        <button class="btn-save" on:click={saveAndClose}>{t('save', localSettings.language)}</button>
      </div>
    </div>
  </div>
{/if}

<style>
  .modal-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.65);
    backdrop-filter: blur(8px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .modal-dialog {
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    box-shadow: var(--shadow-elevation);
    border-radius: 14px;
    width: 520px;
    max-width: 92vw;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 20px;
    border-bottom: 1px solid var(--border-color);
  }

  .modal-title {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 15px;
    font-weight: 600;
  }

  .btn-close {
    background: transparent;
    border: none;
    font-size: 20px;
    color: var(--text-muted);
    cursor: pointer;
    line-height: 1;
  }

  .btn-close:hover {
    color: var(--text-main);
  }

  .tabs-bar {
    display: flex;
    padding: 6px 16px;
    background: var(--bg-subtle);
    border-bottom: 1px solid var(--border-color);
    gap: 8px;
  }

  .tab-link {
    background: transparent;
    border: none;
    padding: 6px 12px;
    border-radius: 6px;
    font-size: 13px;
    color: var(--text-muted);
    cursor: pointer;
  }

  .tab-link:hover {
    color: var(--text-main);
    background: var(--bg-hover);
  }

  .tab-link.active {
    background: var(--accent);
    color: white;
  }

  .modal-body {
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 16px;
    max-height: 420px;
    overflow-y: auto;
    overflow-x: hidden;
  }

  .setting-item {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .setting-label {
    font-size: 13px;
    font-weight: 500;
  }

  .setting-select {
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    color: var(--text-main);
    padding: 8px 12px;
    border-radius: 6px;
    outline: none;
  }

  .setting-item-check {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 13px;
    cursor: pointer;
  }

  .setting-item-check input {
    accent-color: var(--accent);
    cursor: pointer;
  }

  .hotkeys-box {
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    padding: 12px;
    border-radius: 8px;
    font-size: 12px;
  }

  .hotkeys-box h4 {
    margin-bottom: 8px;
    font-size: 12px;
    color: var(--text-dim);
    text-transform: uppercase;
  }

  .hotkeys-box ul {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 4px;
    color: var(--text-muted);
  }

  .theme-picker {
    display: flex;
    gap: 8px;
  }

  .theme-opt {
    flex: 1;
    padding: 10px;
    border-radius: 8px;
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    color: var(--text-main);
    cursor: pointer;
    font-size: 12px;
    transition: all 0.15s ease;
  }

  .theme-opt.selected {
    border-color: var(--accent);
    background: rgba(59, 130, 246, 0.15);
    color: var(--accent);
    font-weight: 600;
  }

  .about-section {
    text-align: center;
    padding: 12px 0;
  }

  .about-section h3 {
    font-size: 18px;
    margin-bottom: 4px;
  }

  .about-desc {
    font-size: 13px;
    color: var(--text-muted);
    margin-bottom: 12px;
  }

  .about-tech {
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    color: var(--accent);
    margin-bottom: 8px;
  }

  .about-author {
    font-size: 12px;
    color: var(--text-dim);
    margin-bottom: 16px;
  }

  .about-links {
    display: flex;
    justify-content: center;
    gap: 12px;
    flex-wrap: wrap;
    margin-top: 14px;
  }

  .link-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: var(--bg-subtle, rgba(255, 255, 255, 0.05));
    border: 1px solid var(--border-color, rgba(255, 255, 255, 0.12));
    color: var(--text-main, #f1f5f9);
    padding: 8px 14px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
  }

  .link-btn:hover {
    background: var(--bg-hover, rgba(255, 255, 255, 0.1));
    border-color: var(--accent, #3b82f6);
    color: #ffffff;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(59, 130, 246, 0.25);
  }

  .link-btn svg {
    color: var(--accent, #3b82f6);
    transition: transform 0.2s ease;
  }

  /* Updater Block Styles */
  .tab-badge-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: #f59e0b;
    box-shadow: 0 0 6px #f59e0b;
    margin-left: 6px;
  }

  .updater-box {
    background: var(--bg-subtle, rgba(255, 255, 255, 0.03));
    border: 1px solid var(--border-color, rgba(255, 255, 255, 0.08));
    border-radius: 10px;
    padding: 12px 14px;
    margin: 14px auto;
    max-width: 440px;
    text-align: left;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
  }

  .updater-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
  }

  .updater-status {
    display: flex;
    align-items: center;
    gap: 8px;
    min-height: 24px;
  }

  .status-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    flex-shrink: 0;
  }

  .status-dot.idle {
    background: var(--text-muted, #94a3b8);
  }

  .status-dot.up-to-date {
    background: #10b981;
    box-shadow: 0 0 8px rgba(16, 185, 129, 0.5);
  }

  .status-dot.update-available {
    background: #f59e0b;
    box-shadow: 0 0 8px rgba(245, 158, 11, 0.6);
  }

  .status-dot.pulse {
    background: var(--accent, #3b82f6);
    box-shadow: 0 0 8px rgba(59, 130, 246, 0.6);
    animation: pulse-glow 1.2s infinite ease-in-out;
  }

  @keyframes pulse-glow {
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: 0.5; transform: scale(1.2); }
  }

  .status-msg {
    font-size: 12px;
    font-weight: 500;
    color: var(--text-main, #f1f5f9);
  }

  .status-msg.up-to-date-text {
    color: #10b981;
  }

  .status-msg.update-available-text {
    color: #f59e0b;
    font-weight: 600;
  }

  .btn-check-updates {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: var(--bg-hover, rgba(255, 255, 255, 0.08));
    border: 1px solid var(--border-color, rgba(255, 255, 255, 0.15));
    color: var(--text-main, #f1f5f9);
    padding: 6px 10px;
    border-radius: 6px;
    font-size: 11.5px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.15s ease;
  }

  .btn-check-updates:hover:not(:disabled) {
    background: rgba(59, 130, 246, 0.15);
    border-color: var(--accent, #3b82f6);
    color: #ffffff;
  }

  .btn-check-updates:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .spin-icon {
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }

  .updater-error {
    font-size: 11.5px;
    color: #ef4444;
    margin-top: 8px;
    padding: 6px 10px;
    background: rgba(239, 68, 68, 0.1);
    border-radius: 6px;
  }

  .updater-card {
    background: rgba(245, 158, 11, 0.07);
    border: 1px solid rgba(245, 158, 11, 0.25);
    border-radius: 8px;
    padding: 10px 12px;
    margin-top: 10px;
    animation: fadeIn 0.2s ease-out;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(-4px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .updater-card-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 8px;
  }

  .card-badge {
    background: #f59e0b;
    color: #0f172a;
    font-size: 11px;
    font-weight: 700;
    padding: 1px 6px;
    border-radius: 4px;
  }

  .card-title {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-main, #f1f5f9);
  }

  .updater-card-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 6px;
  }

  .btn-update-download {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 12px;
    border-radius: 6px;
    font-size: 11.5px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.15s ease;
    border: none;
  }

  .btn-update-download.primary {
    background: #10b981;
    color: #ffffff;
  }

  .btn-update-download.primary:hover {
    background: #059669;
    transform: translateY(-1px);
    box-shadow: 0 3px 8px rgba(16, 185, 129, 0.3);
  }

  .btn-update-download.secondary {
    background: var(--bg-hover, rgba(255, 255, 255, 0.08));
    border: 1px solid var(--border-color, rgba(255, 255, 255, 0.15));
    color: var(--text-main, #f1f5f9);
  }

  .btn-update-download.secondary:hover {
    background: rgba(255, 255, 255, 0.12);
    border-color: var(--accent, #3b82f6);
    color: #ffffff;
    transform: translateY(-1px);
  }

  .btn-release-notes {
    display: inline-block;
    margin-top: 8px;
    background: transparent;
    border: none;
    color: var(--accent, #3b82f6);
    font-size: 11.5px;
    cursor: pointer;
    text-decoration: underline;
    padding: 0;
    transition: opacity 0.15s ease;
  }

  .btn-release-notes:hover {
    opacity: 0.8;
  }

  .updater-auto-row {
    display: flex;
    align-items: flex-start;
    gap: 8px;
    margin-top: 10px;
    padding-top: 8px;
    border-top: 1px solid var(--border-color, rgba(255, 255, 255, 0.06));
  }

  .updater-auto-row input[type="checkbox"] {
    margin-top: 2px;
    cursor: pointer;
  }

  .updater-auto-row label {
    cursor: pointer;
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .auto-title {
    font-size: 11.5px;
    color: var(--text-main, #f1f5f9);
    font-weight: 500;
  }

  .auto-desc {
    font-size: 10.5px;
    color: var(--text-dim, #64748b);
  }

  .modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    padding: 14px 20px;
    background: var(--bg-subtle);
    border-top: 1px solid var(--border-color);
  }

  .btn-cancel, .btn-save {
    padding: 8px 16px;
    border-radius: 6px;
    font-size: 13px;
    cursor: pointer;
  }

  .btn-cancel {
    background: transparent;
    border: 1px solid var(--border-color);
    color: var(--text-main);
  }

  .btn-save {
    background: var(--accent);
    border: none;
    color: white;
    font-weight: 500;
  }
</style>
