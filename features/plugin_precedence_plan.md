# FEAT-003: Наивысший приоритет установленных плагинов над встроенными вьюерами

## Описание задачи
В экосистемах расширяемых приложений (QuickLook, VS Code, Obsidian) установленные и включённые плагины имеют абсолютный приоритет над встроенными по умолчанию просмотрщиками.

В текущей реализации PeekIt ([`+page.svelte:396-422`](file:///d:/Projects/active/PeekIt/src/routes/+page.svelte#L396-L422)) условия проверялись в следующем порядке:
1. `video` / `audio` -> `<MediaPreview />`
2. `image` -> `<ImagePreview />`
3. `pdf` -> `<PdfPreview />`
4. `archive` -> `<ArchivePreview />`
5. `activePlugin` -> `<PluginHost />`
6. `code` / `text` -> `<CodePreview />`
7. `markdown` -> `<MarkdownPreview />`
8. `fallback` -> `<GenericPreview />`

Из-за этого любые специализированные плагины для видео (например, `peekit-plugin-video`), аудио, изображений, PDF или архивов блокировались встроенными компонентами и никогда не активировались.

## Предлагаемое решение

Изменить порядок маршрутизации просмотрщиков в [`src/routes/+page.svelte`](file:///d:/Projects/active/PeekIt/src/routes/+page.svelte):
1. Если файл не выбран (`!currentFile`) — `<EmptyState />`
2. **Если найден и включён плагин (`activePlugin`) — `<PluginHost />`** (наивысший приоритет)
3. Иначе — встроенные дефолтные вьюеры по категориям:
   - `video` / `audio` -> `<MediaPreview />`
   - `image` -> `<ImagePreview />`
   - `pdf` -> `<PdfPreview />`
   - `archive` -> `<ArchivePreview />`
   - `code` / `text` -> `<CodePreview />`
   - `markdown` -> `<MarkdownPreview />`
   - Остальные типы и fallback -> `<GenericPreview />`

Также в [`src/routes/+page.svelte`](file:///d:/Projects/active/PeekIt/src/routes/+page.svelte):
- В обработчике закрытия настроек `handleCloseSettings()` добавить принудительный пересчёт `activePlugin`, если окно предпросмотра активно с открытым файлом (чтобы при включении/отключении плагина в настройках превью мгновенно переключалось между плагином и дефолтным просмотрщиком).

---

## Предлагаемые изменения

### Frontend Router

#### [`+page.svelte`](file:///d:/Projects/active/PeekIt/src/routes/+page.svelte)
- Переместить ветку `{:else if activePlugin}` непосредственно после `{#if !currentFile}`.
- Проверить обновление `activePlugin` при закрытии модального окна настроек.

```svelte
<!-- Central Dynamic Viewer Body -->
<section class="viewer-body">
  {#if !currentFile}
    <div class="empty-state">
      ...
    </div>
  {:else if activePlugin}
    <PluginHost
      plugin={activePlugin}
      file={currentFile}
      theme={settings.theme}
      language={settings.language}
    />
  {:else if currentFile.category === 'video' || currentFile.category === 'audio'}
    <MediaPreview
      file={currentFile}
      lang={settings.language}
      autoplay={settings.autoplayMedia}
      initialVolume={settings.volume}
    />
  {:else if currentFile.category === 'image'}
    <ImagePreview file={currentFile} lang={settings.language} />
  {:else if currentFile.category === 'pdf'}
    <PdfPreview file={currentFile} lang={settings.language} />
  {:else if currentFile.category === 'archive'}
    <ArchivePreview file={currentFile} lang={settings.language} />
  {:else if currentFile.category === 'code' || currentFile.category === 'text'}
    <CodePreview file={currentFile} content={textContent} lang={settings.language} />
  {:else if currentFile.category === 'markdown'}
    <MarkdownPreview file={currentFile} content={textContent} lang={settings.language} />
  {:else}
    <GenericPreview file={currentFile} lang={settings.language} onOpenApp={openWithDefaultApp} />
  {/if}
</section>
```

---

## План верификации

### Автоматические проверки
- Запуск `npm run check` (Svelte/TypeScript проверка типов).

### Ручная проверка
1. Проверка файла, для которого установлен плагин (например, папка при наличии `Folder Viewer` или видеофайл при наличии `Video Viewer`): отображается плагин в `PluginHost`.
2. Отключение плагина в Настройках -> Плагины: повторное открытие файла отображает стандартный просмотрщик (`GenericPreview` для папки, `MediaPreview` для видео).
3. Включение плагина обратно: снова активируется `PluginHost`.
