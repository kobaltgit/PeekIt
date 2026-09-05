<script lang="ts">
  import Prism from '../prism';
  import type { FilePreviewInfo, AppLanguage } from '../types';
  import { t } from '../i18n';

  export let file: FilePreviewInfo;
  export let content: string = '';
  export let lang: AppLanguage = 'ru';

  let copied = false;

  async function copyText() {
    try {
      await navigator.clipboard.writeText(content);
      copied = true;
      setTimeout(() => (copied = false), 2000);
    } catch (e) {
      console.warn('Failed to copy', e);
    }
  }

  function getPrismLanguage(ext: string, fileName: string): string | null {
    const e = (ext || '').toLowerCase();
    const f = (fileName || '').toLowerCase();

    // Well-known special filenames
    if (f === 'dockerfile') return 'docker';
    if (f === 'makefile') return 'bash';
    if (f === 'cmakelists.txt') return 'cmake';
    if (f === 'gemfile' || f === 'vagrantfile') return 'ruby';
    if (f === 'cargo.lock') return 'toml';
    if (f === 'pubspec.lock') return 'yaml';
    if (f === 'package-lock.json') return 'json';
    if (f.startsWith('.env')) return 'ini';
    if (
      f === '.gitignore' ||
      f === '.gitattributes' ||
      f === '.gitmodules' ||
      f === '.editorconfig' ||
      f === '.npmrc'
    ) {
      return 'ini';
    }

    const map: Record<string, string> = {
      // JavaScript / TypeScript / Web
      js: 'javascript', mjs: 'javascript', cjs: 'javascript',
      ts: 'typescript', mts: 'typescript', cts: 'typescript',
      jsx: 'javascript', tsx: 'typescript',
      html: 'markup', htm: 'markup', xml: 'markup', svg: 'markup', svelte: 'markup', vue: 'markup', astro: 'markup',
      css: 'css', scss: 'scss', sass: 'scss', less: 'less',

      // Data, Serialization & Config
      json: 'json', jsonc: 'json', json5: 'json',
      yaml: 'yaml', yml: 'yaml',
      toml: 'toml', ini: 'ini', cfg: 'ini', conf: 'ini', config: 'ini', env: 'ini', properties: 'properties',
      proto: 'protobuf',
      graphql: 'graphql', gql: 'graphql',

      // Systems, Backend & Native
      rs: 'rust',
      py: 'python', pyw: 'python',
      c: 'c', h: 'c',
      cpp: 'cpp', cc: 'cpp', cxx: 'cpp', hpp: 'cpp', hxx: 'cpp',
      cs: 'csharp',
      go: 'go',
      java: 'java',
      kt: 'kotlin', kts: 'kotlin',
      swift: 'swift',
      dart: 'dart',
      scala: 'scala',
      groovy: 'groovy', gradle: 'groovy',
      zig: 'zig',
      r: 'r',
      sql: 'sql',

      // Shell & Scripts
      sh: 'bash', bash: 'bash', zsh: 'bash',
      bat: 'batch', cmd: 'batch',
      ps1: 'powershell', psm1: 'powershell',
      lua: 'lua',
      php: 'php',
      rb: 'ruby',
      perl: 'perl', pl: 'perl', pm: 'perl',

      // Docs & DevOps
      md: 'markdown', markdown: 'markdown',
      dockerfile: 'docker',
      cmake: 'cmake',
      diff: 'diff', patch: 'diff',
      lock: 'yaml',
    };

    return map[e] || null;
  }

  function escapeHtml(str: string): string {
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  function highlightToLines(rawCode: string, langName: string | null): string[] {
    if (!rawCode) return [];
    
    // Normalize line breaks for cross-platform and Windows CRLF support
    const normalized = rawCode.replace(/\r\n/g, '\n').replace(/\r/g, '\n');

    let grammar = langName ? Prism.languages[langName] : null;
    if (!grammar && langName && Prism.languages.clike) {
      grammar = Prism.languages.clike;
    }

    if (!grammar) {
      return normalized.split('\n').map(l => escapeHtml(l) || '&nbsp;');
    }

    try {
      const rawHtml = Prism.highlight(normalized, grammar, langName || 'clike');
      const resultLines: string[] = [];
      let currentLine = '';
      const openTags: string[] = [];

      // Match complete tags, newlines, text up to next tag/newline, or stray <
      const tokenRegex = /(<\/?[a-zA-Z0-9_-]+[^>]*>|\n|[^\n<]+|<)/g;
      let match: RegExpExecArray | null;

      while ((match = tokenRegex.exec(rawHtml)) !== null) {
        const part = match[0];
        if (part === '\n') {
          for (let i = openTags.length - 1; i >= 0; i--) {
            currentLine += '</span>';
          }
          resultLines.push(currentLine || '&nbsp;');
          currentLine = openTags.join('');
        } else if (part.startsWith('</')) {
          openTags.pop();
          currentLine += part;
        } else if (part.startsWith('<') && !part.endsWith('/>') && part !== '<') {
          openTags.push(part);
          currentLine += part;
        } else {
          currentLine += part;
        }
      }
      resultLines.push(currentLine || '&nbsp;');
      return resultLines;
    } catch (e) {
      console.warn('Highlight failed, falling back to plain text:', e);
      return normalized.split('\n').map(l => escapeHtml(l) || '&nbsp;');
    }
  }

  $: prismLang = getPrismLanguage(file.extension, file.fileName);
  $: highlightedLines = highlightToLines(content, prismLang);
</script>

<div class="code-container">
  <div class="code-toolbar">
    <div class="toolbar-meta">
      <span class="badge-lang">{(file.extension || 'TXT').toUpperCase()}</span>
      <span class="line-count">{highlightedLines.length} {t('lines', lang)}</span>
    </div>
    <button class="copy-btn" on:click={copyText}>
      {#if copied}
        <span class="copied-indicator">{t('code_copied', lang)}</span>
      {:else}
        <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
          <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
        </svg>
        <span>{t('copy_code', lang)}</span>
      {/if}
    </button>
  </div>

  <div class="code-scroll-area">
    <pre class="code-pre"><code>{#each highlightedLines as lineHtml, idx}<div class="code-line"><span class="line-num">{idx + 1}</span><span class="line-text">{@html lineHtml}</span></div>{/each}</code></pre>
  </div>
</div>

<style>
  .code-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    width: 100%;
    background: var(--bg-card);
    overflow: hidden;
  }

  .code-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 16px;
    background: var(--bg-subtle);
    border-bottom: 1px solid var(--border-color);
  }

  .toolbar-meta {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 12px;
  }

  .badge-lang {
    background: var(--accent);
    color: white;
    font-size: 11px;
    font-weight: 600;
    padding: 2px 6px;
    border-radius: 4px;
  }

  .line-count {
    color: var(--text-muted);
    font-family: 'JetBrains Mono', monospace;
  }

  .copy-btn {
    background: transparent;
    border: 1px solid var(--border-color);
    color: var(--text-main);
    padding: 4px 10px;
    border-radius: 6px;
    font-size: 12px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
    transition: all 0.15s ease;
  }

  .copy-btn:hover {
    background: var(--bg-hover);
    border-color: var(--border-hover);
  }

  .copied-indicator {
    color: #22c55e;
    font-weight: 500;
  }

  .code-scroll-area {
    flex: 1;
    overflow-y: auto;
    overflow-x: hidden;
    padding: 12px 0;
    user-select: text;
  }

  .code-pre {
    margin: 0;
    font-family: 'JetBrains Mono', 'Consolas', 'Courier New', monospace;
    font-size: 13px;
    line-height: 1.6;
  }

  .code-line {
    display: flex;
    padding: 0 16px;
    line-height: 1.6;
  }

  .code-line:hover {
    background: var(--bg-hover);
  }

  .line-num {
    width: 44px;
    text-align: right;
    padding-right: 16px;
    color: var(--text-dim);
    user-select: none;
    flex-shrink: 0;
  }

  .line-text {
    flex: 1;
    white-space: pre-wrap;
    word-break: break-word;
    overflow-wrap: anywhere;
    color: var(--text-main);
  }

  /* Prism Token Highlighting - Dark Mode (Default) */
  :global(.token.comment),
  :global(.token.prolog),
  :global(.token.doctype),
  :global(.token.cdata) {
    color: #768390 !important;
    font-style: italic;
  }
  :global(.token.punctuation) {
    color: #abb2bf !important;
  }
  :global(.token.property),
  :global(.token.tag),
  :global(.token.boolean),
  :global(.token.number),
  :global(.token.constant),
  :global(.token.symbol),
  :global(.token.deleted) {
    color: #e5c07b !important;
  }
  :global(.token.selector),
  :global(.token.attr-name),
  :global(.token.string),
  :global(.token.char),
  :global(.token.builtin),
  :global(.token.inserted) {
    color: #98c379 !important;
  }
  :global(.token.operator),
  :global(.token.entity),
  :global(.token.url),
  :global(.token.variable) {
    color: #56b6c2 !important;
  }
  :global(.token.atrule),
  :global(.token.attr-value),
  :global(.token.keyword) {
    color: #c678dd !important;
    font-weight: 600;
  }
  :global(.token.function),
  :global(.token.class-name),
  :global(.token.type) {
    color: #61afef !important;
  }
  :global(.token.regex),
  :global(.token.important) {
    color: #d19a66 !important;
  }
  :global(.token.key) {
    color: #e06c75 !important;
  }
  :global(.token.parameter) {
    color: #e5c07b !important;
  }
  :global(.token.annotation),
  :global(.token.decorator),
  :global(.token.macro) {
    color: #56b6c2 !important;
  }

  /* Prism Token Highlighting - Light Mode Adaptations */
  :global([data-theme="light"] .token.comment) { color: #6e7781 !important; font-style: italic; }
  :global([data-theme="light"] .token.punctuation) { color: #24292f !important; }
  :global([data-theme="light"] .token.property),
  :global([data-theme="light"] .token.boolean),
  :global([data-theme="light"] .token.number),
  :global([data-theme="light"] .token.constant) { color: #953800 !important; }
  :global([data-theme="light"] .token.string),
  :global([data-theme="light"] .token.char) { color: #0a3069 !important; }
  :global([data-theme="light"] .token.keyword),
  :global([data-theme="light"] .token.atrule) { color: #cf222e !important; font-weight: 600; }
  :global([data-theme="light"] .token.function),
  :global([data-theme="light"] .token.class-name),
  :global([data-theme="light"] .token.type) { color: #8250df !important; }
  :global([data-theme="light"] .token.operator),
  :global([data-theme="light"] .token.entity) { color: #0969da !important; }
  :global([data-theme="light"] .token.key) { color: #cf222e !important; }
  :global([data-theme="light"] .token.parameter) { color: #953800 !important; }
  :global([data-theme="light"] .token.annotation),
  :global([data-theme="light"] .token.decorator),
  :global([data-theme="light"] .token.macro) { color: #116329 !important; }
</style>
