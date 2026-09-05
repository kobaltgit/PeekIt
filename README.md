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

| Параметр | Peekit (Rust + Tauri v2) | Старый QuickLook (C# / WPF) | PowerToys Peek |
| :--- | :--- | :--- | :--- |
| **ОЗУ в фоне** | **10–15 МБ** | 80–150 МБ | 100–200 МБ |
| **Время отклика** | **< 50 мс** | 250–600 мс | 200–400 мс |
| **Встроенный медиаплеер** | **Да (полный Fluent-контроллер)** | Базовый | Ограниченный |
| **Права администратора** | **Не требуются (HKCU, без UAC)** | Не требуются | Частично |
| **Размер дистрибутива** | **~10 МБ** | ~50 МБ | > 200 МБ |

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
