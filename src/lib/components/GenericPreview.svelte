<script lang="ts">
  import type { FilePreviewInfo, AppLanguage } from '../types';
  import { t } from '../i18n';

  export let file: FilePreviewInfo;
  export let lang: AppLanguage = 'ru';
  export let onOpenApp: () => void;
</script>

<div class="generic-container">
  <div class="card-box">
    {#if file.extra?.isCloudPlaceholder}
      <div class="cloud-warning-badge">
        <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z" />
        </svg>
        <span>{t('cloud_placeholder_badge', lang)}</span>
      </div>
      <p class="cloud-desc">{t('cloud_placeholder_desc', lang)}</p>
    {/if}

    <div class="file-icon-circle">
      <svg viewBox="0 0 24 24" width="48" height="48" fill="none" stroke="currentColor" stroke-width="1.6">
        <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z" />
        <polyline points="13 2 13 9 20 9" />
      </svg>
      <span class="ext-badge">{file.extension.toUpperCase() || 'FILE'}</span>
    </div>

    <h2 class="file-name">{file.fileName}</h2>

    <div class="meta-grid">
      <div class="meta-item">
        <span class="meta-label">{t('size', lang)}</span>
        <span class="meta-val">{file.sizeFormatted}</span>
      </div>
      <div class="meta-item">
        <span class="meta-label">{t('modified', lang)}</span>
        <span class="meta-val">{file.modified}</span>
      </div>
      <div class="meta-item full">
        <span class="meta-label">MIME</span>
        <span class="meta-val mono">{file.mimeType}</span>
      </div>
    </div>

    <button class="btn-open-primary" on:click={onOpenApp}>
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
        <polyline points="15 3 21 3 21 9" />
        <line x1="10" y1="14" x2="21" y2="3" />
      </svg>
      <span>{t('open_in_app', lang)}</span>
    </button>
  </div>
</div>

<style>
  .generic-container {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 32px;
    background: var(--bg-card);
  }

  .card-box {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    background: var(--bg-subtle);
    border: 1px solid var(--border-color);
    padding: 32px;
    border-radius: 16px;
    max-width: 460px;
    width: 100%;
    box-shadow: var(--shadow-elevation);
  }

  .cloud-warning-badge {
    display: flex;
    align-items: center;
    gap: 8px;
    background: rgba(59, 130, 246, 0.15);
    color: var(--accent);
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 500;
    margin-bottom: 12px;
  }

  .cloud-desc {
    font-size: 12px;
    color: var(--text-muted);
    margin-bottom: 20px;
    line-height: 1.5;
  }

  .file-icon-circle {
    position: relative;
    width: 88px;
    height: 88px;
    border-radius: 20px;
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--accent);
    margin-bottom: 16px;
  }

  .ext-badge {
    position: absolute;
    bottom: -6px;
    background: var(--accent);
    color: #fff;
    font-size: 10px;
    font-weight: 700;
    padding: 2px 6px;
    border-radius: 4px;
  }

  .file-name {
    font-size: 16px;
    font-weight: 600;
    color: var(--text-main);
    margin-bottom: 20px;
    word-break: break-all;
  }

  .meta-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    width: 100%;
    margin-bottom: 24px;
  }

  .meta-item {
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    padding: 8px 12px;
    border-radius: 8px;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 2px;
  }

  .meta-item.full {
    grid-column: span 2;
  }

  .meta-label {
    font-size: 11px;
    color: var(--text-dim);
    text-transform: uppercase;
  }

  .meta-val {
    font-size: 12px;
    color: var(--text-main);
    font-weight: 500;
  }

  .meta-val.mono {
    font-family: 'JetBrains Mono', monospace;
  }

  .btn-open-primary {
    background: var(--accent);
    color: white;
    border: none;
    padding: 10px 24px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.15s ease;
  }

  .btn-open-primary:hover {
    background: var(--accent-hover);
    box-shadow: 0 0 16px var(--accent-glow);
  }
</style>
