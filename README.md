# 👁️ Peekit — Instant Spacebar File Preview for Windows

[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg?logo=windows)](https://microsoft.com)
[![Rust](https://img.shields.io/badge/Rust-2021%20Edition-DEA584.svg?logo=rust)](https://www.rust-lang.org)
[![Tauri](https://img.shields.io/badge/Tauri-v2.0-FFC131.svg?logo=tauri)](https://v2.tauri.app)
[![Svelte](https://img.shields.io/badge/Svelte-v5%20(Runes)-FF3E00.svg?logo=svelte)](https://svelte.dev)
[![Flutter Web](https://img.shields.io/badge/Website-Flutter%20Web-02569B.svg?logo=flutter)](https://kobaltgit.github.io/peekit/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[**Русский**](#-о-проекте-peekit) | [**English**](#-about-peekit)

---

## 🇷🇺 О проекте Peekit

**Peekit** — сверхлегковесная, нативная утилита для Windows 10 & 11, входящая в экосистему системных инструментов (**MiniBin v2**, **Undoit**, **PolyShift**).

Позволяет мгновенно просматривать содержимое любых файлов по нажатию клавиши **Space (Пробел)** в Проводнике или на Рабочем столе — без запуска тяжелых сторонних программ, задержек и подвисаний.

### ⚡ Ключевые показатели

| Параметр | Peekit v1.2.0 | QuickLook | PowerToys Peek |
| :--- | :--- | :--- | :--- |
| **Технологический стек** | **Rust + Tauri v2 + Svelte 5** | C# / .NET / WPF | C++ / WinUI 3 (в составе PowerToys) |
| **Потребление ОЗУ в фоне** | **10–15 МБ** | 30–50 МБ | 100–200 МБ |
| **ОЗУ при активном просмотре** | **~25–80 МБ** (в зависимости от плагина) | ~60–80 МБ (текст) / 150–300 МБ (PDF, медиа) | 120–250 МБ |
| **Холодный отклик по Space** | **~ 50 мс** | ~50–80 мс | ~200–350 мс |
| **Размер дистрибутива** | **~3.4 МБ** (установщик) / 5.1 МБ (portable) | ~90 МБ | >200МБ (весь пакет PowerToys) |
| **Архитектура плагинов** | **Изолированные Web-песочницы (iframe + postMessage)** | .NET скомпилированные DLL | Отсутствует |
| **Права администратора** | **Не требуются (чистый HKCU)** | Не требуются | Требуются частично |

### 🎯 Возможности

- **Мгновенный запуск по Пробелу:** Низкоуровневый системный хук Windows `WH_KEYBOARD_LL`.
- **Защита ввода (Inline Rename Filter):** Пробел не перехватывается, если пользователь переименовывает файл в Проводнике или вводит текст в поле поиска.
- **Встроенный медиаплеер:** Воспроизведение видео (MP4, WebM, MKV) и аудио (MP3, WAV, FLAC, AAC) со скраббером, громкостью, зацикливанием и динамической звуковой волной.
- **Широкая поддержка форматов:**
  - **Изображения:** PNG, JPG, WebP, GIF, SVG, BMP, ICO с зумом и информацией о разрешении.
  - **Код и текст:** Подсветка синтаксиса для 50+ языков, нумерация строк, копирование.
  - **Документы и PDF:** Постраничный просмотр PDF с масштабированием, рендер Markdown.
  - **Архивы:** Просмотр структуры и размеров файлов внутри `.zip` без распаковки.
  - **Облачные файлы:** Бережная обработка OneDrive плейсхолдеров без нежелательной фоновой загрузки гигабайтов.
- **Двуязычность и темы:** Полная поддержка русского и английского языков, темная (Slate Dark) и светлая (Clean Light) темы Fluent Design.
- **🧩 Модульная система плагинов (Plugin Architecture):**
  - Изолированные веб-плагины, работающие в защищенных песочницах WebView2 без оверхеда на основной процесс.
  - **Встроенные плагины v1.1.0 "из коробки":**
    - 🎨 **Шрифты (Font Viewer):** `.ttf`, `.otf`, `.woff`, `.woff2` (OpenType санитайзер, глифы, панграммы).
    - 🧊 **3D Модели (3D Viewer):** `.stl`, `.obj`, `.gltf`, `.glb`, `.ply` (Three.js WebGL, студийное освещение, пресеты материалов, 360° вертушка, полигональная статистика).
    - 📄 **Word Документы (Docx Viewer):** `.docx`, `.doc` (Печатный макет А4, таблицы, изображения, ночной режим чтения).
    - 📊 **Электронные таблицы (Spreadsheet Viewer):** `.xlsx`, `.xls`, `.csv`, `.tsv`, `.ods` (Сетка Excel с формулами, вкладки листов, живой поиск).
    - 📽️ **Презентации (PowerPoint Viewer):** `.pptx`, `.ppt` (Интерактивное слайд-шоу, навигация стрелками, боковая лента миниатюр).
  - Разработка и сообщество плагинов: [peekit-plugins](https://github.com/kobaltgit/peekit-plugins).

---

## 🇬🇧 About Peekit

**Peekit** is an ultra-lightweight, native Windows 10 & 11 utility and part of the Windows utility ecosystem alongside **MiniBin v2**, **Undoit**, and **PolyShift**.

It enables instant file previews by pressing **Space** in File Explorer or on the Desktop without launching bulky third-party applications.

### ⚡ Key Benchmarks

| Parameter | Peekit v1.2.0 | QuickLook | PowerToys Peek |
| :--- | :--- | :--- | :--- |
| **Technology stack** | **Rust + Tauri v2 + Svelte 5** | C# / .NET / WPF | C++ / WinUI 3 (part of PowerToys) |
| **Background RAM usage** | **10–15 MB** | 30–50 MB | 100–200 MB |
| **Active preview RAM** | **~25–80 MB** (depending on plugin) | ~60–80 MB (text) / 150–300 MB (PDF, media) | 120–250 MB |
| **Cold response on Space** | **~ 50 ms** | ~50–80 ms | ~200–350 ms |
| **Distribution size** | **~3.4 MB** (installer) / 5.1 MB (portable) | ~90 MB | >200MB (full PowerToys suite) |
| **Plugin architecture** | **Isolated Web sandboxes (iframe + postMessage)** | .NET compiled DLLs | None |
| **Administrator rights** | **Not required (clean HKCU)** | Not required | Partially required |

### 🎯 Core Features

- **Instant Spacebar Activation:** Powered by native Rust Win32 low-level keyboard hooks.
- **Smart Typing & Rename Filter:** Does not interfere when renaming files in Explorer or typing in search bars.
- **Integrated Fluent Media Player:** Smooth playback for video and audio with timeline scrubber, volume slider, loop mode, and speed toggles.
- **Broad Format Coverage:** Images, multi-page PDFs, rendered Markdown, syntax-highlighted code, and ZIP archive contents without unpacking.
- **🧩 Extensible Plugin Architecture:**
  - Sandboxed WebView2 web-plugins with zero impact on background memory.
  - **Bundled Out-Of-The-Box Plugins (v1.1.0):**
    - 🎨 **Fonts:** `.ttf`, `.otf`, `.woff`, `.woff2` (OpenType sanitizer fallback, custom pangrams, glyph viewer).
    - 🧊 **3D Models:** `.stl`, `.obj`, `.gltf`, `.glb`, `.ply` (Three.js WebGL, studio lighting, materials, 360° turntable, polygon/vertex stats).
    - 📄 **Word Documents:** `.docx`, `.doc` (A4 print layout, tables, images, dark/light reading modes).
    - 📊 **Spreadsheets:** `.xlsx`, `.xls`, `.csv`, `.tsv`, `.ods` (Excel grid, formula bar, multi-sheet tabs, live search).
    - 📽️ **Presentations:** `.pptx`, `.ppt` (Slide-show stage, keyboard navigation, thumbnail strip).
  - Ecosystem & Developer repo: [peekit-plugins](https://github.com/kobaltgit/peekit-plugins).
- **Zero Admin / Portable:** Runs entirely in user mode (HKCU).

---

## 🛠️ Локальное тестирование / Local Development

```bash
# 1. Сборка фронтенда (Svelte 5 + Vite)
npm install
npm run build

# 2. Проверка бэкенда Rust (Tauri v2)
cd src-tauri
cargo check

# 3. Запуск локального промо-сайта (Flutter Web)
cd ../website
flutter run -d chrome
```

---

## 📄 Лицензия / License

Распространяется под свободной лицензией **MIT**. Подробности в файле [LICENSE](LICENSE).
