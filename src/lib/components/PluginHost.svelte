<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { invoke, convertFileSrc } from '@tauri-apps/api/core';
  import type { PluginInfo, FilePreviewInfo, AppTheme, AppLanguage } from '$lib/types';
  import type { HostToPluginMessage, PluginToHostMessage } from '$lib/plugins/protocol';

  interface Props {
    plugin: PluginInfo;
    file: FilePreviewInfo;
    theme: AppTheme;
    language: AppLanguage;
  }

  let { plugin, file, theme, language }: Props = $props();

  let iframeElement = $state<HTMLIFrameElement | null>(null);
  let isReady = $state(false);
  let errorMessage = $state<string | null>(null);

  const entryFilePath = $derived(
    `${plugin.rootPath}/${plugin.manifest.entry}`.replace(/\\/g, '/')
  );
  const iframeSrc = $derived(convertFileSrc(entryFilePath));

  function sendToPlugin(msg: HostToPluginMessage, transfer: Transferable[] = []) {
    if (iframeElement && iframeElement.contentWindow) {
      if (transfer.length > 0) {
        iframeElement.contentWindow.postMessage(msg, '*', transfer);
      } else {
        iframeElement.contentWindow.postMessage(msg, '*');
      }
    }
  }

  function sendInit() {
    sendToPlugin({
      type: 'PEEKIT_INIT',
      payload: {
        filePath: file.path,
        fileName: file.fileName,
        fileSize: file.sizeBytes,
        sizeFormatted: file.sizeFormatted,
        extension: file.extension,
        theme,
        language,
      },
    });
  }

  async function handleRequestData() {
    try {
      const rawBytes = await invoke<number[] | Uint8Array>('read_binary_for_plugin', { path: file.path });
      const uint8 = rawBytes instanceof Uint8Array ? rawBytes : new Uint8Array(rawBytes);
      const buffer = uint8.buffer.slice(uint8.byteOffset, uint8.byteOffset + uint8.byteLength);

      sendToPlugin(
        {
          type: 'PEEKIT_DATA_RESPONSE',
          payload: { data: buffer },
        },
        [buffer]
      );
    } catch (err: any) {
      console.error('[PluginHost] Failed to read binary for plugin:', err);
      sendToPlugin({
        type: 'PEEKIT_DATA_RESPONSE',
        payload: {
          data: null,
          error: err?.toString() || 'Failed to read file data',
        },
      });
    }
  }

  function handleMessage(event: MessageEvent) {
    // Only accept messages from our iframe
    if (!iframeElement || event.source !== iframeElement.contentWindow) {
      return;
    }

    const data = event.data as PluginToHostMessage;
    if (!data || typeof data !== 'object' || !('type' in data)) {
      return;
    }

    switch (data.type) {
      case 'PEEKIT_READY':
        isReady = true;
        sendInit();
        break;

      case 'PEEKIT_REQUEST_DATA':
        handleRequestData();
        break;

      case 'PEEKIT_RESIZE':
        break;

      case 'PEEKIT_ERROR':
        errorMessage = data.payload?.message || 'Unknown plugin error';
        console.warn(`[PluginHost:${plugin.manifest.id}] Error:`, data.payload?.message);
        break;
    }
  }

  // React to file change while iframe is already ready
  $effect(() => {
    if (isReady && file) {
      sendInit();
    }
  });

  // React to theme change
  $effect(() => {
    if (isReady && theme) {
      sendToPlugin({
        type: 'PEEKIT_THEME_CHANGED',
        payload: { theme },
      });
    }
  });

  function handleIframeLoad() {
    if (isReady) {
      sendInit();
    }
  }

  onMount(() => {
    window.addEventListener('message', handleMessage);
  });

  onDestroy(() => {
    window.removeEventListener('message', handleMessage);
  });
</script>

<div class="plugin-container">
  {#if errorMessage}
    <div class="plugin-error-banner">
      <div class="error-icon">⚠️</div>
      <div class="error-info">
        <div class="error-title">Ошибка плагина "{plugin.manifest.name}"</div>
        <div class="error-desc">{errorMessage}</div>
      </div>
    </div>
  {/if}

  <iframe
    bind:this={iframeElement}
    src={iframeSrc}
    title={plugin.manifest.name}
    sandbox="allow-scripts allow-same-origin"
    class="plugin-iframe"
    onload={handleIframeLoad}
  ></iframe>
</div>

<style>
  .plugin-container {
    width: 100%;
    height: 100%;
    position: relative;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    background: transparent;
  }

  .plugin-iframe {
    width: 100%;
    height: 100%;
    border: none;
    background: transparent;
    flex: 1;
  }

  .plugin-error-banner {
    display: flex;
    align-items: center;
    gap: 12px;
    background: rgba(239, 68, 68, 0.15);
    border-bottom: 1px solid rgba(239, 68, 68, 0.3);
    padding: 10px 16px;
    color: #fca5a5;
    font-size: 13px;
  }

  .error-icon {
    font-size: 18px;
    flex-shrink: 0;
  }

  .error-title {
    font-weight: 600;
  }

  .error-desc {
    font-size: 12px;
    opacity: 0.85;
    margin-top: 2px;
  }
</style>
