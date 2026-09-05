## 🎯 Философия экосистемы (Core Pillars)

1. **Бескомпромиссная производительность:**
   - Нативный машинный код (**Rust**) и прямой Win32 API.
   - Размер любого дистрибутива: **от 2 до 10 МБ** (никакого Electron и тяжелого .NET).
   - Потребление оперативной памяти: **10–25 МБ ОЗУ** в фоновом режиме.
   - Запуск: мгновенный (**< 100 мс**).
2. **Премиальная эстетика:**
   - Стиль Windows 11 Fluent Design / macOS: блюр Mica / Acrylic, глубокие цвета (Slate Dark), мягкие тени и акцентные свечения.
   - Микро-анимации, адаптация под светлую и тёмную темы.
3. **Безопасность и удобство:**
   - Не требуют прав администратора (работают в пространстве пользователя HKCU, без назойливых окон UAC).
   - Портабельный режим из коробки (portable.txt).
   - Автоматическая и ручная проверка обновлений через GitHub Releases API.

---

## 📦 Текущие проекты в разработке

### 1. 🗑️ MiniBin v2 (Релиз v2.0.1 готов)
* **Назначение:** Замена громоздкой корзины на Рабочем столе компактной и функциональной иконкой в трее.
* **Ключевые фичи:**
  - Мониторинг размера и количества удалённых файлов в реальном времени.
  - Всплывающее Flyout-окно с карточкой хранилища, поиском, быстрым восстановлением и удалением.
  - Кастомные темы иконок (Fluent, Retro Win98, Minimalist, Original, свои файлы).
  - Встроенная система автопроверки обновлений с защитой от лимитов (cooldown 1 час) и уведомлениями Windows Toast.
  - Раздел «О программе» с полезными ресурсами и авторством.

### 2. ↩️ Undoit (готов)
* **Назначение:** Страховочная сетка для файловой системы — умная отмена действий (Ctrl+Z для файлов), защита от случайных удалений и перезаписей.
* **Синергия с MiniBin:** MiniBin очищает место и хранит корзину, а Undoit ведёт журнал быстрых отмен.

### 3. 🌐 PolyShift (готов)
 v2 (В плане переработки на Rust)
* **Назначение:** Мгновенный перевод и ИИ-помощник в любом приложении Windows по хоткею Alt + T.
* **Ключевые фичи v2:**
  - Потоковый стриминг ответа от Gemini в реальном времени (первые слова за 200 мс).
  - Плавающий HUD с эффектом матового стекла у курсора мыши.
  - Мульти-режимы: Перевод (Alt+T), Исправление грамматики (Alt+G), Выжимка (Alt+S), Объяснение кода/сленга (Alt+E).
  - Аппаратное шифрование API-ключа через Windows DPAPI.

### 👁️ 2. QuickLook (Мгновенный просмотр по пробелу) В разработке
* **Концепция:**  
  Нажатие **Space (Пробел)** на любом файле в Проводнике или на Рабочем столе мгновенно открывает превью во всплывающем окне без запуска тяжелых программ.
* **Поддерживаемые форматы:**  
  - Изображения (PNG, JPG, WebP, SVG, PSD).
  - Документы и текст (PDF, Markdown, JSON, код с подсветкой синтаксиса).
  - Медиа (MP4, MP3, WAV с легким плеером).
  - Архивы (просмотр списка файлов внутри .zip без распаковки).
* **Преимущество перед аналогами из MS Store:**  
  В 10 раз легче, не крашится на больших файлах, нулевая задержка открытия на Rust.


  Этот пошаговый план (Task Prompt) спроектирован для автономного ИИ-агента (Cursor, Claude Code, Windsurf) или разработчика. Задачи разбиты на фазы с конкретными контрактами данных, сигнатурами функций и критериями приемки (Definition of Done).

---

# Спецификация задачи: Реализация системы веб-плагинов для PeekIt

## Стек и архитектура
* **Ядро (Backend):** Rust (Tauri v2).
* **Интерфейс (Frontend):** Svelte 5 (Runes), TypeScript, Vite.
* **Среда выполнения плагинов:** Изолированный контейнер (`<iframe sandbox>`) с протоколом обмена сообщениями (`postMessage`).
* **Директория хранения:** `%APPDATA%\Peekit\plugins\`

---

## Фаза 1. Спецификация контрактов и манифеста

### Задача 1.1: Спецификация `manifest.json`
Создать стандарт описания плагина. Манифест должен валидироваться строго.

**Структура `manifest.json`:**
```json
{
  "$schema": "./plugin-schema.json",
  "id": "com.peekit.stl-viewer",
  "name": "3D STL Viewer",
  "version": "1.0.0",
  "author": "Community",
  "description": "QuickLook preview for 3D STL files",
  "extensions": [".stl"],
  "entry": "index.html",
  "min_peekit_version": "1.0.0",
  "permissions": ["read_file"]
}
```

---

## Фаза 2. Rust Backend: Сканер и управление плагинами

### Задача 2.1: Модель данных плагина и сканер директорий
**Файлы:** `src-tauri/src/plugins/mod.rs`, `src-tauri/src/plugins/scanner.rs`
1. Определить структуру в Rust (`serde::Deserialize`):
   ```rust
   #[derive(Debug, Clone, Serialize, Deserialize)]
   pub struct PluginManifest {
       pub id: String,
       pub name: String,
       pub version: String,
       pub extensions: Vec<String>,
       pub entry: String,
       #[serde(default)]
       pub permissions: Vec<String>,
   }

   #[derive(Debug, Clone, Serialize, Deserialize)]
   pub struct PluginInfo {
       pub manifest: PluginManifest,
       pub root_path: String,
       pub is_enabled: bool,
   }
   ```
2. Реализовать сканер директории `%APPDATA%/Peekit/plugins`:
   * Создать директорию, если она отсутствует.
   * Обойти подпапки, найти и распарсить `manifest.json`.
   * Защитить от Path Traversal и битых JSON (логировать ошибки, не роняя программу).

### Задача 2.2: Регистрация кастомного протокола в Tauri v2
**Файлы:** `src-tauri/src/lib.rs`
* Для безопасного рендеринга внешних веб-файлов из `%APPDATA%` зарегистрировать кастомный безопасный протокол `plugin-asset://`:
  * Запрос: `plugin-asset://com.peekit.stl-viewer/index.html`
  * Преобразуется в: `%APPDATA%/Peekit/plugins/com.peekit.stl-viewer/index.html`
  * Отдает файл с правильным MIME-типом (`text/html`, `application/javascript` и т.д.).

### Задача 2.3: Tauri IPC Commands
**Файлы:** `src-tauri/src/commands/plugins.rs`
Реализовать команды:
* `#[tauri::command] fn get_installed_plugins() -> Vec<PluginInfo>`
* `#[tauri::command] fn open_plugins_folder() -> Result<(), String>` (открытие в проводнике)
* `#[tauri::command] fn read_file_for_plugin(path: String) -> Result<Vec<u8>, String>`

---

## Фаза 3. Frontend: Plugin Host и SDK (Svelte 5)

### Задача 3.1: Состояние реестра плагинов (Svelte 5 Store / Runes)
**Файл:** `src/lib/stores/plugins.svelte.ts`
1. Хранить состояние:
   ```typescript
   export const pluginRegistry = $state({
     plugins: [] as PluginInfo[],
     extensionMap: new Map<string, PluginInfo>(),
   });
   ```
2. Метод `initPlugins()`: вызывает `get_installed_plugins` и заполняет `extensionMap` для быстрого поиска `O(1)` по расширению файла.

### Задача 3.2: SDK и Протокол связи (Host $\leftrightarrow$ Guest)
**Файл:** `src/lib/plugins/protocol.ts`
Определить RPC-сообщения между Peekit и iframe плагина:
```typescript
export type HostToPluginMessage = 
  | { type: 'PEEKIT_INIT'; payload: { filePath: string; theme: 'dark' | 'light'; fileName: string; fileSize: number } }
  | { type: 'PEEKIT_THEME_CHANGED'; payload: { theme: 'dark' | 'light' } };

export type PluginToHostMessage = 
  | { type: 'PEEKIT_REQUEST_DATA' }
  | { type: 'PEEKIT_RESIZE'; payload: { width: number; height: number } }
  | { type: 'PEEKIT_READY' };
```

### Задача 3.3: Компонент контейнера `<PluginHost.svelte>`
**Файл:** `src/lib/components/PluginHost.svelte`
1. Принимает пропсы: `plugin: PluginInfo`, `filePath: string`.
2. Рендерит безопасный iframe:
   ```html
   <iframe
     src="plugin-asset://{plugin.manifest.id}/{plugin.manifest.entry}"
     sandbox="allow-scripts allow-same-origin"
     class="w-full h-full border-0"
   ></iframe>
   ```
3. Слушает события `window.addEventListener('message', ...)`:
   * При получении `PEEKIT_READY` отправляет `PEEKIT_INIT` с метаданными.
   * При получении `PEEKIT_REQUEST_DATA` читает файл через Tauri IPC и пересылает бинарный буфер (ArrayBuffer) в iframe через `postMessage`.

---

## Фаза 4. Интеграция в пайплайн предпросмотра

### Задача 4.1: Маршрутизация типов файлов
**Файл:** Компонент маршрутизации предпросмотра (главный диспетчер)
Изменить логику выбора вьюера:
```typescript
// Псевдокод логики выбора
if (isNativeSupported(fileExt)) {
    // Встроенные быстрые просмотрщики (текст, картинки, pdf, видео)
    renderNativeViewer(fileExt);
} else if (pluginRegistry.extensionMap.has(fileExt)) {
    // Перенаправление на плагин
    const plugin = pluginRegistry.extensionMap.get(fileExt);
    renderPluginViewer(plugin);
} else {
    // Дефолтная плашка с инфо о неизвестном файле
    renderUnknownFileCard();
}
```

---

## Фаза 5. Референсный плагин (Proof of Concept)

### Задача 5.1: Создание шаблона плагина `peekit-plugin-font`
**Папка:** `examples/peekit-plugin-font/` (для предпросмотра `.ttf` / `.otf`)
1. `manifest.json` с привязкой к `.ttf`, `.otf`.
2. `index.html`:
   * Принимает `ArrayBuffer` шрифта по `postMessage`.
   * Создает `FontFace`, добавляет в `document.fonts`.
   * Отображает алфавит, цифры, панграммы и ползунок изменения размера шрифта.

---

## Фаза 6. Интерфейс управления плагинами (UI)

### Задача 6.1: Вкладка настроек «Плагины»
**Файл:** `src/lib/components/settings/PluginsSettings.svelte`
* Список обнаруженных плагинов (Иконка, Имя, Версия, Поддерживаемые расширения).
* Кнопка **«Открыть папку плагинов»** (вызывает `open_plugins_folder`).
* Кнопка **«Перезагрузить»** (горячее обновление без перезапуска приложения).


---

### Фаза 7. Экосистема: Создание центрального репозитория плагинов (GitHub Registry)
**Цель:** Развернуть публичный репозиторий `kobaltgit/peekit-plugins` как единый реестр (каталог) расширений сообщества. 
* **Структура реестра:** Реализовать центральный индекс `registry.json` (список метаданных всех проверенных плагинов: `id`, `name`, `version`, `download_url`, `checksum_sha256`, `extensions`, `author`, `min_app_version`) и настроить его раздачу через GitHub Pages или сырой CDN для последующего парсинга клиентом PeekIt.
* **CI/CD Автоматизация (GitHub Actions):** Написать пайплайн валидации Pull Request'ов от сторонних авторов: автоматическая проверка `manifest.json` по JSON Schema, проверка отсутствия конфликтов по расширениям файлов с уже существующими плагинами и базовый аудит безопасности (линтер, проверка внешних сетевых запросов).
* **Шаблон для разработчиков (Starter Kit):** Добавить в репозиторий директорию `template/` (или отдельный репозиторий-шаблон `peekit-plugin-template`) с готовым окружением: TypeScript-декларациями `@peekit/plugin-sdk`, базовой сборкой через Vite/Rollup в единый бандл и локальным сервером для тестирования плагина в браузере без установки самого PeekIt.

---

## Критерии приемки (Definition of Done)
1. **Изоляция:** Падение скрипта плагина (throw Error) не крашит окно PeekIt.
2. **Производительность:** Нажатие `Space` на встроенном типе файла (например, `.png`) отрабатывает без задержек; сканирование плагинов не блокирует поток запуска утилиты.
3. **Безопасность:** Внутри плагина заблокирован прямой доступ к файловой системе Windows (только через контролируемый `postMessage`).
4. **Рабочий PoC:** Положив папку с референсным плагином в `%APPDATA%/Peekit/plugins/`, пользователь может нажать пробел на файле `.ttf` и увидеть кастомный интерфейс просмотра шрифта.