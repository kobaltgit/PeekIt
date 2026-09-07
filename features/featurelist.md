# PeekIt: Журнал внедрения нового функционала (Feature Tracker)

В данном файле ведётся реестр запланированных и реализованных функциональных возможностей (фич), их архитектурное проектирование, этапы внедрения и хронология работы.

---

## 1. Сводная таблица функционала (Features Backlog)

| ID | Категория | Название | Приоритет | Статус | Версия | Спецификация / План |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **[FEAT-001](#feat-001)** | Core / Plugins | Поддержка плагинов для просмотра содержимого папок | High | Completed | v1.3.0 | [v1.3.0_plan.md](file:///d:/Projects/active/PeekIt/bugs/v1.3.0_plan.md) |
| **[FEAT-002](#feat-002)** | System / UX | Система проверки и уведомления об обновлениях (Updater в стиле MiniBin) | Medium | Completed | v1.3.0 | [features/updater_plan.md](file:///d:/Projects/active/PeekIt/features/updater_plan.md) |
| **[FEAT-003](#feat-003)** | Core / Plugins | Приоритет установленных плагинов над встроенными вьюерами (Plugin Precedence) | High | Completed | v1.3.1 | [features/plugin_precedence_plan.md](file:///d:/Projects/active/PeekIt/features/plugin_precedence_plan.md) |
| **[FEAT-004](#feat-004)** | Core / Plugins | Системный диалог «Сохранить как...» для плагинов (Plugin Save Dialog API) | Medium | Completed | v1.3.1 | [features/worklog.md](file:///d:/Projects/active/PeekIt/features/worklog.md) |

---

## 2. Подробное описание фич

### <a id="feat-001"></a>FEAT-001: Архитектура просмотра папок для плагинов
* **Описание:** Позволяет пользователю просматривать содержимое директорий при нажатии клавиши Пробел в Проводнике Windows через встроенный автономный плагин `Folder Viewer` или внешние плагины.
* **Реализовано:**
  * Бэкенд Rust: безопасное поверхностное чтение директории (`read_folder_entries` в `preview.rs`), расчёт общего размера и статистики элементов первого уровня.
  * Фронтенд: обработка селектора `"<folder>"`, передача данных структуры в iframe плагина.
  * Встроенный плагин: `plugins/peekit-plugin-folder/` с поиском, иконками типов файлов и переходом к файлам в Проводнике.
* **Статус:** **Completed** (Релиз v1.3.0).

---

### <a id="feat-002"></a>FEAT-002: Система проверки и уведомления об обновлениях (в стиле MiniBin)
* **Цель:** Предоставить пользователю возможность узнавать о выходе новых версий PeekIt без сторонних зависимостей, с минимальным влиянием на размер бинарного файла и максимальной надежностью.
* **Ключевые требования и архитектура (по аналогии с MiniBin):**
  1. **Легковесный бэкенд на Rust (`src-tauri/src/updater.rs`):**
     * Запрос к GitHub API: `https://api.github.com/repos/kobaltgit/PeekIt/releases/latest`.
     * Использование нативного системного PowerShell `Invoke-RestMethod` в фоновом скрытом процессе (`CREATE_NO_WINDOW`). Нулевой прирост размера `.exe`, отсутствие тяжелых зависимостей (`reqwest`, `tokio-tls`).
     * Парсинг Semver: корректное покомпонентное сравнение номеров версий (`latest` vs `current`).
     * Автоматическое извлечение прямых ссылок на дистрибутивы из `assets`:
       * `setup_url` (`Peekit_*_setup.exe`)
       * `portable_url` (`Peekit_*_Portable.zip`)
       * `release_url` (страница релиза на GitHub)
       * `release_notes` (текст описания изменений)
  2. **Умный интервал и Cooldown:**
     * Фоновая проверка через 3 секунды после старта приложения, затем еженедельно (каждые 7 дней).
     * Защита от лимитов GitHub API: кулдаун 1 час между автопроверками при частых перезапусках.
     * Возможность принудительной ручной проверки по кнопке (`force: true`).
  3. **Нативные Windows Toast уведомления:**
     * Всплывающее уведомление Windows 10/11 при обнаружении новой версии (не более одного раза на конкретную версию релиза):
       > **PeekIt — Доступно обновление**  
       > *Вышла новая версия X.X.X. Нажмите, чтобы открыть окно загрузки.*
  4. **Пользовательский интерфейс (Frontend):**
     * Карточка в настройках `SettingsModal.svelte`:
       * Индикатор статуса версии (актуальная / доступно обновление).
       * Кнопка «Проверить сейчас» со спиннером анимации.
       * Кнопки прямого скачивания инсталлятора (`.exe`) и портабельной версии (`.zip`), а также ссылка на Release Notes.
       * Переключатель «Автоматически проверять обновления» (вкл/выкл).
     * Ненавязчивый бейдж-индикатор в шапке окна настроек при наличии новой версии.
* **Статус:** **Completed** (Реализовано, протестировано и собрано в составе v1.3.0).

---

### <a id="feat-003"></a>FEAT-003: Приоритет установленных плагинов над встроенными вьюерами (Plugin Precedence)
* **Цель:** Предоставить установленным и включённым плагинам наивысший приоритет маршрутизации предпросмотра перед встроенными компонентами (по аналогии с QuickLook, VS Code и Obsidian).
* **Архитектурные изменения:**
  * Перенос ветки `{:else if activePlugin}` на первое место сразу после `{#if !currentFile}` в [`src/routes/+page.svelte`](file:///d:/Projects/active/PeekIt/src/routes/+page.svelte).
  * Дефолтные вьюеры (`MediaPreview`, `ImagePreview`, `PdfPreview`, `ArchivePreview`, `CodePreview`, `MarkdownPreview`) выступают в роли fallback-просмотрщиков, когда плагин не установлен или отключён.
  * Обеспечение моментального пересчёта `activePlugin` при закрытии настроек после включения/отключения плагина.
* **Статус:** **Completed** (Реализовано в `+page.svelte`, скомпилированы и упакованы сборки v1.3.1 в `output/`).

---

### <a id="feat-004"></a>FEAT-004: Системный диалог Windows «Сохранить как...» для плагинов (Plugin Save Dialog API)
* **Цель:** Позволить плагинам (например, `com.peekit.video-player` для экспорта кадров/GIF/отрезков видео) вызывать нативный диалог сохранения Windows с предустановленным путём/именем файла и сохранять Base64-данные на диск через Tauri backend.
* **Архитектурные изменения:**
  * Добавление сообщения `PEEKIT_SAVE_FILE` в протокол хост-плагин ([`src/lib/plugins/protocol.ts`](file:///d:/Projects/active/PeekIt/src/lib/plugins/protocol.ts)).
  * Обработка `PEEKIT_SAVE_FILE` в [`src/lib/components/PluginHost.svelte`](file:///d:/Projects/active/PeekIt/src/lib/components/PluginHost.svelte), добавление sandbox-прав `allow-downloads allow-modals` и `allow="fullscreen; file-system-access"`.
  * Реализация команды Tauri `save_file_dialog_for_plugin` в Rust бэкенде ([`src-tauri/src/commands.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/commands.rs)) с использованием `tauri_plugin_dialog::DialogExt`.
  * Регистрация команды в [`src-tauri/src/lib.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/lib.rs).
  * Обновление текста версии 1.3.1 в окне «О программе» ([`SettingsModal.svelte`](file:///d:/Projects/active/PeekIt/src/lib/components/SettingsModal.svelte)).
* **Статус:** **Completed** (Проверено проверкой типов, тестами и полной сборкой дистрибутивов).

---

## 3. Хронология работы над функционалом (Timeline)

| Дата | Фича | Действие |
| :--- | :--- | :--- |
| **2026-09-07** | **FEAT-001** | Реализована поддержка просмотра содержимого папок через плагин `Folder Viewer` в релизе v1.3.0. |
| **2026-09-07** | **FEAT-002** | Обсуждение и утверждение архитектуры системы обновлений по образу и подобию MiniBin (без изменения версии программы). |
| **2026-09-07** | **Система** | Создана папка [`features/`](file:///d:/Projects/active/PeekIt/features), запущен оперативный журнал [`features/worklog.md`](file:///d:/Projects/active/PeekIt/features/worklog.md) и сформирован протокол агента `feature-tracker`. |
| **2026-09-07** | **FEAT-002** | Реализация завершена: `updater.rs` (бэкенд), UI карточка обновлений в `SettingsModal.svelte`, i18n-ключи, unit-тесты (4/4 pass), сборка 3 дистрибутивов. Статус → **Completed**. |
| **2026-09-07** | **FEAT-003** | Проектирование архитектуры приоритета плагинов над встроенными вьюерами (Plugin Precedence). Создан план [`features/plugin_precedence_plan.md`](file:///d:/Projects/active/PeekIt/features/plugin_precedence_plan.md). |
| **2026-09-07** | **FEAT-003** | Реализован наивысший приоритет плагинов в `+page.svelte`. Выполнен инкремент версии до 1.3.1. Успешно собраны дистрибутивы `output/` (Setup, MSI, Portable ZIP). Статус → **Completed**. |
| **2026-09-07** | **FEAT-004** | Реализован API диалога сохранения `PEEKIT_SAVE_FILE` в Rust и Svelte, обновлена версия в окне «О программе», успешно пересобраны все дистрибутивы v1.3.1. Статус → **Completed**. |




