# PeekIt: Журнал оперативной работы и исправления багов (Worklog)

В данном файле в реальном времени фиксируются все действия по диагностике, внесению правок, тестированию и сборке релизов.

---

## Формат записей

Каждая запись содержит:
- **Метка времени (ГГГГ-ММ-ДД ЧЧ:ММ):** точное время фиксации действия.
- **Идентификатор:** `[BUG-XXX]`, `[FEAT-XXX]` или `[REL-XXX]`.
- **Этап:** `[Диагностика]`, `[Разработка]`, `[Тестирование]`, `[Сборка]`, `[Завершено]`.
- **Описание:** что было исследовано, изменено или проверено.
- **Затронутые файлы:** ссылки на модифицированные файлы.
- **Результат / Статус:** текущий статус инцидента.

---

## Хронологический лог операций

### 2026-09-07

#### [2026-09-07 05:20] • [BUG-001 / BUG-002] • [Диагностика]
- **Цель:** Исследование причин бесконечного вращения спиннера во вкладке «Плагины» и отсутствия реактивного обновления статусов кнопок при установке/удалении.
- **Анализ кода:**
  - В файле [`src/lib/stores/plugins.svelte.ts`](file:///d:/Projects/active/PeekIt/src/lib/stores/plugins.svelte.ts) класс `PluginRegistry` использует руны Svelte 5 (`$state`).
  - В файле [`src/lib/components/settings/PluginsTab.svelte`](file:///d:/Projects/active/PeekIt/src/lib/components/settings/PluginsTab.svelte) компонент работает в Svelte 4 legacy mode (`export let`, `$:`, `on:click`).
  - Компилятор Svelte в legacy mode не создаёт реактивных подписок на мутации свойств внешнего класса `pluginRegistry.isLoading` и `pluginRegistry.plugins`. В результате при асинхронном завершении запроса к Rust локальные переменные не меняются, и перерисовка UI не происходит.
  - Обнаружен неэффективный таймер `pollInterval = setInterval(..., 1500)`, который нагружает диск каждые 1.5 с, но не решает проблему реактивности.
- **Статус:** Причина локализована на 100%. Намечено решение с локальными реактивными переменными.

---

#### [2026-09-07 05:25] • [FEAT-001] • [Проектирование]
- **Цель:** Проектирование поддержки плагинов для просмотра папок.
- **Анализ кода:**
  - Windows Shell API (`IFolderView::Items(SVGIO_SELECTION)`) в [`explorer.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/explorer.rs) уже возвращает пути к папкам.
  - В [`preview.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/preview.rs) папки определялись как `generic` с размером `0 B`.
  - Спроектирован интерфейс поверхностного чтения `read_folder_entries` (первый уровень до 1000 элементов, перехват `PermissionDenied`) и создание встроенного плагина `Folder Viewer` (`com.peekit.folder-viewer`).
- **Статус:** Архитектура согласована, оформлена в плане.

---

#### [2026-09-07 05:28] • [REL-001] • [Инициализация трекера]
- **Действие:**
  - Создана папка [`bugs/`](file:///d:/Projects/active/PeekIt/bugs).
  - Сформирован сводный реестр инцидентов [`bugs/buglist.md`](file:///d:/Projects/active/PeekIt/bugs/buglist.md).
  - Размещён утверждённый план версии 1.3.0 [`bugs/v1.3.0_plan.md`](file:///d:/Projects/active/PeekIt/bugs/v1.3.0_plan.md).
  - Создан данный оперативный журнал [`bugs/worklog.md`](file:///d:/Projects/active/PeekIt/bugs/worklog.md).
- **Статус:** Трекер развёрнут и готов к фиксации последующих шагов.

---

#### [2026-09-07 05:34] • [BUG-001 / BUG-002] • [Разработка]
- **Цель:** Устранение проблем реактивности в компоненте настроек плагинов: ликвидация залипающего спиннера (BUG-001) и обеспечение мгновенного обновления кнопок/списка (BUG-002).
- **Выполненные действия:**
  - В [`src/lib/stores/plugins.svelte.ts`](file:///d:/Projects/active/PeekIt/src/lib/stores/plugins.svelte.ts) метод `loadPlugins()` теперь возвращает `Promise<PluginInfo[]>`. В `findPluginForFile` добавлена поддержка флага `isFolder` и селектора `"<folder>"`.
  - В [`src/lib/components/settings/PluginsTab.svelte`](file:///d:/Projects/active/PeekIt/src/lib/components/settings/PluginsTab.svelte):
    - Введены локальные реактивные переменные `installedPlugins` и `isLoadingInstalled`.
    - Добавлена функция `refreshInstalled()`, синхронизирующая локальное состояние с `pluginRegistry`.
    - Все обработчики (`handleFileChange`, `handleInstallPkit`, `handleInstallFromStore`, `handleUninstallPlugin`, `handleTogglePlugin`) теперь сразу вызывают `await refreshInstalled()`.
    - `getPluginStatus` проверяет `installedPlugins`, что обеспечивает мгновенное изменение состояния кнопок «Установить» ➔ «Установлено» без перезапуска.
    - Шаблон списка плагинов переключен на `isLoadingInstalled` и `installedPlugins`, ликвидируя зависающий спиннер.
    - Полностью удалён неэффективный таймер `pollInterval = setInterval(..., 1500)`.
- **Статус:** Код изменен, готов к проверке типов. Инциденты BUG-001 и BUG-002 устранены в коде.

---

#### [2026-09-07 05:38] • [FEAT-001] • [Разработка]
- **Цель:** Реализация поддержки превью папок для плагинов на бэкенде Rust и фронтенде Svelte.
- **Выполненные действия:**
  - В [`src-tauri/src/preview.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/preview.rs):
    - Добавлены структуры `FolderItem` и `FolderStats`.
    - `FileExtraInfo` расширена полями `folder_items` и `folder_stats`.
    - Реализована функция `read_folder_entries(path_str)` с безопасным ограничением (до 1000 элементов) и сортировкой (папки сначала, затем файлы по алфавиту).
    - В `inspect_file` добавлена обработка `if metadata.is_dir()`: выставляется категория `folder`, расширение `<folder>`, вычисляются статистика и общий размер первого уровня.
  - В [`src-tauri/src/commands.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/commands.rs) добавлена команда `read_folder_entries`, зарегистрирована в `invoke_handler` в [`src-tauri/src/lib.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/lib.rs).
  - В [`src-tauri/src/plugins/manifest.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/plugins/manifest.rs) селекторы `<folder>` и `folder` нормализуются без добавления ведущей точки.
  - В [`src/lib/types.ts`](file:///d:/Projects/active/PeekIt/src/lib/types.ts) добавлены типы `FolderItem`, `FolderStats`, категория `folder`.
  - В [`src/routes/+page.svelte`](file:///d:/Projects/active/PeekIt/src/routes/+page.svelte) в вызовы `findPluginForFile` передан флаг `isFolder: currentFile.category === 'folder'`.
  - В [`src/lib/plugins/protocol.ts`](file:///d:/Projects/active/PeekIt/src/lib/plugins/protocol.ts) и [`src/lib/components/PluginHost.svelte`](file:///d:/Projects/active/PeekIt/src/lib/components/PluginHost.svelte) в `init-file` передаётся `extra`, а также добавлены обработчики `PEEKIT_OPEN_FILE` и `PEEKIT_REVEAL_FILE`.
  - В [`src/lib/components/GenericPreview.svelte`](file:///d:/Projects/active/PeekIt/src/lib/components/GenericPreview.svelte) добавлено аккуратное fallback-отображение для папок с иконкой папки и числом элементов первого уровня.
- **Статус:** Бэкенд и фронтенд ядра готовы.

---

#### [2026-09-07 05:42] • [FEAT-001] • [Создание плагина Folder Viewer]
- **Цель:** Разработка официального автономного встроенного плагина `Folder Viewer` (`com.peekit.folder-viewer`) в `plugins/peekit-plugin-folder/`.
- **Выполненные действия:**
  - Создан `plugins/peekit-plugin-folder/manifest.json` с идентификатором `com.peekit.folder-viewer`, версией 1.0.0 и селектором `extensions: ["<folder>"]`.
  - Создан `plugins/peekit-plugin-folder/index.html` (адаптивная панель с поиском, сортировкой, иконками типов файлов, бейджами, поддержкой светлой/тёмной тем и двойным кликом для открытия).
- **Статус:** Плагин создан и готов к бандлингу.

---

#### [2026-09-07 05:45] • [REL-001] • [Сборка релиза v1.3.0]
- **Цель:** Подготовка и сборка релизных дистрибутивов v1.3.0 (Setup EXE, MSI, Portable ZIP).
- **Выполненные действия:**
  - Версия поднята до 1.3.0 в `package.json`, `src-tauri/Cargo.toml`, `src-tauri/tauri.conf.json` и `SettingsModal.svelte`.
  - Успешно пройдена проверка типов `npm run check` (0 ошибок).
  - Успешно пройдена проверка компиляции бэкенда `cargo check` (0 предупреждений/ошибок).
  - Выполнена полная оптимизированная сборка `npm run tauri build` с кодом выхода 0.
- **Статус:** Компиляция завершена успешно.

---

#### [2026-09-07 05:47] • [REL-001 / BUG-001 / BUG-002 / FEAT-001] • [Упаковка и верификация]
- **Цель:** Упаковка дистрибутивов в `output/`, создание Portable ZIP с плагинами и `portable.txt`, вычисление контрольных сумм SHA-256.
- **Выполненные действия:**
  - Скопированы NSIS установщик и MSI пакет в папку `output/`.
  - Сформирована структура портабельной сборки `output/Peekit_v1.3.0_Portable/`, включая `peekit.exe`, флаг-файл `portable.txt` и встроенные плагины (включая новый `Folder Viewer`).
  - Создан архив `output/Peekit_v1.3.0_Portable.zip`.
  - Рассчитаны контрольные суммы SHA-256:
    - `Peekit_1.3.0_x64-setup.exe` (3,590,710 байт) -> `55A222E482E047082C1A3D070CDB4BCEECD9ABD2EFCA6B144FB425A52AA058F7`
    - `Peekit_1.3.0_x64_en-US.msi` (5,771,264 байт) -> `0D64BA53EE30B4960A88FA03D986646D030D984FEA12BA776E9D9DCD5B64F8E4`
    - `Peekit_v1.3.0_Portable.zip` (5,396,840 байт) -> `0B025BA29603EDF93D798497096518C48D525A30271D7767695D25BD1D32D612`
  - Создан файл релизных заметок [`RELEASE_NOTES_v1.3.0.md`](file:///d:/Projects/active/PeekIt/RELEASE_NOTES_v1.3.0.md).
- **Статус:** [Завершено] Все задачи спринта (BUG-001, BUG-002, FEAT-001, REL-001) успешно выполнены и закрыты.

---

#### [2026-09-07 06:23] • [BUG-003] • [Диагностика]
- **Цель:** Исследование причин неработающей фильтрации по категориям во вкладке «Магазин плагинов».
- **Симптомы:** Пользователь сообщил, что у большинства плагинов не отображаются категории и кнопки фильтрации не дают результатов, несмотря на то что в каталоге `registry.json` все 12 плагинов имеют проставленные категории.
- **Анализ:**
  - Запрос `registry.json` с GitHub Pages подтвердил наличие поля `category` у всех 12 плагинов.
  - Категории в реестре: `3D`, `Documents`, `Fonts`, `Spreadsheets`, `Presentations`, `Graphics`, `Utilities`.
  - Массив `categories[]` в [`PluginsTab.svelte:192`](file:///d:/Projects/active/PeekIt/src/lib/components/settings/PluginsTab.svelte#L192-L199) содержит: `all`, `graphics`, `3d`, `document`, `font`, `spreadsheet`.
  - **Root Cause:** `getEffectiveCategory(plugin)` (строка 201) вызывает `plugin.category.toLowerCase()` → `"documents"`, но фильтр сравнивает с `"document"` (без `s`) → `"documents" !== "document"` → плагин скрывается.
  - Категории `Presentations` и `Utilities` из реестра отсутствуют в массиве `categories[]` → плагины `slides-viewer`, `apk-viewer`, `sqlite-viewer` не попадают ни в одну группу.
- **Затронутые файлы:** [`PluginsTab.svelte`](file:///d:/Projects/active/PeekIt/src/lib/components/settings/PluginsTab.svelte) (строки 192–221, 224–278).
- **Статус:** Причина локализована на 100%. Ожидает подтверждения на исправление.

---

#### [2026-09-07 06:27] • [BUG-003] • [Разработка]
- **Цель:** Исправление рассинхронизации категорий между `registry.json` и фронтенд-кодом.
- **Выполненные действия в [`PluginsTab.svelte`](file:///d:/Projects/active/PeekIt/src/lib/components/settings/PluginsTab.svelte):**
  - **`categories[]` (строка 192):** Приведены ключи к формату реестра: `document` → `documents`, `font` → `fonts`, `spreadsheet` → `spreadsheets`. Добавлены: `presentations` (Презентации), `utilities` (Утилиты).
  - **`getEffectiveCategory()` (строка 201):** Fallback-возвраты обновлены (`'fonts'`, `'spreadsheets'`, `'documents'`). Добавлены ветки для `presentations` (.pptx, .ppt, .key, .odp) и `utilities` (.apk, .db, .sqlite). Расширения `.dds` добавлены в `graphics`.
  - **`getCategoryLabel()` (строка 224):** Все case обновлены на плюрализованные ключи, добавлены `presentations` и `utilities` с RU/EN переводами.
  - **`getCategoryColor()` (строка 263):** Все case обновлены, добавлены цвета: `presentations` (жёлтый #eab308) и `utilities` (серый #9ca3af).
- **Верификация:** `npm run check` — 0 ошибок. Сборка успешно завершена (`npm run tauri build`, exit code 0). Дистрибутивы упакованы в `output/`.
- **Статус:** Разработка и сборка завершены.

---

#### [2026-09-07 06:31] • [BUG-003] • [Верификация и закрытие]
- **Цель:** Проверка работы фильтра категорий плагинов в собранном приложении и фиксация результатов.
- **Результаты тестирования:**
  - Пользователь подтвердил: фильтрация и отображение категорий плагинов работают штатно.
  - Категории (`3D`, `Графика`, `Документы`, `Шрифты`, `Таблицы`, `Презентации`, `Утилиты`) корректно фильтруют каталог `registry.json`.
  - Все три дистрибутива в `output/` актуализированы (v1.3.0 hotfix):
    - `Peekit_1.3.0_x64-setup.exe` (SHA256: `F28655C56E045DB82001C2AE0127FFD9791E3DD8D7D0577B6836F84F6BB2F92C`)
    - `Peekit_1.3.0_x64_en-US.msi` (SHA256: `16A68662C1EFA8303290C86093A5BFA95EABDE3EF3D9FF0849C20478AC41EDDD`)
    - `Peekit_v1.3.0_Portable.zip` (SHA256: `972E1540DC8E63FFA3380CA019CEF9673ECE426898980385557371C67018A801`)
- **Статус:** [Завершено] Баг BUG-003 успешно решен, проверен и закрыт.

---

#### [2026-09-07 09:28] • [BUG-004] • [Диагностика]
- **Цель:** Первичный анализ и локализация проблемы неработающего пункта «Выход» в системном меню/трее.
- **Симптомы:** При нажатии «Выход» в трей-меню приложение не закрывается.
- **Анализ кода:**
  - В [`src-tauri/src/lib.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/lib.rs) строка 175: в `tauri::RunEvent::ExitRequested` безусловно вызывается `api.prevent_exit()`.
  - Когда меню вызывает `app.exit(0)`, Tauri посылает `ExitRequested`, который немедленно отменяется.
  - В результате процесс PeekIt блокирует собственное завершение.
- **Предлагаемое решение:** Ввести флаг `IS_QUITTING` или использовать `std::process::exit(0)` при клике на выход.
- **Статус:** Investigating / Open

---

#### [2026-09-07 09:37] • [BUG-004] • [Разработка]
- **Цель:** Устранение блокировки выхода при нажатии на пункт «Выход» в меню трея.
- **Выполненные действия:**
  - В [`src-tauri/src/lib.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/lib.rs) возвращён прямой системный вызов `std::process::exit(0)` в обработчике `"quit"`.
- **Статус:** In Progress

---

#### [2026-09-07 09:55] • [BUG-004] • [Верификация и завершение]
- **Цель:** Верификация закрытия инцидента BUG-004, прохождение тестов и выпуск в релизе v1.3.2.
- **Выполненные действия:**
  - Проверено поведение завершения процесса в коде Rust: при клике на трей-меню `"quit"` вызывается прямой системный `std::process::exit(0)`.
  - Успешно пройдены проверки `npm run check` (0 ошибок) и `cargo test` (4/4 passed).
  - Собраны релизные бандлы `Peekit_1.3.2_x64-setup.exe`, `Peekit_1.3.2_x64_en-US.msi` и `Peekit_v1.3.2_Portable.zip`.
- **Статус:** [Завершено] Инцидент BUG-004 успешно решён и закрыт.
