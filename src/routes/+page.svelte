<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';
  import { listen } from '@tauri-apps/api/event';
  import type { FilePreviewInfo, AppSettings, AppLanguage } from '$lib/types';
  import { t, currentLanguage } from '$lib/i18n';
  import { currentTheme, applyTheme } from '$lib/theme';
  import ImagePreview from '$lib/components/ImagePreview.svelte';
  import MediaPreview from '$lib/components/MediaPreview.svelte';
  import CodePreview from '$lib/components/CodePreview.svelte';
  import MarkdownPreview from '$lib/components/MarkdownPreview.svelte';
  import PdfPreview from '$lib/components/PdfPreview.svelte';
  import ArchivePreview from '$lib/components/ArchivePreview.svelte';
  import GenericPreview from '$lib/components/GenericPreview.svelte';
  import SettingsModal from '$lib/components/SettingsModal.svelte';

  // State
  let currentFile: FilePreviewInfo | null = null;
  let textContent = '';
  let isPinned = false;
  let isSettingsOpen = false;
  let copyFeedback = false;

  let settings: AppSettings = {
    language: 'ru',
    theme: 'dark',
    autostart: true,
    closeOnFocusLoss: false,
    autoplayMedia: true,
    volume: 0.8,
    stayOnTop: false,
  };

  let unlistenPreview: (() => void) | null = null;
  let unlistenClose: (() => void) | null = null;
  let unlistenSettings: (() => void) | null = null;
  let unlistenGroup: (() => void) | null = null;

  let fileGroup: string[] = [];
  let groupIndex: number = 0;

  async function prevGroupItem() {
    if (fileGroup.length <= 1) return;
    groupIndex = (groupIndex - 1 + fileGroup.length) % fileGroup.length;
    await loadFileInfo(fileGroup[groupIndex]);
  }

  async function nextGroupItem() {
    if (fileGroup.length <= 1) return;
    groupIndex = (groupIndex + 1) % fileGroup.length;
    await loadFileInfo(fileGroup[groupIndex]);
  }

  async function invokeTauri(cmd: string, args: any = {}): Promise<any> {
    try {
      return await invoke(cmd, args);
    } catch (e) {
      console.warn(`Tauri invoke '${cmd}' failed (running in browser mode):`, e);
      return null;
    }
  }

  async function loadFileInfo(filePath: string) {
    const info: FilePreviewInfo = await invokeTauri('get_file_info', { path: filePath });
    if (info) {
      if (['code', 'markdown', 'text'].includes(info.category)) {
        textContent = await invokeTauri('read_text_content', { path: filePath }) || '';
      }
      currentFile = info;
    }
  }

  async function openWithDefaultApp() {
    if (!currentFile) return;
    await invokeTauri('open_with_default_app', { path: currentFile.path });
  }

  async function revealInFolder() {
    if (!currentFile) return;
    await invokeTauri('reveal_in_explorer', { path: currentFile.path });
  }

  async function copyPath() {
    if (!currentFile) return;
    try {
      await navigator.clipboard.writeText(currentFile.path);
      copyFeedback = true;
      setTimeout(() => (copyFeedback = false), 2000);
    } catch (e) {
      console.warn('Copy failed:', e);
    }
  }

  async function togglePin() {
    isPinned = !isPinned;
    await invokeTauri('toggle_pin_window', { pin: isPinned });
  }

  async function closeWindow() {
    currentFile = null;
    textContent = '';
    fileGroup = [];
    groupIndex = 0;
    await invokeTauri('hide_preview_window');
  }

  function handleCloseSettings() {
    isSettingsOpen = false;
    if (!currentFile) {
      closeWindow();
    }
  }

  async function handleKeydown(e: KeyboardEvent) {
    if (isSettingsOpen) {
      if (e.key === 'Escape') {
        e.preventDefault();
        handleCloseSettings();
      }
      return;
    }

    if (e.code === 'Space' || e.key === 'Escape') {
      // If we are in media player and space is pressed, allow media player toggle, else close
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) {
        return;
      }
      e.preventDefault();
      closeWindow();
    } else if (e.key === 'Enter') {
      e.preventDefault();
      openWithDefaultApp();
    } else if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(e.key)) {
      e.preventDefault();
      if (fileGroup.length > 1) {
        if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
          prevGroupItem();
        } else {
          nextGroupItem();
        }
      } else {
        const newFile = await invokeTauri('navigate_adjacent_file', { direction: e.key });
        if (newFile && typeof newFile === 'string') {
          await loadFileInfo(newFile);
        }
      }
    }
  }

  function saveSettings(updated: AppSettings) {
    settings = updated;
    $currentLanguage = updated.language;
    $currentTheme = updated.theme;
    applyTheme(updated.theme);
    invokeTauri('save_app_config', { config: updated });
    handleCloseSettings();
  }

  onMount(async () => {
    window.addEventListener('keydown', handleKeydown);

    // Initial config load
    const savedConfig = await invokeTauri('get_app_config');
    if (savedConfig) {
      settings = { ...settings, ...savedConfig };
      $currentLanguage = settings.language;
      $currentTheme = settings.theme;
      applyTheme(settings.theme);
    } else {
      applyTheme('dark');
    }

    // Listen for Tauri events
    try {
      unlistenPreview = await listen<string>('preview_file', async (event) => {
        if (event.payload) {
          await loadFileInfo(event.payload);
        }
      });
      unlistenGroup = await listen<{ files: string[]; index: number }>('preview_group', async (event) => {
        if (event.payload && event.payload.files) {
          fileGroup = event.payload.files;
          groupIndex = event.payload.index || 0;
        }
      });
      unlistenClose = await listen('close_preview', () => {
        currentFile = null;
        textContent = '';
        fileGroup = [];
        groupIndex = 0;
      });
      unlistenSettings = await listen('open_settings', () => {
        isSettingsOpen = true;
      });
    } catch (e) {
      // Standalone browser demo preview fallback
      currentFile = {
        path: 'C:\\Users\\Kobalt\\Videos\\Demo_Release.mp4',
        fileName: 'Demo_Release.mp4',
        extension: 'mp4',
        sizeBytes: 15485760,
        sizeFormatted: '14.8 MB',
        modified: '2026-09-05 17:00',
        category: 'video',
        mimeType: 'video/mp4',
        extra: {
          dimensions: { width: 1920, height: 1080 },
          durationSeconds: 42,
        },
      };
    }
  });

  onDestroy(() => {
    if (typeof window !== 'undefined') {
      window.removeEventListener('keydown', handleKeydown);
    }
    if (unlistenPreview) unlistenPreview();
    if (unlistenGroup) unlistenGroup();
    if (unlistenClose) unlistenClose();
    if (unlistenSettings) unlistenSettings();
  });
</script>

<main class="quicklook-window">
  <!-- Window Top Bar (Fluent Custom Titlebar) -->
  <header class="topbar" data-tauri-drag-region>
    <div class="file-title-group">
      <div class="app-icon">
        <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10" />
          <path d="M12 8v8M8 12h8" />
        </svg>
      </div>
      <div class="file-info-text">
        <span class="file-title">
          {currentFile ? currentFile.fileName : t('no_file_selected', settings.language)}
        </span>
        {#if currentFile}
          <span class="file-size-badge">{currentFile.sizeFormatted}</span>
        {/if}
      </div>
    </div>

    <!-- Actions Toolbar -->
    <div class="actions-toolbar">
      {#if fileGroup.length > 1}
        <div class="group-carousel-nav">
          <button class="carousel-nav-btn" on:click={prevGroupItem} title="Предыдущий файл (← / ↑)">
            <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5">
              <polyline points="15 18 9 12 15 6" />
            </svg>
          </button>
          <span class="group-counter">{groupIndex + 1} / {fileGroup.length}</span>
          <button class="carousel-nav-btn" on:click={nextGroupItem} title="Следующий файл (→ / ↓)">
            <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5">
              <polyline points="9 18 15 12 9 6" />
            </svg>
          </button>
        </div>
      {/if}

      {#if currentFile}
        <button class="action-btn" on:click={openWithDefaultApp} title={t('open_in_app', settings.language)}>
          <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
            <polyline points="15 3 21 3 21 9" />
            <line x1="10" y1="14" x2="21" y2="3" />
          </svg>
          <span class="btn-label">{t('open_in_app', settings.language)}</span>
        </button>

        <button class="action-btn icon-only" on:click={copyPath} title={t('copy_path', settings.language)}>
          {#if copyFeedback}
            <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="#22c55e" stroke-width="2">
              <polyline points="20 6 9 17 4 12" />
            </svg>
          {:else}
            <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
              <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
            </svg>
          {/if}
        </button>

        <button
          class="action-btn icon-only {isPinned ? 'pinned' : ''}"
          on:click={togglePin}
          title={isPinned ? t('unpin_window', settings.language) : t('pin_window', settings.language)}
        >
          <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="12" y1="17" x2="12" y2="22" />
            <path d="M5 17h14v-2l-2-3V5a1 1 0 0 0-1-1H8a1 1 0 0 0-1 1v7l-2 3v2z" />
          </svg>
        </button>
      {/if}

      <button class="action-btn icon-only" on:click={() => (isSettingsOpen = true)} title={t('settings', settings.language)}>
        <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="3" />
          <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z" />
        </svg>
      </button>

      <button class="action-btn icon-only close-btn" on:click={closeWindow} title={t('close', settings.language)}>
        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="18" y1="6" x2="6" y2="18" />
          <line x1="6" y1="6" x2="18" y2="18" />
        </svg>
      </button>
    </div>
  </header>

  <!-- Central Dynamic Viewer Body -->
  <section class="viewer-body">
    {#if !currentFile}
      <div class="empty-state">
        <div class="empty-pulse-icon">
          <svg viewBox="0 0 24 24" width="54" height="54" fill="none" stroke="currentColor" stroke-width="1.5">
            <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
            <line x1="8" y1="21" x2="16" y2="21" />
            <line x1="12" y1="17" x2="12" y2="21" />
          </svg>
        </div>
        <h2>{t('app_title', settings.language)}</h2>
        <p>{t('select_file_hint', settings.language)}</p>
      </div>
    {:else if currentFile.category === 'video' || currentFile.category === 'audio'}
      <MediaPreview
        file={currentFile}
        lang={settings.language}
        autoplay={settings.autoplayMedia}
        initialVolume={settings.volume}
      />
    {:else if currentFile.category === 'image'}
      <ImagePreview file={currentFile} lang={settings.language} />
    {:else if currentFile.category === 'code' || currentFile.category === 'text'}
      <CodePreview file={currentFile} content={textContent} lang={settings.language} />
    {:else if currentFile.category === 'markdown'}
      <MarkdownPreview file={currentFile} content={textContent} lang={settings.language} />
    {:else if currentFile.category === 'pdf'}
      <PdfPreview file={currentFile} lang={settings.language} />
    {:else if currentFile.category === 'archive'}
      <ArchivePreview file={currentFile} lang={settings.language} />
    {:else}
      <GenericPreview file={currentFile} lang={settings.language} onOpenApp={openWithDefaultApp} />
    {/if}
  </section>

  <!-- Status Bar -->
  <footer class="statusbar">
    <div class="status-left">
      {#if currentFile}
        <span class="badge-cat">{currentFile.category.toUpperCase()}</span>
        <span class="status-path">{currentFile.path}</span>
      {:else}
        <span class="status-tip">Windows Explorer Peekit</span>
      {/if}
    </div>
    <div class="status-right">
      <span class="shortcut-pill">Space / Esc</span>
      <span class="shortcut-desc">{t('close', settings.language)}</span>
    </div>
  </footer>

  <!-- Preferences Modal -->
  <SettingsModal
    settings={settings}
    isOpen={isSettingsOpen}
    onClose={handleCloseSettings}
    onSave={saveSettings}
  />
</main>

<style>
  .quicklook-window {
    display: flex;
    flex-direction: column;
    height: 100vh;
    width: 100vw;
    background: var(--bg-window);
    backdrop-filter: blur(24px) saturate(180%);
    border: 1px solid var(--border-color);
    box-shadow: var(--shadow-elevation);
    overflow: hidden;
  }

  .topbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 48px;
    padding: 0 16px;
    background: var(--bg-card);
    border-bottom: 1px solid var(--border-color);
    flex-shrink: 0;
  }

  .file-title-group {
    display: flex;
    align-items: center;
    gap: 12px;
    min-width: 0;
    user-select: none;
  }

  .app-icon {
    width: 28px;
    height: 28px;
    border-radius: 8px;
    background: var(--accent);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .file-info-text {
    display: flex;
    align-items: center;
    gap: 8px;
    min-width: 0;
  }

  .file-title {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-main);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .file-size-badge {
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    font-size: 11px;
    color: var(--text-muted);
    padding: 2px 6px;
    border-radius: 4px;
    font-family: 'JetBrains Mono', monospace;
  }

  .actions-toolbar {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .group-carousel-nav {
    display: flex;
    align-items: center;
    gap: 4px;
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    padding: 2px 4px;
    border-radius: 6px;
    margin-right: 4px;
  }

  .carousel-nav-btn {
    background: transparent;
    border: none;
    color: var(--text-main);
    cursor: pointer;
    padding: 3px 5px;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.15s ease;
  }

  .carousel-nav-btn:hover {
    background: var(--bg-hover);
    color: var(--accent);
  }

  .group-counter {
    font-size: 11px;
    font-weight: 600;
    font-family: 'JetBrains Mono', monospace;
    color: var(--text-main);
    padding: 0 4px;
    user-select: none;
  }

  .action-btn {
    background: transparent;
    border: 1px solid var(--border-color);
    color: var(--text-main);
    padding: 5px 10px;
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
    border-color: var(--border-hover);
  }

  .action-btn.icon-only {
    padding: 6px;
  }

  .action-btn.pinned {
    background: rgba(59, 130, 246, 0.15);
    color: var(--accent);
    border-color: var(--accent);
  }

  .close-btn:hover {
    background: #ef4444;
    border-color: #ef4444;
    color: white;
  }

  .viewer-body {
    flex: 1;
    overflow: hidden;
    position: relative;
    display: flex;
  }

  .empty-state {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 12px;
    color: var(--text-muted);
    padding: 32px;
    text-align: center;
  }

  .empty-pulse-icon {
    color: var(--accent);
    animation: pulse 2.5s ease-in-out infinite;
  }

  @keyframes pulse {
    0%, 100% { opacity: 0.7; transform: scale(1); }
    50% { opacity: 1; transform: scale(1.05); }
  }

  .statusbar {
    height: 30px;
    padding: 0 16px;
    background: var(--bg-card);
    border-top: 1px solid var(--border-color);
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 11px;
    color: var(--text-dim);
    flex-shrink: 0;
  }

  .status-left {
    display: flex;
    align-items: center;
    gap: 8px;
    overflow: hidden;
  }

  .badge-cat {
    background: var(--bg-subtle);
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 10px;
    font-weight: 700;
    color: var(--accent);
  }

  .status-path {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    font-family: 'JetBrains Mono', monospace;
  }

  .status-right {
    display: flex;
    align-items: center;
    gap: 6px;
    flex-shrink: 0;
  }

  .shortcut-pill {
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    padding: 1px 6px;
    border-radius: 4px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 10px;
    color: var(--text-main);
  }
</style>
