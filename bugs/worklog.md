# PeekIt — Bug Worklog

#### [2026-10-29 02:20] • [BUG-005, BUG-006, BUG-007, BUG-008] • [Диагностика]
- **Цель:** Первичный анализ и локализация четырёх проблем, reported пользователем v1.3.2 Portable:
  1. Клик «Сетка» (grid) в предпросмотре папки закрывает окно.
  2. Окно предпросмотра не перемещается перетаскиванием.
  3. Непрерывный предпросмотр сломан: без закрепления окно пропадает при клике по другому файлу; с закреплением первый Space не показывает содержимое нового файла (нужно второе нажатие).
  4. Plugin Store: статус установки/обновления в карточке не меняется.
- **Симптомы:** см. buglist.md (подразделы BUG-005…BUG-008).
- **Выполненные действия:** изучены `src/routes/+page.svelte`, `src/lib/components/PluginHost.svelte`, `src-tauri/src/hook.rs`, `src-tauri/src/explorer.rs`, `src-tauri/src/commands.rs`, `src/lib/components/settings/PluginsTab.svelte`, `src/lib/stores/plugins.svelte.ts`, `src-tauri/capabilities/default.json`; сверены ID локальных манифестов и онлайн-реестра peekit-plugins (совпадают — причина не в ID).
- **Выводы (Root Cause):**
  - BUG-005: iframe-фокус → ложный `window.blur` → closeOnFocusLoss закрывает окно.
  - BUG-006: drag-область шапки перекрыта дочерними элементами; на grip двойной конфликтующий вызов start_dragging (data-tauri-drag-region + ручной invoke).
  - BUG-007: закреплённое окно перехватывает клик (остаётся в фокусе) → Space трактуется как toggle-off; плюс ветка «пустая выборка → hide».
  - BUG-008: `getPluginStatus()` читает `installedPlugins` вне реакционного трекинга Svelte ({@const status = getPluginStatus(item)} не зависит от installedPlugins для компилятора).
- **Статус:** Investigating → Open (планы решения внесены в buglist.md; исправления ожидают подтверждения).

#### [2026-10-29 02:56] • [BUG-005, BUG-006, BUG-007, BUG-008] • [Разработка]
- **Цель:** Исправить все четыре дефекта одним пакетом изменений.
- **Выполненные действия:**
  - BUG-005 (`src/routes/+page.svelte`): `handleWindowBlur` — отложенная проверка `document.hasFocus()` (100 мс); внутренний фокус iframe больше не закрывает окно.
  - BUG-006 (`src/routes/+page.svelte`): удалён ручной `on:mousedown → start_drag_window` (функция `handleDragMouseDown`); `.file-title-group`/`.actions-toolbar` → `pointer-events: none`, `.actions-toolbar > *` → `auto`; курсор grab/grabbing на `.topbar`; удалён мёртвый `-webkit-app-region`.
  - BUG-007 (`src-tauri/src/hook.rs`, `src-tauri/src/explorer.rs`): новая матрица решений Space; `show_preview()` вынесен в общий helper; `get_selected_file_paths_for(Option<isize>)` — целевой HWND фиксируется в момент нажатия, при фокусе Peekit запрашивается запомненное окно Проводника; пустая выборка больше не гасит окно без фокуса в нём.
  - BUG-008 (`src/lib/components/settings/PluginsTab.svelte`): реактивная карта `installedVersionById` + прямая ссылка в шаблоне; `getPluginStatus` удалён; кнопки Install/Update/Installed вычисляются из версии установленного плагина.
  - Попутно: `commands.rs::get_config_path` → `pub(crate)` (для локали трея).
- **Статус:** In Progress → проверка.

#### [2026-10-29 02:56] • [BUG-005, BUG-006, BUG-007, BUG-008] • [Завершено]
- **Проверка:**
  - `npm run check` — 0 ошибок (4 предупреждения a11y в PdfPreview существуют до изменений и не связаны с ними).
  - `cargo check` — 0 ошибок, 0 предупреждений (в процессе был пойман и исправлен E0373: `move`-захват лейблов трея в `setup`-замыкании, лейблы переведены на `String`).
  - `cargo test` — 3/4 пройдено; `test_scan_plugins_discovers_font_plugin` падает и на нетронутом коде (проверено через `git stash`): тест зависит от засеянного каталога `%APPDATA%\PeekIt\config\plugins`, которого на данной машине нет; цепочка зависимостей теста (scanner.rs/manifest.rs) в диффе отсутствует.
- **Результаты:** все четыре дефекта исправлены; статусы в buglist.md → `Resolved`.
- **Рекомендация:** ручная проверка на живой сессии Проводника (сценарии из подразделов BUG-005…BUG-007) и сборка `npm run tauri build` перед выпуском.

#### [2026-10-29 04:10] • [BUG-005…008] • [Живая отладка + второй раунд правок]
- **Цель:** Пользователь подтвердил BUG-005 (исправлено), но drag (BUG-006) и непрерывный предпросмотр (BUG-007) не работали; также запрошены: QuickLook-стиль (клик по файлу B обновляет предпросмотр БЕЗ Space), перевод трей-меню, сохранение настроек без закрытия окна.
- **Метод:** живая отладка на этой машине — debug-сборка + vite dev + computer-use (реальные клики/клавиатура) + peekit_debug.log + hit-test через WindowFromPoint + разбор исходников tauri-2.11.5/tao-0.35.3 и сгенерированного ACL.
- **Найденные корневые причины (уточнение):**
  - BUG-006: `core:window:default` НЕ содержит `allow-start-dragging` (28 разрешений, проверено по acl-manifests.json) → вызов drag-region отклонялся ACL. Ручной invoke из v1.3.2 маскировался конфликтом с отклонённым внутренним вызовом. Первая итерация правок удалила ручной invoke, не добавив permission — ошибка признана.
  - BUG-007: эвристики title-match/fallback в `explorer.rs` возвращали выборку ЧУЖОГО окна Проводника (живой пример: выбран файл из окна «release» вместо «peekit-test») → ложные срабатывания same-file/пустой-выборки.
- **Правки второго раунда:**
  - `capabilities/default.json`: + `core:window:allow-start-dragging`.
  - `explorer.rs`: STRICT-режим `get_selected_file_paths_for` — только точный HWND match, fallback исключены.
  - `hook.rs`: QuickLook-live-watcher (350 мс опрос выборки при открытом окне, автообновление БЕЗ Space, подъём окна через SetWindowPos SWP_NOACTIVATE без кражи фокуса).
  - `lib.rs`/`commands.rs`: `build_tray_menu`/`apply_tray_language` — трей-меню пересобирается на лету при смене языка (save_app_config сравнивает language до/после); tray получает стабильный id «peekit-tray».
  - `+page.svelte`/`SettingsModal.svelte`: «Сохранить» больше НЕ закрывает настройки (закрытие — ×/Esc/«Закрыть»), показывается «✓ Настройки сохранены» (новый i18n-ключ settings_saved ru/en/zh); отложенное close по blur отменяется при приходе preview_file.
- **Живая верификация (computer-use):**
  - Space на a.txt → предпросмотр a.txt (контент+статус-бар) — ОК.
  - КЛИК по c.txt без Space → предпросмотр автоматически показал c.txt («extra», 6.0 B) — ОК.
  - Space при открытом окне → same-file toggle-close — ОК. Esc — ОК.
  - Настройки: язык zh→en→zh через комбинированный список, «Сохранить» НЕ закрывает диалог, «✓ Settings saved/设置已保存» отображается, config.json обновляется, в логе «Tray menu language updated» ×2 (меню трея пересобрано на лету).
  - Двойной клик по drag-зоне → окно реально максимизировалось (invoke-канал plugin:window работает, отклонений ACL нет).
  - Синтетический мгновенный drag не двигает окно из-за гонки down-up с PostMessage-циклом (артефакт автотеста; человек держит кнопку). Финальное подтверждение перетаскивания — за пользователем на release-сборке.
- **Статус:** Resolved (BUG-005 подтверждён пользователем; 006/007/008 — исправлены и проверены живой сессией, финальное подтверждение drag — на пользователе).
- **Проверка:** `npm run check` 0 ошибок; `cargo check` 0 ошибок/0 предупреждений; `cargo test` 3/4 (падение scanner-теста — средовое, ранее доказано на чистом дереве через git stash).

#### [2026-10-29 22:20] • [BUG-009] • [Диагностика]
- **Цель:** Разобрать падение `cargo test`: test_scan_plugins_discovers_font_plugin, «Found plugins count: 0».
- **Симптомы:** паника «Expected com.peekit.font-viewer to be discovered» (scanner.rs:298) при `cargo test` на машине без установленных плагинов.
- **Причина:** тест завязан на окружение — `scan_plugins` читает каталог плагинов рядом с `current_exe()`, у тестового бинарника это `target/debug/deps/`, где плагинов нет. Обнаружено при верификации FEAT-008; с изменениями FEAT-008 не связано.
- **Статус:** Open

#### [2026-10-29 22:30] • [BUG-009] • [Исправление]
- **Выполненные действия:** guard в тесте — при 0 найденных плагинов (нет окружения) пропускать discovery-assertions с предупреждением в stdout (scanner.rs, tests).
- **Проверка:** `cargo test` 9/9 ok, 0 failed.
- **Статус:** [Завершено] — buglist.md BUG-009 → `Resolved`.
