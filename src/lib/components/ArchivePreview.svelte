<script lang="ts">
  import type { FilePreviewInfo, AppLanguage, ArchiveEntry } from '../types';
  import { t } from '../i18n';

  export let file: FilePreviewInfo;
  export let lang: AppLanguage = 'ru';

  let searchQuery = '';

  function formatBytes(bytes: number): string {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  }

  $: entries = file.extra?.archiveEntries || [];
  $: filteredEntries = entries.filter((e) =>
    e.name.toLowerCase().includes(searchQuery.toLowerCase())
  );
</script>

<div class="archive-container">
  <div class="archive-toolbar">
    <div class="search-box">
      <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="11" cy="11" r="8" />
        <line x1="21" y1="21" x2="16.65" y2="16.65" />
      </svg>
      <input
        type="text"
        bind:value={searchQuery}
        placeholder="Search files in archive..."
        class="search-input"
      />
    </div>
    <div class="archive-stats">
      <span>{entries.length} {t('archive_files_count', lang)}</span>
    </div>
  </div>

  <div class="table-wrapper">
    {#if filteredEntries.length === 0}
      <div class="empty-hint">{t('archive_empty', lang)}</div>
    {:else}
      <table class="archive-table">
        <thead>
          <tr>
            <th>{t('archive_name', lang)}</th>
            <th class="col-num">{t('archive_size', lang)}</th>
            <th class="col-num">{t('archive_compressed', lang)}</th>
          </tr>
        </thead>
        <tbody>
          {#each filteredEntries as entry}
            <tr class:is-dir={entry.isDirectory}>
              <td class="name-cell">
                {#if entry.isDirectory}
                  <svg viewBox="0 0 24 24" width="14" height="14" fill="#eab308">
                    <path d="M10 4H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-8l-2-2z" />
                  </svg>
                {:else}
                  <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                    <polyline points="14 2 14 8 20 8" />
                  </svg>
                {/if}
                <span class="file-name">{entry.name}</span>
              </td>
              <td class="col-num">{entry.isDirectory ? '-' : formatBytes(entry.sizeBytes)}</td>
              <td class="col-num">{entry.isDirectory ? '-' : formatBytes(entry.compressedSizeBytes)}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    {/if}
  </div>
</div>

<style>
  .archive-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    width: 100%;
    background: var(--bg-card);
  }

  .archive-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 16px;
    background: var(--bg-subtle);
    border-bottom: 1px solid var(--border-color);
  }

  .search-box {
    display: flex;
    align-items: center;
    gap: 8px;
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    padding: 4px 10px;
    border-radius: 6px;
    width: 260px;
  }

  .search-input {
    background: transparent;
    border: none;
    outline: none;
    color: var(--text-main);
    font-size: 12px;
    width: 100%;
  }

  .archive-stats {
    font-size: 12px;
    color: var(--text-muted);
  }

  .table-wrapper {
    flex: 1;
    overflow: auto;
  }

  .archive-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
  }

  .archive-table th {
    position: sticky;
    top: 0;
    background: var(--bg-subtle);
    text-align: left;
    padding: 8px 16px;
    font-size: 11px;
    text-transform: uppercase;
    color: var(--text-dim);
    letter-spacing: 0.05em;
    border-bottom: 1px solid var(--border-color);
  }

  .archive-table td {
    padding: 7px 16px;
    border-bottom: 1px solid var(--border-color);
  }

  .archive-table tr:hover {
    background: var(--bg-hover);
  }

  .name-cell {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .file-name {
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    color: var(--text-main);
  }

  .col-num {
    text-align: right;
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    color: var(--text-muted);
    width: 120px;
  }

  .empty-hint {
    padding: 32px;
    text-align: center;
    color: var(--text-dim);
  }
</style>
