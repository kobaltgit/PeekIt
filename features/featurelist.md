# PeekIt — Feature Tracker (Сводная таблица функций)

> Протокол ведения: см. AGENTS.md. Нумерация продолжается с FEAT-008 (FEAT-007 реализован 2026-10-29).

## Сводная таблица

| ID | Дата | Функция | Компоненты | Статус | План/артефакт |
| :--- | :--- | :--- | :--- | :--- | :--- |
| FEAT-007 | 2026-10-29 | Поддержка китайского языка (zh-CN / 简体中文) в интерфейсе | `src/lib/i18n.ts`, `src/lib/types.ts`, `SettingsModal.svelte`, `PluginsTab.svelte`, `GenericPreview.svelte`, `PluginHost.svelte`, `+page.svelte`, плагин `peekit-plugin-folder`, трей (`lib.rs`), тост обновлений (`updater.rs`) | Completed | см. подраздел FEAT-007 |
| FEAT-008 | 2026-10-29 | Контент-сниффинг текста: превью для файлов без «текстовых» расширений (.git/config, .env.local, LICENSE и т.п.) | `src-tauri/src/preview.rs` (`sniff_is_text`, `read_file_text_capped`, `inspect_file`) | Completed | см. подраздел FEAT-008 |

---

## FEAT-008 — Контент-сниффинг текста (превью «бесформенных» текстовых файлов)

**Проблема (репродукция пользователя):** файл `E:\...\shipanytwo\.git\config` (4070 B) показывается карточкой GENERIC с MIME `application/octet-stream`, содержимое не отображается. QuickLook тот же файл показывает как текст.

**Причина:** `inspect_file` определяет категорию только по расширению/имени. `.git/config` — имя без расширения → `detect_category("")` → `generic`; fallback-проверки (`starts_with(".env")`, `starts_with(".git")`, `ends_with("rc")`) смотрят только на имя файла, а не на путь, и «config» не совпадает ни с одной. `.env`/`.env.local` сейчас работают (попадают в `starts_with(".env")`), но любая другая бесформенная строка (`.ssh/known_hosts`, `LICENSE` без расширения, `.git/HEAD`, произвольные `.bak/.orig/.conf`) — нет.

**Архитектура решения (по образцу QuickLook / git):**
1. `preview.rs`: новая функция `sniff_is_text(path)` — читает до 8 KiB с начала файла:
   - пустой файл → текст;
   - BOM (UTF-8 / UTF-16 LE/BE) → текст;
   - NUL-байт в выборке → бинарный (эвристика git — корректно отсеивает `.git/index`, `.git/objects/*`);
   - доля управляющих символов (кроме \t \n \r \b \f ESC) > 5% → бинарный;
   - иначе → текст.
2. `inspect_file`: если после всех эвристик по имени категория всё ещё `generic` И файл не облачный placeholder (OneDrive — не триггерить скачивание) И `sniff_is_text` → `category = "text"`, `mime_type = "text/plain"`. Фронтенд уже грузит `read_text_content` для категории `text` — изменений фронтенда не требуется.
3. `read_file_text_capped`: BOM-осведомлённое декодирование — срез UTF-8 BOM, декодирование UTF-16 LE/BE (файлы, экспортированные PowerShell, блокнот «Unicode») вместо NUL-каши.
4. Юнит-тесты: `.git/config` этого репозитория (реальный файл) → text; `.env`, `.env.local`, `.ssh/known_hosts`, LICENSE → text; `.git/index`-подобный бинарник с NUL → generic; zip-заголовок/случайные байты → generic; UTF-16 LE с BOM декодируется корректно.

**Критерии готовности:** `cargo test` зелёный; `cargo check` 0 warnings; `npm run check` 0 ошибок; реальные файлы `.git/config` / `.env` в Dev-сборке показывают содержимое (категория TEXT в статус-баре).

**Хронология работы**

| Дата | Действие | Результат |
| :--- | :--- | :--- |
| 2026-10-29 22:15 | Проектирование: локализована причина (категорийная маршрутизация, не чтение файла), выбран сниффинг по образцу git/QuickLook | Proposed |
| 2026-10-29 22:20 | Реализация: `sniff_is_text`, интеграция в `inspect_file` с guard от облачных placeholder, BOM-декодирование в `read_file_text_capped`, 8 юнит-тестов | Completed |
| 2026-10-29 22:40 | Верификация: `cargo test` 10/10 ok; `cargo check` 0 warnings; `npm run check` 0 ошибок | Критерии выполнены |

**Примечание:** запрос пользователя «настройка автозапуска» отдельной фичей не требует — опция уже существует (Settings → Общие → «Запускать вместе с Windows», `@tauri-apps/plugin-autostart`, HKCU Run); проверена цепочка: чекбокс → `enable/disableAutostart` → capabilities `autostart:default` → плагин зарегистрирован в `lib.rs`.

---

## FEAT-007 — Локализация интерфейса на китайский язык (简体中文)

**Архитектура / Требования:**
Текущее состояние: `AppLanguage = 'ru' | 'en'` (types.ts:66); словарь `translations` в i18n.ts содержит только ru/en (~100 ключей); селектор языка в SettingsModal имеет 2 опции; t() fallback: lang → en → key.

**Требуемые изменения:**
1. `src/lib/types.ts`: расширить `AppLanguage` до `'ru' | 'en' | 'zh'`.
2. `src/lib/i18n.ts`: добавить полный словарь `zh` (~100 ключей) — все ключи из en.
3. `SettingsModal.svelte`: добавить `<option value="zh">简体中文 (ZH)</option>`.
4. Компоненты предпросмотра (MediaPreview, PdfPreview, ArchivePreview, GenericPreview и др.) — проверить прямые RU/EN строки; добавить zh-ветки там, где текст захардкожен.
5. Плагины (`plugins/*/index.html`) — собственные I18N-объекты (ru/en); добавить zh + расширить проверку языка (`payload.language === 'zh'`).
6. Tray-меню (lib.rs) — текущие подписи «Русский (English)» дублированы; можно оставить как есть или добавить zh.
7. Rust default config `language: "ru"` — без изменений (обратно совместимо).

**Критерии готовности:**
- `npm run check` без ошибок; выбор zh применяет переводы во всех окнах без перезапуска; сохранение в config.json (`"language": "zh"`) переживает рестарт.

**Хронология работы**

| Дата | Действие | Результат |
| :--- | :--- | :--- |
| 2026-10-29 | Проектирование: анализ системы локализации, объём изменений | Proposed |
| 2026-10-29 | Реализация: zh-словарь i18n.ts (98/98 ключей, сверено скриптом), тип AppLanguage='ru'\|'en'\|'zh', опция в SettingsModal, трёхязычные строки PluginsTab/GenericPreview/PluginHost/+page, zh-словарь плагина folder, локаль трея (lib.rs) и тоста обновлений (updater.rs) | Completed |
| 2026-10-29 | Верификация: `npm run check` 0 ошибок; `cargo check` 0 ошибок/0 предупреждений | Критерии выполнены |

**Ограничение (известное):** плагины docx / font / sheet / 3d / slides / geo / video распространяются как собранные бандлы и не читают язык хоста — их надписи остаются на языке оригинала (как и раньше для EN-пользователей). Трей-меню применяет язык при следующем запуске приложения.
