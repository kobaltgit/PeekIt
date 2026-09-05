class WebsiteI18n {
  static const Map<String, Map<String, String>> _strings = {
    'ru': {
      'nav_features': 'Возможности',
      'nav_formats': 'Форматы',
      'nav_demo': 'Интерактивное демо',
      'nav_compare': 'Сравнение',
      'nav_faq': 'Вопросы и ответы',
      'nav_download': 'Скачать',

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
      'nav_demo': 'Interactive Demo',
      'nav_compare': 'Comparison',
      'nav_faq': 'FAQ',
      'nav_download': 'Download',

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
