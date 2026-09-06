class WebsiteI18n {
  static const Map<String, Map<String, String>> _strings = {
    'ru': {
      'nav_features': 'Возможности',
      'nav_formats': 'Форматы',
      'nav_plugins': 'Плагины',
      'nav_demo': 'Интерактивное демо',
      'nav_compare': 'Сравнение',
      'nav_faq': 'Вопросы и ответы',
      'nav_download': 'Скачать',

      // Plugins Showcase
      'plugins_tag': 'ЭКОСИСТЕМА РАСШИРЕНИЙ',
      'plugins_title': 'Плагины для любых профессиональных форматов',
      'plugins_subtitle': 'Устанавливайте поддержку графики, 3D, офисных документов и шрифтов в 1 клик прямо из встроенного магазина PeekIt. Каждый плагин изолирован в защищенной песочнице и работает с нулевым фоновым потреблением памяти.',
      'cat_all': 'Все',
      'cat_graphics': 'Графика',
      'cat_3d': '3D',
      'cat_docs': 'Документы',
      'cat_fonts': 'Шрифты',
      'cat_sheets': 'Таблицы',
      'plugins_store_title': 'Встроенный магазин плагинов прямо в PeekIt',
      'plugins_store_desc': 'Откройте контекстное меню трея PeekIt и выберите «Магазин плагинов», чтобы устанавливать и обновлять плагины из сети в 1 клик без ручной распаковки архивов.',
      'plugins_btn_catalog': 'Каталог плагинов',

      // Plugin Descriptions & Features (RU)
      'plugin_psd_desc': 'Высокоточный просмотр макетов Adobe Photoshop с векторно-растровым рендерингом.',
      'plugin_psd_f1': 'Просмотр и скрытие отдельных слоев макета',
      'plugin_psd_f2': 'Панорамирование и зум от 10% до 800%',
      'plugin_psd_f3': 'Инспекция цветового пространства и метаданных',

      'plugin_ai_desc': 'Векторный просмотр иллюстраций и дизайн-макетов Adobe Illustrator.',
      'plugin_ai_f1': 'Переключение между монтажными областями (артбордами)',
      'plugin_ai_f2': 'Плавный векторный зум без потери четкости',
      'plugin_ai_f3': 'Отображение размеров полотна и палитры документа',

      'plugin_eps_desc': 'Мгновенный просмотр векторных и полиграфических файлов Encapsulated PostScript.',
      'plugin_eps_f1': 'Парсинг векторных PostScript-контуров',
      'plugin_eps_f2': 'Извлечение встроенных превью TIFF / WMF',
      'plugin_eps_f3': 'Полноэкранный просмотр логотипов и векторных иконок',

      'plugin_3d_desc': 'Интерактивный просмотр 3D-моделей на движке Three.js с аппаратным ускорением WebGL.',
      'plugin_3d_f1': '4 студийных шейдера: глина, серый, металл, нормали',
      'plugin_3d_f2': 'Режимы шейдинга: сглаженный, flat и сетка (wireframe)',
      'plugin_3d_f3': 'Плавное вращение 360° (вертушка) и подсчет полигонов',

      'plugin_docx_desc': 'Быстрый офлайн-просмотр документов Microsoft Word с сохранением оригинальной верстки.',
      'plugin_docx_f1': 'Реалистичный печатный макет A4 с тенями и полями',
      'plugin_docx_f2': 'Таблицы, форматирование текста, списки и заголовки',
      'plugin_docx_f3': 'Ночной режим чтения с мягким темным фоном',

      'plugin_ebook_desc': 'Удобное и стильное чтение электронных книг в форматах EPUB и FB2.',
      'plugin_ebook_f1': 'Боковое оглавление с быстрым переходом по главам',
      'plugin_ebook_f2': '3 палитры оформления: светлая, сепия и ночная',
      'plugin_ebook_f3': 'Регулировка размера шрифта и межстрочного интервала',

      'plugin_sheet_desc': 'Просмотр электронных таблиц Excel и CSV/TSV с интерактивной сеткой ячеек.',
      'plugin_sheet_f1': 'Переключатель вкладок листов книги (Sheet1, Sheet2...)',
      'plugin_sheet_f2': 'Инспектор выбранной ячейки и просмотр формул',
      'plugin_sheet_f3': 'Живой мгновенный поиск по значениям таблицы',

      'plugin_slides_desc': 'Просмотр презентаций PowerPoint в формате интерактивного слайд-шоу.',
      'plugin_slides_f1': 'Боковая панель миниатюр слайдов с быстрой навигацией',
      'plugin_slides_f2': 'Полноэкранный просмотр с адаптацией 16:9 и 4:3',
      'plugin_slides_f3': 'Удобное переключение стрелками и клавишей Space',

      'plugin_font_desc': 'Интерактивная типографика и тестирование шрифтовых файлов.',
      'plugin_font_f1': 'Полная таблица глифов с шестнадцатеричными Unicode-кодами',
      'plugin_font_f2': 'Выбор кегля (размера) шрифта от 12px до 96px',
      'plugin_font_f3': 'Набор панграмм на русском, английском и цифрах',

      // Hero
      'hero_tag': 'ЭКОСИСТЕМА WINDOWS СИСТЕМНЫХ УТИЛИТ',
      'hero_title': 'Мгновенный просмотр любых файлов по клавише Space',
      'hero_subtitle': 'Легковесная нативная утилита на Rust и Tauri v2. Забудьте о запуске тяжелых программ: наведите курсор на файл в Проводнике или на Рабочем столе и нажмите Пробел.',
      'hero_btn_download': 'Скачать для Windows',
      'hero_btn_github': 'Исходный код на GitHub',
      'hero_badge_ram': '10–15 МБ ОЗУ',
      'hero_badge_speed': 'Запуск < 50 мс',
      'hero_badge_rust': '100% Rust & Win32',

      // Features
      'feat_title': 'Почему Peekit лучше стандартных решений',
      'feat_subtitle': 'Разработано с нуля для максимального комфорта и скорости работы в Windows 10 & 11',
      
      'feat_1_title': 'Бескомпромиссная скорость',
      'feat_1_desc': 'Нативное ядро на Rust с прямыми вызовами Win32 COM API. Никаких виртуальных машин .NET или фреймворков Electron.',
      
      'feat_2_title': 'Встроенный медиаплеер',
      'feat_2_desc': 'Мгновенное воспроизведение видео (MP4, WebM) и аудио (MP3, WAV, FLAC) с таймлайном, зацикливанием и регулятором громкости.',

      'feat_3_title': 'Умный фильтр ввода',
      'feat_3_desc': 'Хук клавиатуры не перехватывает Пробел при переименовании файлов в Проводнике, поиске или наборе текста.',

      'feat_4_title': 'Безопасность и HKCU',
      'feat_4_desc': 'Не требует прав администратора и не показывает назойливые окна UAC. Полностью портативный режим из коробки.',

      'feat_5_title': 'Поддержка вкладок Win 11',
      'feat_5_desc': 'Корректно определяет активную вкладку в новом Проводнике Windows 11 и на Рабочем столе.',

      'feat_6_title': '100% Приватность',
      'feat_6_desc': 'Никакой фоновой телеметрии, сбора данных или облачных серверов. Всё работает строго на вашем компьютере.',

      // Formats
      'formats_title': 'Поддерживаемые форматы файлов',
      'formats_subtitle': 'Один хоткей для десятков типов контента',
      'fmt_images': 'Изображения',
      'fmt_images_desc': 'PNG, JPG, WebP, GIF, SVG, BMP, ICO с зумом и разрешением.',
      'fmt_media': 'Медиаплеер',
      'fmt_media_desc': 'MP4, WebM, MKV, MP3, WAV, FLAC, OGG с Fluent-контроллером.',
      'fmt_code': 'Код и текст',
      'fmt_code_desc': 'Подсветка синтаксиса для 50+ языков, нумерация строк, копирование.',
      'fmt_docs': 'Документы и PDF',
      'fmt_docs_desc': 'PDF-документы с постраничной навигацией и Markdown с рендером.',
      'fmt_archives': 'Архивы ZIP',
      'fmt_archives_desc': 'Быстрый просмотр состава архивов без распаковки на диск.',

      // Demo
      'demo_title': 'Интерактивная песочница Peekit',
      'demo_subtitle': 'Кликните на файл в виртуальном Проводнике ниже или нажмите клавишу Space',
      'demo_explorer_bar': 'Этот компьютер > Документы > Проект',
      'demo_press_space': 'Нажмите Space для предпросмотра',
      'demo_close_hint': 'Нажмите Esc или Space для закрытия',

      // Comparison
      'compare_title': 'Сравнение с аналогами',
      'compare_subtitle': 'Реальные показатели производительности',
      'col_param': 'Характеристика',
      'col_peekit': 'Peekit (Rust + Tauri v2)',
      'col_msstore': 'Старый QuickLook (C# / WPF)',
      'col_powertoys': 'PowerToys Peek',
      'param_ram': 'Потребление ОЗУ',
      'param_ram_peekit': '10–15 МБ',
      'param_ram_ms': '80–150 МБ',
      'param_ram_pt': '100–200 МБ (фон)',
      'param_speed': 'Время отклика',
      'param_speed_peekit': '< 50 мс',
      'param_speed_ms': '250–600 мс',
      'param_speed_pt': '200–400 мс',
      'param_media': 'Встроенный медиаплеер',
      'param_media_peekit': 'Да (с контроллером)',
      'param_media_ms': 'Базовый',
      'param_media_pt': 'Ограниченный',
      'param_admin': 'Требует права админа',
      'param_admin_peekit': 'Нет (HKCU)',
      'param_admin_ms': 'Нет',
      'param_admin_pt': 'Частично',
      'param_size': 'Размер дистрибутива',
      'param_size_peekit': '~10 МБ',
      'param_size_ms': '~50 МБ',
      'param_size_pt': '> 200 МБ (весь пакет)',

      // FAQ
      'faq_title': 'Часто задаваемые вопросы',
      'faq_1_q': 'Как работает вызов по клавише Пробел?',
      'faq_1_a': 'Peekit использует низкоуровневый системный хук Windows. Он активируется только тогда, когда активным окном является Проводник или Рабочий стол. При наборе текста пробел работает как обычно.',
      'faq_2_q': 'Нужны ли права администратора (UAC)?',
      'faq_2_a': 'Нет. Peekit спроектирован для работы исключительно в пользовательском пространстве (HKCU). Он не модифицирует системные DLL и не требует подтверждения UAC.',
      'faq_3_q': 'Есть ли портативная версия?',
      'faq_3_a': 'Да, достаточно скачать .zip архив. Peekit сохраняет все свои параметры рядом с исполняемым файлом при наличии файла portable.txt.',

      // CTA
      'cta_title': 'Установите Peekit и ускорьте работу с файлами',
      'cta_subtitle': 'Бесплатно, с открытым исходным кодом под лицензией MIT.',
      'cta_btn': 'Скачать релиз (Windows x64)',
      
      // Footer
      'footer_ecosystem': 'Экосистема утилит:',
      'footer_minibin': 'MiniBin v2 — Корзина в системном трее',
      'footer_undoit': 'Undoit — Машина времени для файлов',
      'footer_polyshift': 'PolyShift — Умный перевод и ИИ',
      'footer_peekit': 'Peekit — Мгновенный просмотр файлов',
      'footer_rights': '© 2026 Kobalt. Открытый исходный код под лицензией MIT.',
    },
    'en': {
      'nav_features': 'Features',
      'nav_formats': 'Formats',
      'nav_plugins': 'Plugins',
      'nav_demo': 'Interactive Demo',
      'nav_compare': 'Comparison',
      'nav_faq': 'FAQ',
      'nav_download': 'Download',

      // Plugins Showcase
      'plugins_tag': 'EXTENSIONS ECOSYSTEM',
      'plugins_title': 'Plugins for Any Professional File Format',
      'plugins_subtitle': 'Install graphics, 3D, office, and typography support in 1 click directly from the in-app PeekIt store. Every plugin is safely sandboxed with zero persistent background memory footprint.',
      'cat_all': 'All',
      'cat_graphics': 'Graphics',
      'cat_3d': '3D',
      'cat_docs': 'Documents',
      'cat_fonts': 'Fonts',
      'cat_sheets': 'Sheets',
      'plugins_store_title': 'Built-In Plugin Store Directly Inside PeekIt',
      'plugins_store_desc': 'Right-click PeekIt tray icon and choose "Plugin Store" to download and update plugins with a single click — no manual archive extractions required.',
      'plugins_btn_catalog': 'Browse Catalog',

      // Plugin Descriptions & Features (EN)
      'plugin_psd_desc': 'High-fidelity previewer for Adobe Photoshop files with layer inspection and vector rendering.',
      'plugin_psd_f1': 'Inspect and toggle individual layer visibility',
      'plugin_psd_f2': 'Smooth panning and zooming from 10% to 800%',
      'plugin_psd_f3': 'Color space and embedded metadata inspection',

      'plugin_ai_desc': 'Vector previewer for Adobe Illustrator design files and artwork.',
      'plugin_ai_f1': 'Switch between multiple artboards seamlessly',
      'plugin_ai_f2': 'Infinite vector zoom without loss of sharpness',
      'plugin_ai_f3': 'Document canvas dimensions and color profile view',

      'plugin_eps_desc': 'Instant viewer for Encapsulated PostScript vector and print files.',
      'plugin_eps_f1': 'Vector PostScript path parsing and rendering',
      'plugin_eps_f2': 'Embedded TIFF and WMF preview extraction',
      'plugin_eps_f3': 'Full-fidelity preview for logos and vector icons',

      'plugin_3d_desc': 'Interactive 3D model viewer powered by Three.js with hardware WebGL acceleration.',
      'plugin_3d_f1': '4 studio shaders: clay, studio grey, metal, normals',
      'plugin_3d_f2': 'Shading modes: smooth, flat, and wireframe mesh',
      'plugin_3d_f3': 'Smooth 360° turntable auto-rotation and polygon counter',

      'plugin_docx_desc': 'Fast offline Microsoft Word reader preserving document layout and formatting.',
      'plugin_docx_f1': 'Realistic A4 print page layout with margins and shadows',
      'plugin_docx_f2': 'Tables, text formatting, bullet lists, and headings',
      'plugin_docx_f3': 'Night reading mode with eye-friendly dark background',

      'plugin_ebook_desc': 'Comfortable and elegant offline reader for EPUB and FB2 e-books.',
      'plugin_ebook_f1': 'Sidebar table of contents with quick chapter jumping',
      'plugin_ebook_f2': '3 color themes: Clean Light, Warm Sepia, Dark Night',
      'plugin_ebook_f3': 'Customizable font sizing and line spacing',

      'plugin_sheet_desc': 'Excel spreadsheet and CSV/TSV viewer with interactive cell grid.',
      'plugin_sheet_f1': 'Workbook sheet tab bar (Sheet1, Sheet2...)',
      'plugin_sheet_f2': 'Selected cell inspector and formula viewer bar',
      'plugin_sheet_f3': 'Live instant search across all cell values',

      'plugin_slides_desc': 'PowerPoint presentation viewer in an interactive slide-deck format.',
      'plugin_slides_f1': 'Sidebar slide thumbnails strip for rapid navigation',
      'plugin_slides_f2': 'Fullscreen mode with 16:9 and 4:3 aspect ratio fit',
      'plugin_slides_f3': 'Effortless keyboard navigation with arrow keys and Space',

      'plugin_font_desc': 'Interactive typography workbench and font file tester.',
      'plugin_font_f1': 'Complete Unicode glyph table with hex code inspection',
      'plugin_font_f2': 'Interactive font size slider from 12px to 96px',
      'plugin_font_f3': 'Built-in pangram test sentences in Cyrillic & Latin',

      // Hero
      'hero_tag': 'WINDOWS UTILITIES ECOSYSTEM',
      'hero_title': 'Instant Spacebar File Preview for Windows 10 & 11',
      'hero_subtitle': 'Lightweight native utility built with Rust and Tauri v2. Stop waiting for heavy apps: highlight any file in Explorer or Desktop and hit Space.',
      'hero_btn_download': 'Download for Windows',
      'hero_btn_github': 'Source on GitHub',
      'hero_badge_ram': '10–15 MB RAM',
      'hero_badge_speed': '< 50ms Startup',
      'hero_badge_rust': '100% Rust & Win32',

      // Features
      'feat_title': 'Why Peekit Outperforms the Rest',
      'feat_subtitle': 'Architected from scratch for maximum responsiveness and zero overhead',
      
      'feat_1_title': 'Uncompromising Speed',
      'feat_1_desc': 'Native Rust core directly accessing Win32 COM APIs. No .NET runtime penalties, no Electron bloat.',
      
      'feat_2_title': 'Integrated Media Player',
      'feat_2_desc': 'Instant playback of video (MP4, WebM) and audio (MP3, WAV, FLAC) with custom scrubber, loop, and volume.',

      'feat_3_title': 'Smart Typing Filter',
      'feat_3_desc': 'Keyboard hook automatically suppresses intercept while you rename files in Explorer or type in search fields.',

      'feat_4_title': 'User Space Security',
      'feat_4_desc': 'Runs entirely in HKCU without administrator privileges or annoying UAC prompts. Fully portable.',

      'feat_5_title': 'Windows 11 Tabs Ready',
      'feat_5_desc': 'Seamlessly resolves the active tab in Windows 11 multi-tab Explorer and Desktop surfaces.',

      'feat_6_title': '100% Offline & Private',
      'feat_6_desc': 'Zero analytics, no tracking, no cloud dependencies. Everything executes strictly on your local machine.',

      // Formats
      'formats_title': 'Extensive File Format Support',
      'formats_subtitle': 'One universal hotkey for all your everyday files',
      'fmt_images': 'Images',
      'fmt_images_desc': 'PNG, JPG, WebP, GIF, SVG, BMP, ICO with zoom and pixel resolution info.',
      'fmt_media': 'Media Player',
      'fmt_media_desc': 'MP4, WebM, MKV, MP3, WAV, FLAC, OGG with full Fluent controller.',
      'fmt_code': 'Code & Text',
      'fmt_code_desc': 'Syntax highlighting for 50+ languages, line numbers, and fast copy.',
      'fmt_docs': 'Documents & PDF',
      'fmt_docs_desc': 'Multi-page PDF reader with zoom and Markdown with rich HTML render.',
      'fmt_archives': 'ZIP Archives',
      'fmt_archives_desc': 'Inspect file contents inside archives without uncompressing to disk.',

      // Demo
      'demo_title': 'Interactive Peekit Sandbox',
      'demo_subtitle': 'Click any file in the virtual Explorer below or press Space on your keyboard',
      'demo_explorer_bar': 'This PC > Documents > Workspace',
      'demo_press_space': 'Press Space to preview',
      'demo_close_hint': 'Press Esc or Space to close',

      // Comparison
      'compare_title': 'Benchmarked Against Alternatives',
      'compare_subtitle': 'Real-world metrics that make a difference',
      'col_param': 'Feature',
      'col_peekit': 'Peekit (Rust + Tauri v2)',
      'col_msstore': 'Legacy QuickLook (C# / WPF)',
      'col_powertoys': 'PowerToys Peek',
      'param_ram': 'RAM Consumption',
      'param_ram_peekit': '10–15 MB',
      'param_ram_ms': '80–150 MB',
      'param_ram_pt': '100–200 MB (suite)',
      'param_speed': 'Latency to Preview',
      'param_speed_peekit': '< 50 ms',
      'param_speed_ms': '250–600 ms',
      'param_speed_pt': '200–400 ms',
      'param_media': 'Built-in Media Player',
      'param_media_peekit': 'Yes (Fluent controls)',
      'param_media_ms': 'Basic',
      'param_media_pt': 'Limited',
      'param_admin': 'Requires Admin / UAC',
      'param_admin_peekit': 'No (HKCU)',
      'param_admin_ms': 'No',
      'param_admin_pt': 'Partial',
      'param_size': 'Installer Size',
      'param_size_peekit': '~10 MB',
      'param_size_ms': '~50 MB',
      'param_size_pt': '> 200 MB (full pack)',

      // FAQ
      'faq_title': 'Frequently Asked Questions',
      'faq_1_q': 'How does Spacebar activation work?',
      'faq_1_a': 'Peekit registers a low-level Windows keyboard hook that only triggers when Windows Explorer or Desktop is in the foreground. If you are typing or renaming a file, it passes through untouched.',
      'faq_2_q': 'Do I need Administrator permissions?',
      'faq_2_a': 'No. Peekit runs entirely in user mode (HKCU). It requires no UAC elevation and modifies no protected system directories.',
      'faq_3_q': 'Is there a portable version available?',
      'faq_3_a': 'Yes, simply grab the standalone .zip release. Peekit detects portable.txt and stores configuration directly alongside the executable.',

      // CTA
      'cta_title': 'Supercharge your Windows workflow with Peekit',
      'cta_subtitle': 'Free, open source under the MIT License.',
      'cta_btn': 'Download Latest Release (Windows x64)',
      
      // Footer
      'footer_ecosystem': 'Utilities Ecosystem:',
      'footer_minibin': 'MiniBin v2 — System Tray Recycle Bin',
      'footer_undoit': 'Undoit — Local File Time Machine',
      'footer_polyshift': 'PolyShift — AI Translation & Assist',
      'footer_peekit': 'Peekit — Instant Spacebar File Preview',
      'footer_rights': '© 2026 Kobalt. Open source under MIT License.',
    }
  };

  static String t(String key, String lang) {
    return _strings[lang]?[key] ?? _strings['en']?[key] ?? key;
  }
}
