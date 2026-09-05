<script lang="ts">
  import type { FilePreviewInfo, AppLanguage } from '../types';
  import { t } from '../i18n';
  import CodePreview from './CodePreview.svelte';

  export let file: FilePreviewInfo;
  export let content: string = '';
  export let lang: AppLanguage = 'ru';

  let mode: 'preview' | 'raw' = 'preview';

  // Simple, secure, zero-dependency Markdown to HTML parser
  function parseMarkdown(md: string): string {
    let html = md
      // Escape HTML
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      // Headers
      .replace(/^### (.*$)/gim, '<h3>$1</h3>')
      .replace(/^## (.*$)/gim, '<h2>$1</h2>')
      .replace(/^# (.*$)/gim, '<h1>$1</h1>')
      // Code blocks
      .replace(/```([\s\S]*?)```/gim, '<pre><code>$1</code></pre>')
      // Inline code
      .replace(/`([^`]+)`/gim, '<code>$1</code>')
      // Bold & Italic
      .replace(/\*\*(.*?)\*\*/gim, '<strong>$1</strong>')
      .replace(/\*(.*?)\*/gim, '<em>$1</em>')
      // Blockquotes
      .replace(/^\> (.*$)/gim, '<blockquote>$1</blockquote>')
      // Unordered lists
      .replace(/^\- (.*$)/gim, '<li>$1</li>')
      // Links
      .replace(/\[([^\]]+)\]\(([^)]+)\)/gim, '<a href="$2" target="_blank">$1</a>')
      // Paragraphs
      .replace(/\n\n/gim, '</p><p>');

    return `<div class="md-body"><p>${html}</p></div>`;
  }

  $: renderedHtml = parseMarkdown(content);
</script>

<div class="md-container">
  <div class="md-mode-switch">
    <button
      class="tab-btn {mode === 'preview' ? 'active' : ''}"
      on:click={() => (mode = 'preview')}
    >
      {t('markdown_rendered', lang)}
    </button>
    <button
      class="tab-btn {mode === 'raw' ? 'active' : ''}"
      on:click={() => (mode = 'raw')}
    >
      {t('code_raw', lang)}
    </button>
  </div>

  <div class="md-content">
    {#if mode === 'preview'}
      <div class="md-rendered-scroll">
        <!-- eslint-disable-next-line svelte/no-at-html-tags -->
        {@html renderedHtml}
      </div>
    {:else}
      <CodePreview {file} {content} {lang} />
    {/if}
  </div>
</div>

<style>
  .md-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    width: 100%;
    background: var(--bg-card);
  }

  .md-mode-switch {
    display: flex;
    padding: 8px 16px;
    background: var(--bg-subtle);
    border-bottom: 1px solid var(--border-color);
    gap: 8px;
  }

  .tab-btn {
    background: transparent;
    border: none;
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 500;
    padding: 4px 12px;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.15s ease;
  }

  .tab-btn:hover {
    background: var(--bg-hover);
    color: var(--text-main);
  }

  .tab-btn.active {
    background: var(--accent);
    color: white;
  }

  .md-content {
    flex: 1;
    overflow: hidden;
  }

  .md-rendered-scroll {
    height: 100%;
    overflow: auto;
    padding: 24px 32px;
    user-select: text;
    line-height: 1.7;
  }

  :global(.md-body h1) {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 16px;
    color: var(--text-main);
    border-bottom: 1px solid var(--border-color);
    padding-bottom: 8px;
  }

  :global(.md-body h2) {
    font-size: 18px;
    font-weight: 600;
    margin-top: 20px;
    margin-bottom: 12px;
    color: var(--text-main);
  }

  :global(.md-body h3) {
    font-size: 15px;
    font-weight: 600;
    margin-top: 16px;
    margin-bottom: 8px;
  }

  :global(.md-body p) {
    margin-bottom: 14px;
    color: var(--text-main);
  }

  :global(.md-body code) {
    background: var(--bg-subtle);
    padding: 2px 6px;
    border-radius: 4px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
  }

  :global(.md-body pre) {
    background: var(--bg-subtle);
    padding: 14px;
    border-radius: 8px;
    overflow-x: auto;
    margin: 14px 0;
    border: 1px solid var(--border-color);
  }

  :global(.md-body blockquote) {
    border-left: 3px solid var(--accent);
    padding-left: 14px;
    margin: 14px 0;
    color: var(--text-muted);
  }

  :global(.md-body li) {
    margin-left: 20px;
    margin-bottom: 6px;
  }

  :global(.md-body a) {
    color: var(--accent);
    text-decoration: none;
  }

  :global(.md-body a:hover) {
    text-decoration: underline;
  }
</style>
