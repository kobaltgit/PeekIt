<script lang="ts">
  import { onMount } from 'svelte';
  import { convertFileSrc } from '@tauri-apps/api/core';
  import type { FilePreviewInfo, AppLanguage } from '../types';
  import { t } from '../i18n';
  import * as pdfjsLib from 'pdfjs-dist';
  import pdfjsWorker from 'pdfjs-dist/build/pdf.worker.min.mjs?url';

  if (typeof window !== 'undefined' && pdfjsLib.GlobalWorkerOptions) {
    pdfjsLib.GlobalWorkerOptions.workerSrc = pdfjsWorker;
  }

  export let file: FilePreviewInfo;
  export let lang: AppLanguage = 'ru';

  let canvasEl: HTMLCanvasElement;
  let currentPage = 1;
  let totalPages = 1;
  let scale = 1.3;
  let pdfDoc: any = null;
  let loading = true;
  let errorMsg = '';

  async function loadPdf() {
    try {
      loading = true;
      errorMsg = '';
      const fileUrl = convertFileSrc(file.path);
      const response = await fetch(fileUrl);
      const buffer = await response.arrayBuffer();

      const loadingTask = pdfjsLib.getDocument({
        data: new Uint8Array(buffer),
        cMapUrl: 'https://cdn.jsdelivr.net/npm/pdfjs-dist@4.10.38/cmaps/',
        cMapPacked: true,
      });

      pdfDoc = await loadingTask.promise;
      totalPages = pdfDoc.numPages;
      currentPage = 1;
      await renderCurrentPage();
    } catch (err: any) {
      console.error('PDF load error:', err);
      errorMsg = err?.message || 'Failed to load PDF';
    } finally {
      loading = false;
    }
  }

  async function renderCurrentPage() {
    if (!pdfDoc || !canvasEl) return;
    const page = await pdfDoc.getPage(currentPage);
    const viewport = page.getViewport({ scale });
    const ctx = canvasEl.getContext('2d');
    if (!ctx) return;

    canvasEl.width = viewport.width;
    canvasEl.height = viewport.height;

    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, canvasEl.width, canvasEl.height);

    await page.render({
      canvasContext: ctx,
      viewport: viewport,
    }).promise;
  }

  function prevPage() {
    if (currentPage > 1) {
      currentPage--;
      renderCurrentPage();
    }
  }

  function nextPage() {
    if (currentPage < totalPages) {
      currentPage++;
      renderCurrentPage();
    }
  }

  function zoomIn() {
    scale = Math.min(3.0, scale + 0.2);
    renderCurrentPage();
  }

  function zoomOut() {
    scale = Math.max(0.6, scale - 0.2);
    renderCurrentPage();
  }

  onMount(() => {
    loadPdf();
  });
</script>

<div class="pdf-container">
  <div class="pdf-toolbar">
    <div class="page-nav">
      <button class="btn-nav" on:click={prevPage} disabled={currentPage <= 1}>
        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="15 18 9 12 15 6" />
        </svg>
      </button>
      <span class="page-indicator">
        {currentPage} {t('page_of', lang)} {totalPages}
      </span>
      <button class="btn-nav" on:click={nextPage} disabled={currentPage >= totalPages}>
        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="9 18 15 12 9 6" />
        </svg>
      </button>
    </div>

    <div class="zoom-controls">
      <button class="btn-nav" on:click={zoomOut} title="Zoom Out">
        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="5" y1="12" x2="19" y2="12" />
        </svg>
      </button>
      <span class="zoom-label">{Math.round(scale * 100)}%</span>
      <button class="btn-nav" on:click={zoomIn} title="Zoom In">
        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="12" y1="5" x2="12" y2="19" />
          <line x1="5" y1="12" x2="19" y2="12" />
        </svg>
      </button>
    </div>
  </div>

  <div class="pdf-canvas-wrapper">
    {#if loading}
      <div class="loading-box">
        <div class="spinner"></div>
      </div>
    {:else if errorMsg}
      <div class="error-box">{errorMsg}</div>
    {/if}
    <canvas bind:this={canvasEl} class="pdf-canvas" class:hidden={loading || !!errorMsg}></canvas>
  </div>
</div>

<style>
  .pdf-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    width: 100%;
    background: var(--bg-card);
  }

  .pdf-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 16px;
    background: var(--bg-subtle);
    border-bottom: 1px solid var(--border-color);
  }

  .page-nav, .zoom-controls {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .btn-nav {
    background: transparent;
    border: 1px solid var(--border-color);
    color: var(--text-main);
    border-radius: 6px;
    padding: 4px 8px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.15s ease;
  }

  .btn-nav:disabled {
    opacity: 0.3;
    cursor: not-allowed;
  }

  .btn-nav:hover:not(:disabled) {
    background: var(--bg-hover);
  }

  .page-indicator, .zoom-label {
    font-size: 12px;
    font-family: 'JetBrains Mono', monospace;
    color: var(--text-muted);
  }

  .pdf-canvas-wrapper {
    flex: 1;
    overflow: auto;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding: 24px;
    background: rgba(0, 0, 0, 0.2);
  }

  .pdf-canvas {
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
    border-radius: 4px;
    max-width: 100%;
  }

  .pdf-canvas.hidden {
    display: none;
  }

  .loading-box {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 200px;
  }

  .spinner {
    width: 32px;
    height: 32px;
    border: 3px solid rgba(255, 255, 255, 0.1);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .error-box {
    color: #ef4444;
    font-size: 14px;
    padding: 20px;
  }
</style>
