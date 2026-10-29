# PeekIt — Feature Worklog

#### [2026-10-29 02:25] • [FEAT-007] • [Проектирование]
- **Цель:** Добавить китайский язык (zh-CN) в локализацию PeekIt по запросу пользователя (сейчас только ru/en).
- **Выполненные действия:** проанализирована система локализации: словарь `src/lib/i18n.ts` (ru/en, ~100 ключей), тип `AppLanguage` в `src/lib/types.ts`, селектор в `SettingsModal.svelte`, собственные I18N-словари внутри `plugins/*/index.html`. Составлен объём изменений (см. featurelist.md, FEAT-007).
- **Статус:** Proposed (реализация не начата, ожидает подтверждения).

#### [2026-10-29 02:56] • [FEAT-007] • [Разработка → Завершено]
- **Цель:** Добавить китайский язык (zh-CN) в локализацию PeekIt.
- **Выполненные действия:**
  - `src/lib/types.ts`: `AppLanguage = 'ru' | 'en' | 'zh'`.
  - `src/lib/i18n.ts`: полный zh-словарь, 98/98 ключей (сверено скриптом с en).
  - `SettingsModal.svelte`: опция «简体中文 (ZH)» в селекторе языка.
  - `PluginsTab.svelte`: хелпер `L(ru, en, zh)` — кнопки Refresh/Uninstall/Retry, подтверждение удаления, ярлыки категорий, `getCategoryLabel`, labelZh в `categories`.
  - `GenericPreview.svelte`, `PluginHost.svelte`, `+page.svelte`: трёхязычные строки (содержимое папки, баннер ошибки плагина, кнопки карусели).
  - `plugins/peekit-plugin-folder/index.html`: zh-словарь I18N + приём `language === 'zh'`.
  - `src-tauri/src/lib.rs`: подписи меню трея выбираются по `language` из config.json при старте (применяется после перезапуска).
  - `src-tauri/src/updater.rs`: тост «Доступно обновление» на языке конфигурации.
- **Проверка:** `npm run check` — 0 ошибок; `cargo check` — 0 ошибок / 0 предупреждений.
- **Статус:** [Завершено] — статус в featurelist.md → `Completed`.

#### [2026-10-29 04:10] • [FEAT-007] • [Доработка по фидбеку — Завершено]
- **Цель:** Устранить «трей не переведён» и улучшить поведение сохранения настроек (запрос пользователя).
- **Выполненные действия:**
  - Трей-меню теперь перевыбирает язык НА ЛЕТУ: `lib.rs::build_tray_menu`/`apply_tray_language` + `save_app_config` сравнивает язык до/после и пересобирает меню (tray id «peekit-tray»); рестарт больше не нужен.
  - «Сохранить» в настройках больше не закрывает диалог: можно переключать вкладки после сохранения; кнопка показывает «✓ Настройки сохранены» (новый ключ settings_saved: ru/en/zh); закрытие — «Закрыть»/×/Esc. Ответ на вопрос пользователя: сохраняются ВСЕ вкладки (единый объект настроек), а не только текущая.
  - `save_app_config`/`set_plugin_enabled` принимают AppHandle для обновления трея.
- **Живая верификация:** zh→en→zh через UI: интерфейс переключается мгновенно, диалог остаётся открытым, «✓ 设置已保存/Settings saved» отображается, config.json персистится, лог «Tray menu language updated» ×2.
- **Статус:** [Завершено].

#### [2026-10-29 22:15] • [FEAT-008] • [Проектирование / Разработка]
- **Цель:** Показывать содержимое текстовых файлов без «текстовых» расширений (.git/config, .env.local, .ssh/known_hosts, LICENSE и т.п.) — сейчас карточка GENERIC без содержимого, у QuickLook получается.
- **Диагностика:** `inspect_file` (preview.rs) маршрутизирует по расширению/имени; `.git/config` → extension="" → generic; имя-фоллбеки смотрят только на имя файла, не на путь. Чтение (`read_text_content`) при этом работает для любой категории — блокирует именно категория.
- **Выполненные действия:**
  - `preview.rs`: `sniff_is_text()` — 8 KiB выборка: empty→text, BOM→text, NUL→binary (эвристика git), доля control-символов >5%→binary, иначе text.
  - `inspect_file()`: финальный фоллбек generic→sniff; guard от облачных placeholder (не триггерить скачивание OneDrive); при сниффе mime→text/plain.
  - `read_file_text_capped()`: BOM-осведомлённое декодирование (UTF-8 BOM strip, UTF-16 LE/BE).
  - Юнит-тесты: реальный `.git/config` репозитория, `.env`, `.env.local`, known_hosts, бинарник с NUL, zip-байты, UTF-16 LE декодирование.
- **Статус:** In Progress (реализация, далее верификация).

#### [2026-10-29 22:40] • [FEAT-008] • [Завершено]
- **Цель:** (см. запись 22:15) превью текста для файлов без «текстовых» расширений.
- **Выполненные действия:** `sniff_is_text` (8 KiB выборка: empty/BOM→text, NUL→binary, control-символы >5%→binary); интеграция финальным фоллбеком в `inspect_file` (generic→text, mime→text/plain) с guard от облачных placeholder OneDrive/iCloud; BOM-осведомлённое декодирование UTF-8/UTF-16 LE/BE в `read_file_text_capped`; 6 юнит-тестов, включая реальный `.git/config` этого репозитория.
- **Проверка:** `cargo test` 9/9 ok (после попутного фикса BUG-009); `cargo check` 0 ошибок/0 предупреждений; `npm run check` 0 ошибок (4 предсуществующих a11y-предупреждения в ImagePreview/PdfPreview, не затронуты).
- **Влияние на UI:** фронтенд не менялся — категория `text` уже маршрутизируется в CodePreview, `loadFileInfo` грузит `read_text_content` для text/code/markdown.
- **Статус:** [Завершено] — featurelist.md FEAT-008 → `Completed`.
