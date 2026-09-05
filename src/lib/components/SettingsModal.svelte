<script lang="ts">
  import type { AppSettings, AppLanguage, AppTheme } from '../types';
  import { t } from '../i18n';

  export let settings: AppSettings;
  export let isOpen: boolean = false;
  export let onClose: () => void;
  export let onSave: (updated: AppSettings) => void;

  let localSettings = { ...settings };
  let activeTab: 'general' | 'appearance' | 'about' = 'general';

  function saveAndClose() {
    onSave(localSettings);
    onClose();
  }
</script>

{#if isOpen}
  <div class="modal-backdrop" on:click={onClose} role="presentation">
    <div class="modal-dialog" on:click|stopPropagation role="dialog" aria-modal="true">
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
          class="tab-link {activeTab === 'about' ? 'active' : ''}"
          on:click={() => (activeTab = 'about')}
        >
          {t('about_tab', localSettings.language)}
        </button>
      </div>

      <div class="modal-body">
        {#if activeTab === 'general'}
          <div class="setting-item">
            <label class="setting-label">{t('language', localSettings.language)}</label>
            <select bind:value={localSettings.language} class="setting-select">
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
            <label class="setting-label">{t('theme', localSettings.language)}</label>
            <div class="theme-picker">
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
        {:else if activeTab === 'about'}
          <div class="about-section">
            <h3>Peekit v1.0.0</h3>
            <p class="about-desc">{t('app_subtitle', localSettings.language)}</p>
            <p class="about-tech">Rust (Win32 COM) + Tauri v2 + Svelte 5</p>
            <p class="about-author">{t('author', localSettings.language)}</p>
            <div class="about-links">
              <a href="https://github.com/kobaltgit/quicklook" target="_blank" rel="noreferrer">
                {t('github_link', localSettings.language)}
              </a>
              <a href="https://kobaltgit.github.io/quicklook/" target="_blank" rel="noreferrer">
                {t('website_link', localSettings.language)}
              </a>
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
    width: 480px;
    max-width: 90vw;
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
    max-height: 380px;
    overflow-y: auto;
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
    gap: 16px;
    font-size: 12px;
  }

  .about-links a {
    color: var(--accent);
    text-decoration: none;
  }

  .about-links a:hover {
    text-decoration: underline;
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
