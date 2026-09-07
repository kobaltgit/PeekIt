<p align="center">
  <img src="src-tauri/icons/128x128.png" width="96" height="96" alt="Peekit Logo" />
  <h1 align="center">Peekit</h1>
  <strong>Мгновенный просмотр файлов по Space для Windows 10 & 11 на Rust и Tauri v2.</strong><br/>
  <em>Instant Spacebar file preview for Windows 10 & 11 built with Rust & Tauri v2.</em>
</p>

<p align="center">
  <a href="https://github.com/kobaltgit/peekit/releases/latest"><img src="https://img.shields.io/github/v/release/kobaltgit/peekit?color=38bdf8&label=Latest%20Release" alt="Latest Release" /></a>
  <a href="https://kobaltgit.github.io/PeekIt/"><img src="https://img.shields.io/badge/Website-Flutter%20Web-02569B.svg?logo=flutter" alt="Live Website" /></a>
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg?logo=windows" alt="Windows 10/11" />
  <img src="https://img.shields.io/badge/Rust-2021%20Edition-DEA584.svg?logo=rust" alt="Rust 2021" />
  <img src="https://img.shields.io/badge/Tauri-v2.0-FFC131.svg?logo=tauri" alt="Tauri v2" />
  <img src="https://img.shields.io/badge/Frontend-Svelte%205%20(Runes)-FF3E00.svg?logo=svelte" alt="Svelte 5" />
  <img src="https://img.shields.io/badge/RAM-%3C%2020%20MB-34d399.svg" alt="Low RAM" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License" /></a>
</p>

<p align="center">
  <a href="#-о-проекте">🇷🇺 Русский</a> • <a href="#-about-the-project">🇬🇧 English</a> • <a href="#-экосистема-kobalt-tools">🌐 Экосистема</a>
</p>

---

## 🇷🇺 О проекте

**Peekit** — сверхлегковесная, нативная утилита для Windows 10 & 11, входящая в экосистему системных инструментов **Kobalt Tools** ([StashIt](https://github.com/kobaltgit/StashIt), [MiniBin](https://github.com/kobaltgit/minibin), [Undoit](https://github.com/kobaltgit/undoit), [PolyShift](https://github.com/kobaltgit/polyshift)).

Позволяет мгновенно просматривать содержимое любых файлов по нажатию клавиши **Space (Пробел)** в Проводнике или на Рабочем столе — без запуска тяжелых сторонних программ, задержек и подвисаний.

### ⚡ Сравнение с аналогами

| Параметр | Peekit v1.3.2 | QuickLook | PowerToys Peek |
| :--- | :--- | :--- | :--- |
| **Технологический стек** | **Rust + Tauri v2 + Svelte 5** | C# / .NET / WPF | C++ / WinUI 3 (в составе PowerToys) |
| **Потребление ОЗУ в фоне** | **10–15 МБ** | 30–50 МБ | 100–200 МБ |
| **ОЗУ при активном просмотре** | **~25–80 МБ** | ~60–80 МБ (текст) / 150–300 МБ | 120–250 МБ |
| **Холодный отклик по Space** | **~50 мс** | ~50–80 мс | ~200–350 мс |
| **Размер дистрибутива** | **~3.4 МБ** | ~90 МБ | > 200 МБ (весь пакет PowerToys) |
| **Архитектура плагинов** | **Изолированные Web-песочницы** | .NET DLL | Отсутствует |
| **Права администратора** | **Не требуются (чистый HKCU)** | Не требуются | Требуются частично |

### 🎯 Возможности

- **Мгновенный запуск по Пробелу:** Низкоуровневый системный хук Windows `WH_KEYBOARD_LL`.
- **Защита ввода (Inline Rename Filter):** Пробел не перехватывается, если пользователь переименовывает файл в Проводнике или вводит текст в поле поиска.
- **Встроенный медиаплеер:** Воспроизведение видео (MP4, WebM, MKV) и аудио (MP3, WAV, FLAC, AAC) со скраббером, громкостью, зацикливанием и звуковой волной.
- **Широкая поддержка форматов:**
  - **Изображения:** PNG, JPG, WebP, GIF, SVG, BMP, ICO с зумом и информацией о разрешении.
  - **Код и текст:** Подсветка синтаксиса для 50+ языков, нумерация строк, копирование.
  - **Документы и PDF:** Постраничный просмотр PDF с масштабированием, рендер Markdown.
  - **Архивы:** Просмотр структуры и размеров файлов внутри `.zip` без распаковки.
  - **Облачные файлы:** Бережная обработка OneDrive плейсхолдеров без нежелательной фоновой загрузки гигабайтов.
- **Двуязычность и темы:** Полная поддержка русского и английского языков, темная (Slate Dark) и светлая (Clean Light) темы Fluent Design.
- **🧩 Модульная система плагинов (Plugin Architecture):**
  - Изолированные веб-плагины, работающие в защищенных песочницах WebView2 без оверхеда на основной процесс.
  - **Встроенные плагины:**
    - 🎨 **Шрифты (Font Viewer):** `.ttf`, `.otf`, `.woff`, `.woff2` (OpenType санитайзер, глифы, панграммы).
    - 🧊 **3D Модели (3D Viewer):** `.stl`, `.obj`, `.gltf`, `.glb`, `.ply` (Three.js WebGL, студийное освещение, 360° вертушка).
    - 📄 **Word Документы (Docx Viewer):** `.docx`, `.doc` (Печатный макет А4, таблицы, изображения, ночной режим).
    - 📊 **Электронные таблицы (Spreadsheet Viewer):** `.xlsx`, `.xls`, `.csv`, `.tsv`, `.ods` (Сетка Excel с формулами, вкладки).
    - 📽️ **Презентации (PowerPoint Viewer):** `.pptx`, `.ppt` (Интерактивное слайд-шоу, боковая лента).
  - Каталог плагинов: [peekit-plugins](https://github.com/kobaltgit/peekit-plugins).

### 📥 Установка и загрузка

Скачайте актуальную версию со [страницы последнего релиза](https://github.com/kobaltgit/peekit/releases/latest):

- **Инсталлятор (`.msi` / `Setup.exe`):** Быстрая установка без прав администратора.
- **Portable версия (`.zip`):** Запуск в один клик без инсталляции.

---

## 🇬🇧 About the Project

**Peekit** is an ultra-lightweight, native Windows 10 & 11 utility and part of the **Kobalt Tools** desktop ecosystem ([StashIt](https://github.com/kobaltgit/StashIt), [MiniBin](https://github.com/kobaltgit/minibin), [Undoit](https://github.com/kobaltgit/undoit), [PolyShift](https://github.com/kobaltgit/polyshift)).

It enables instant file previews by pressing **Space** in File Explorer or on the Desktop without launching bulky third-party applications.

### ⚡ Key Benchmarks

| Parameter | Peekit v1.3.2 | QuickLook | PowerToys Peek |
| :--- | :--- | :--- | :--- |
| **Technology stack** | **Rust + Tauri v2 + Svelte 5** | C# / .NET / WPF | C++ / WinUI 3 (part of PowerToys) |
| **Background RAM usage** | **10–15 MB** | 30–50 MB | 100–200 MB |
| **Active preview RAM** | **~25–80 MB** (depending on plugin) | ~60–80 MB (text) / 150–300 MB | 120–250 MB |
| **Cold response on Space** | **~50 ms** | ~50–80 ms | ~200–350 ms |
| **Distribution size** | **~3.4 MB** | ~90 MB | > 200 MB (full PowerToys suite) |
| **Plugin architecture** | **Isolated Web sandboxes** | .NET compiled DLLs | None |
| **Administrator rights** | **Not required (clean HKCU)** | Not required | Partially required |

### 🎯 Core Features

- **Instant Spacebar Activation:** Powered by native Rust Win32 low-level keyboard hooks.
- **Smart Typing & Rename Filter:** Does not interfere when renaming files in Explorer or typing in search bars.
- **Integrated Fluent Media Player:** Smooth playback for video and audio with timeline scrubber, volume slider, loop mode, and speed toggles.
- **Broad Format Coverage:** Images, multi-page PDFs, rendered Markdown, syntax-highlighted code, and ZIP archive contents without unpacking.
- **🧩 Extensible Plugin Architecture:**
  - Sandboxed WebView2 web-plugins with zero impact on background memory.
  - **Bundled Plugins:**
    - 🎨 **Fonts:** `.ttf`, `.otf`, `.woff`, `.woff2` (OpenType sanitizer fallback, custom pangrams, glyph viewer).
    - 🧊 **3D Models:** `.stl`, `.obj`, `.gltf`, `.glb`, `.ply` (Three.js WebGL, studio lighting, materials, 360° turntable).
    - 📄 **Word Documents:** `.docx`, `.doc` (A4 print layout, tables, images, dark/light reading modes).
    - 📊 **Spreadsheets:** `.xlsx`, `.xls`, `.csv`, `.tsv`, `.ods` (Excel grid, formula bar, multi-sheet tabs, live search).
    - 📽️ **Presentations:** `.pptx`, `.ppt` (Slide-show stage, keyboard navigation, thumbnail strip).
  - Plugin Store: [peekit-plugins](https://github.com/kobaltgit/peekit-plugins).
- **Zero Admin / Portable:** Runs entirely in user mode (HKCU).

### 📥 Installation & Download

Download the latest version from [GitHub Releases](https://github.com/kobaltgit/peekit/releases/latest):

- **Installer (`.msi` / `Setup.exe`):** Fast user-mode setup, no UAC prompts.
- **Portable (`.zip`):** Unpack and run anywhere.

---

## 🛠️ Сборка и разработка / Development

```bash
# 1. Установка зависимостей фронтенда
npm install

# 2. Запуск в режиме разработки (Hot Reload)
npm run tauri dev

# 3. Сборка релизного установщика
npm run tauri build
```

---

## 🌐 Экосистема Kobalt Tools

| Проект | Описание | Стек | Ссылки |
| :--- | :--- | :--- | :--- |
| 📥 **StashIt** | Плавающий карман Drag-and-Drop (Dropover / Yoink для Windows) | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/StashIt) • [Web](https://kobaltgit.github.io/StashIt/) |
| 🗑️ **MiniBin** | Умная корзина в системном трее с Flyout-интерфейсом | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/minibin) • [Web](https://kobaltgit.github.io/minibin/) |
| ⏱️ **Undoit** | Локальная машина времени и версионирование файлов (Ctrl+Z) | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/undoit) • [Web](https://kobaltgit.github.io/Undoit/) |
| 🌐 **PolyShift** | HUD-помощник и контекстный перевод у курсора с Gemini AI | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/polyshift) • [Web](https://kobaltgit.github.io/polyshift/) |
| 👁️ **PeekIt** | Мгновенный предпросмотр файлов по клавише Space | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/peekit) • [Web](https://kobaltgit.github.io/PeekIt/) |
| 🧩 **PeekIt Plugins** | Официальный реестр и SDK веб-плагинов для PeekIt | TypeScript + Web SDK | [Repo](https://github.com/kobaltgit/peekit-plugins) • [Web](https://kobaltgit.github.io/peekit-plugins/) |
| 🎨 **kobalt_ui** | Общая библиотека UI компонентов (шапка, футер, релизы) | Flutter Web (Dart) | [Repo](https://github.com/kobaltgit/kobalt_ui) |

---

## 📄 Лицензия / License

Распространяется под свободной лицензией **MIT**. Подробности в файле [LICENSE](LICENSE).
