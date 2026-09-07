# [План внедрения] Система проверки и уведомления об обновлениях (FEAT-002)

Внедрение в **PeekIt** легковесного, автономного и надежного модуля проверки обновлений по проверенной архитектуре проекта **MiniBin**.

> [!IMPORTANT]
> **Требования пользователя:**
> 1. Полное соответствие архитектуре и поведению системы обновлений в **MiniBin** (фоновый опрос, скрытый PowerShell без консольных окон, Toast-уведомления, карточка с прямыми ссылками на `.exe` и `.zip`).
> 2. **Номер версии не меняем** — версия остается `1.3.0`.
> 3. Нулевое раздувание размера программы (без внешних тяжелых HTTP-библиотек вроде `reqwest`).

---

## Предлагаемые изменения

### Бэкенд (Rust)

#### [NEW] [`src-tauri/src/updater.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/updater.rs)
- Создание модуля `updater.rs` с логикой из MiniBin:
  - **Константы:**
    - `GITHUB_API_URL`: `"https://api.github.com/repos/kobaltgit/PeekIt/releases/latest"`
    - `CURRENT_VERSION`: `env!("CARGO_PKG_VERSION")` (равно `1.3.0`)
    - `COOLDOWN_SECONDS`: `3600` (1 час между автоматическими фоновыми проверками)
    - `WEEKLY_CHECK_SECONDS`: `604800` (7 дней)
  - **Структура `UpdateCheckResult`:**
    - `has_update: bool`
    - `current_version: String`
    - `latest_version: String`
    - `release_url: String`
    - `setup_url: Option<String>`
    - `portable_url: Option<String>`
    - `release_notes: String`
    - `published_at: String`
  - **Функция `is_version_newer(latest, current)`:**
    - Покомпонентное сравнение версий Semver (Major, Minor, Patch).
    - Корректная обработка префиксов `v` / `V` и суффиксов.
  - **Функция `query_github_latest_release()`:**
    - Запуск скрытого процесса PowerShell (`CREATE_NO_WINDOW = 0x08000000`, `-NoProfile`, `-ExecutionPolicy Bypass`).
    - `Invoke-RestMethod` к GitHub Releases API с таймаутом 10 секунд.
    - Парсинг ассетов: определение инсталлятора `*setup.exe` и портабельного архива `*Portable.zip`.
  - **Функция `show_update_toast(version)`:**
    - Отправка нативного всплывающего уведомления Windows 10/11 через `[Windows.UI.Notifications.ToastNotificationManager]` в PowerShell.
    - Показ не более одного раза для каждой новой версии.
  - **Функция `check_updates_with_cooldown(app, force)`:**
    - Считывание настроек (флаг `auto_check_updates`, отметка `last_update_check_time`, `last_notified_version`).
    - Отправка события `update-status` в окно приложения.
  - **Функция `start_background_updater(app)`:**
    - Запуск фонового потока: первая тихая проверка через 3 секунды после старта приложения, последующие — раз в 7 дней при включенной настройке.

---

#### [MODIFY] [`src-tauri/src/commands.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/commands.rs)
- Добавление команды `check_for_updates`:
  ```rust
  #[tauri::command]
  pub fn check_for_updates(app: AppHandle, force: bool) -> Result<crate::updater::UpdateCheckResult, String> {
      crate::updater::check_updates_with_cooldown(&app, force)
  }
  ```
- Расширение дефолтных значений в `get_app_config`:
  - `"auto_check_updates": true`
  - `"last_update_check_time": 0`
  - `"last_notified_version": ""`

---

#### [MODIFY] [`src-tauri/src/lib.rs`](file:///d:/Projects/active/PeekIt/src-tauri/src/lib.rs)
- Объявление модуля `pub mod updater;`.
- Регистрация команды `commands::check_for_updates` в `invoke_handler`.
- Вызов `updater::start_background_updater(app.handle().clone());` в хуке `setup`.

---

### Фронтенд (Svelte, TypeScript, i18n)

#### [MODIFY] [`src/lib/types.ts`](file:///d:/Projects/active/PeekIt/src/lib/types.ts)
- Добавление интерфейса `UpdateCheckResult`:
  ```typescript
  export interface UpdateCheckResult {
    has_update: boolean;
    current_version: string;
    latest_version: string;
    release_url: string;
    setup_url?: string;
    portable_url?: string;
    release_notes: string;
    published_at: string;
  }
  ```
- Расширение `AppSettings`:
  ```typescript
  auto_check_updates?: boolean;
  ```

---

#### [MODIFY] [`src/lib/i18n.ts`](file:///d:/Projects/active/PeekIt/src/lib/i18n.ts)
- Добавление ключей локализации для RU и EN:
  - `check_updates`: «Проверить обновления» / «Check for updates»
  - `checking_updates`: «Проверка...» / «Checking...»
  - `updates_latest`: «У вас установлена актуальная версия» / «You have the latest version»
  - `updates_available`: «Доступно обновление: » / «Update available: »
  - `download_setup`: «Скачать установщик (.exe)» / «Download Setup (.exe)»
  - `download_portable`: «Скачать Portable (.zip)» / «Download Portable (.zip)»
  - `view_release_notes`: «Список изменений →» / «Release Notes →»
  - `auto_check_updates`: «Автоматически проверять обновления» / «Check for updates automatically»
  - `auto_check_updates_desc`: «Проверять наличие новых версий раз в неделю» / «Check for new releases weekly in background»
  - `update_error`: «Не удалось проверить обновления» / «Failed to check for updates»

---

#### [MODIFY] [`src/lib/components/SettingsModal.svelte`](file:///d:/Projects/active/PeekIt/src/lib/components/SettingsModal.svelte)
- В разделе **«О программе» (`about`)**:
  - Интеграция современного блока обновлений:
    - Статусная строка: текущая версия `v1.3.0`, индикатор статуса (зелёная точка «Актуальная версия» или оранжевая «Доступна v...»).
    - Кнопка «Проверить сейчас» (с анимацией вращения иконки `spin`).
    - Карточка доступного обновления (плавно отображается при `updateResult?.has_update`):
      - Кнопка прямой загрузки установщика (.exe).
      - Кнопка прямой загрузки портабельной версии (.zip).
      - Ссылка перехода к просмотру списка изменений на GitHub.
    - Переключатель (Toggle Switch): «Автоматически проверять обновления».
- В шапке модального окна настроек:
  - Ненавязчивый бейджик `Update available`, если фоновый сервис обнаружил релиз.

---

## План верификации

### 1. Автоматическая проверка
- Проверка типов Svelte/TypeScript: `npm run check` (0 ошибок).
- Проверка компиляции Rust: `cargo check` (0 ошибок и предупреждений).
- Запуск unit-тестов модуля сравнения версий: `cargo test` (проверка `is_version_newer` на различных форматах тегов).

### 2. Функциональное тестирование
- Запуск приложения в dev-режиме (`npm run tauri dev`).
- Проверка ручного нажатия кнопки «Проверить обновления» во вкладке «О программе»:
  - Должен корректно выполниться запрос к `https://api.github.com/repos/kobaltgit/PeekIt/releases/latest`.
  - Статус должен сообщить: «У вас установлена актуальная версия» (поскольку последняя версия на GitHub — 1.3.0).
- Проверка имитации новой версии (проверка условия `1.3.1` > `1.3.0`):
  - Появление кнопок скачивания `.exe` и `.zip`.
  - Корректное открытие ссылок в браузере через системный shell opener.
  - Сохранение состояния чекбокса «Автоматически проверять обновления» в `config.json`.
