<script lang="ts">
  import { convertFileSrc } from '@tauri-apps/api/core';
  import type { FilePreviewInfo, AppLanguage } from '../types';
  import { t } from '../i18n';

  export let file: FilePreviewInfo;
  export let lang: AppLanguage = 'ru';

  let zoom = 1;
  let panX = 0;
  let panY = 0;
  let isDragging = false;
  let startX = 0;
  let startY = 0;

  $: imgSrc = file?.path ? convertFileSrc(file.path) : '';

  function handleWheel(e: WheelEvent) {
    e.preventDefault();
    const delta = e.deltaY > 0 ? -0.15 : 0.15;
    zoom = Math.min(Math.max(0.2, zoom + delta), 6);
  }

  function handleMouseDown(e: MouseEvent) {
    if (e.button !== 0) return;
    isDragging = true;
    startX = e.clientX - panX;
    startY = e.clientY - panY;
  }

  function handleMouseMove(e: MouseEvent) {
    if (!isDragging) return;
    panX = e.clientX - startX;
    panY = e.clientY - startY;
  }

  function handleMouseUp() {
    isDragging = false;
  }

  function resetZoom() {
    zoom = 1;
    panX = 0;
    panY = 0;
  }
</script>

<div
  class="image-container"
  on:wheel={handleWheel}
  on:mousedown={handleMouseDown}
  on:mousemove={handleMouseMove}
  on:mouseup={handleMouseUp}
  on:mouseleave={handleMouseUp}
  role="region"
  aria-label="Image Preview"
>
  <div
    class="image-wrapper"
    style="transform: translate({panX}px, {panY}px) scale({zoom}); cursor: {isDragging ? 'grabbing' : 'grab'};"
  >
    <img
      src={imgSrc}
      alt={file.fileName}
      class:is-svg={file.extension === 'svg'}
      draggable="false"
    />
  </div>

  <!-- Zoom & Resolution Badge Overlay -->
  <div class="zoom-badge-bar">
    {#if file.extra?.dimensions}
      <span class="meta-tag">
        {file.extra.dimensions.width} × {file.extra.dimensions.height}
      </span>
    {/if}
    <button class="zoom-reset-btn" on:click={resetZoom} title="Reset zoom">
      {Math.round(zoom * 100)}%
    </button>
  </div>
</div>

<style>
  .image-container {
    flex: 1;
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    position: relative;
    user-select: none;
    background-image: 
      radial-gradient(var(--border-color) 1px, transparent 0);
    background-size: 24px 24px;
    background-position: -19px -19px;
  }

  .image-wrapper {
    display: flex;
    align-items: center;
    justify-content: center;
    transform-origin: center center;
    transition: transform 0.05s linear;
  }

  .image-wrapper img {
    max-width: 85vw;
    max-height: 75vh;
    object-fit: contain;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
    border-radius: 6px;
    user-select: none;
    pointer-events: none;
  }

  .image-wrapper img.is-svg {
    width: min(75vw, 550px);
    height: min(70vh, 550px);
    background: repeating-conic-gradient(rgba(128, 128, 128, 0.15) 0% 25%, transparent 0% 50%) 50% / 16px 16px;
    border-radius: 8px;
    padding: 16px;
  }

  .zoom-badge-bar {
    position: absolute;
    bottom: 16px;
    right: 16px;
    display: flex;
    align-items: center;
    gap: 8px;
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    padding: 4px 10px;
    border-radius: 20px;
    backdrop-filter: blur(12px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    font-size: 12px;
    font-family: 'JetBrains Mono', monospace;
  }

  .meta-tag {
    color: var(--text-muted);
  }

  .zoom-reset-btn {
    background: transparent;
    border: none;
    color: var(--accent);
    cursor: pointer;
    font-weight: 600;
  }

  .zoom-reset-btn:hover {
    text-decoration: underline;
  }
</style>
