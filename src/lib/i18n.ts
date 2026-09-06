import { writable } from 'svelte/store';
import type { AppLanguage } from './types';

export const translations = {
  ru: {
    app_title: 'Peekit',
    app_subtitle: 'Мгновенный просмотр по пробелу',
    open_in_app: 'Открыть в приложении',
    reveal_in_folder: 'Показать в папке',
    copy_path: 'Скопировать путь',
    path_copied: 'Путь скопирован в буфер!',
    pin_window: 'Закрепить поверх окон',
    unpin_window: 'Открепить',
    close: 'Закрыть (Esc или Space)',
    settings: 'Настройки',
    no_file_selected: 'Файл не выбран',
    select_file_hint: 'Нажмите Пробел на любом файле в Проводнике или на Рабочем столе',
    
    // File info
    size: 'Размер',
    modified: 'Изменён',
    dimensions: 'Разрешение',
    lines: 'Строк',
    duration: 'Длительность',
    pages: 'Страниц',
    page_of: 'из',
    archive_files_count: 'Файлов в архиве',
    compression_ratio: 'Сжатие',
    cloud_placeholder_badge: 'Облачный файл (OneDrive)',
    cloud_placeholder_desc: 'Файл хранится в облаке и не скачан локально. Предпросмотр содержимого ограничен системной иконкой.',

    // Media Player
    media_player: 'Медиаплеер',
    play: 'Воспроизвести',
    pause: 'Пауза',
    mute: 'Выключить звук',
    unmute: 'Включить звук',
    volume: 'Громкость',
    loop: 'Зациклить',
    speed: 'Скорость',
    audio_track: 'Аудиодорожка',
    video_track: 'Видео',

    // Archive viewer
    archive_name: 'Имя файла',
    archive_size: 'Размер',
    archive_compressed: 'Сжатый',
    archive_empty: 'Архив пуст',

    // Code & text
    code_raw: 'Исходный текст',
    markdown_rendered: 'Превью (HTML)',
    copy_code: 'Скопировать текст',
    code_copied: 'Скопировано в буфер!',

    // Settings
    settings_title: 'Параметры Peekit',
    general_tab: 'Основные',
    appearance_tab: 'Внешний вид',
    about_tab: 'О программе',
    language: 'Язык интерфейса',
    theme: 'Тема оформления',
    theme_dark: 'Тёмная (Slate Dark)',
    theme_light: 'Светлая (Clean Light)',
    theme_system: 'Системная',
    autostart: 'Запускать вместе с Windows (HKCU, без прав админа)',
    close_on_blur: 'Закрывать при потере фокуса',
    autoplay_media: 'Автовоспроизведение аудио и видео',
    stay_on_top: 'Окно всегда поверх остальных',
    hotkeys_title: 'Горячие клавиши',
    hotkey_space: 'Пробел: открыть / закрыть превью',
    hotkey_esc: 'Escape: закрыть окно',
    hotkey_arrows: 'Стрелки (↑ ↓ ← →): переключение на соседний файл',
    hotkey_enter: 'Enter: открыть файл в стандартной программе',
    version: 'Версия',
    author: 'Разработчик: Kobalt',
    github_link: 'Репозиторий проекта на GitHub',
    website_link: 'Официальный сайт Peekit',
    plugins_repo_link: 'Каталог плагинов PeekIt',
    // Plugins
    plugins_tab: 'Плагины',
    plugins_desc: 'Установленные веб-плагины для расширения форматов файлов',
    plugins_open_folder: 'Открыть папку плагинов',
    plugins_refresh: 'Обновить',
    plugins_empty: 'Плагины не найдены. Поместите плагин в папку или установите из каталога.',
    plugins_extensions: 'Расширения',
    plugins_by: 'Автор',
    plugins_version: 'Версия',
    plugins_install_btn: 'Установить файл (.pkit)',
    plugins_installed_success: 'Плагин успешно установлен!',

    // Marketplace / Store
    plugins_subtab_installed: 'Установленные',
    plugins_subtab_store: 'Каталог плагинов',
    store_search_placeholder: 'Поиск по названию или расширению (.psd, .3d, .docx)...',
    store_install: 'Установить',
    store_installing: 'Установка...',
    store_installed: 'Установлен',
    store_update: 'Обновить',
    store_empty: 'Плагины не найдены',
    store_failed_load: 'Не удалось загрузить каталог из сети',

    save: 'Сохранить',
    close_settings: 'Закрыть',
  },
  en: {
    app_title: 'Peekit',
    app_subtitle: 'Instant Spacebar File Preview',
    open_in_app: 'Open in Default App',
    reveal_in_folder: 'Show in Explorer',
    copy_path: 'Copy File Path',
    path_copied: 'Path copied to clipboard!',
    pin_window: 'Pin on Top',
    unpin_window: 'Unpin Window',
    close: 'Close (Esc or Space)',
    settings: 'Settings',
    no_file_selected: 'No file selected',
    select_file_hint: 'Press Space on any file in Windows Explorer or Desktop',

    // File info
    size: 'Size',
    modified: 'Modified',
    dimensions: 'Resolution',
    lines: 'Lines',
    duration: 'Duration',
    pages: 'Pages',
    page_of: 'of',
    archive_files_count: 'Files in archive',
    compression_ratio: 'Compression',
    cloud_placeholder_badge: 'Cloud File (OneDrive)',
    cloud_placeholder_desc: 'This file is hosted in cloud storage and not downloaded locally. Preview is limited to system thumbnail.',

    // Media Player
    media_player: 'Media Player',
    play: 'Play',
    pause: 'Pause',
    mute: 'Mute',
    unmute: 'Unmute',
    volume: 'Volume',
    loop: 'Loop',
    speed: 'Speed',
    audio_track: 'Audio Track',
    video_track: 'Video',

    // Archive viewer
    archive_name: 'Filename',
    archive_size: 'Size',
    archive_compressed: 'Compressed',
    archive_empty: 'Archive is empty',

    // Code & text
    code_raw: 'Raw Text',
    markdown_rendered: 'Preview (HTML)',
    copy_code: 'Copy Text',
    code_copied: 'Copied to clipboard!',

    // Settings
    settings_title: 'Peekit Preferences',
    general_tab: 'General',
    appearance_tab: 'Appearance',
    about_tab: 'About',
    language: 'Interface Language',
    theme: 'Color Theme',
    theme_dark: 'Dark (Slate Dark)',
    theme_light: 'Light (Clean Light)',
    theme_system: 'System Default',
    autostart: 'Launch at Windows startup (HKCU, no admin needed)',
    close_on_blur: 'Close preview when focus is lost',
    autoplay_media: 'Autoplay audio and video on preview',
    stay_on_top: 'Keep preview window always on top',
    hotkeys_title: 'Keyboard Shortcuts',
    hotkey_space: 'Space: Toggle preview window',
    hotkey_esc: 'Escape: Close preview',
    hotkey_arrows: 'Arrow Keys (↑ ↓ ← →): Switch to adjacent file in folder',
    hotkey_enter: 'Enter: Open file in default application',
    version: 'Version',
    author: 'Developer: Kobalt',
    github_link: 'Project GitHub Repository',
    website_link: 'Official Peekit Website',
    plugins_repo_link: 'PeekIt Plugins Catalog',

    // Plugins
    plugins_tab: 'Plugins',
    plugins_desc: 'Installed web plugins extending supported file formats',
    plugins_open_folder: 'Open Plugins Folder',
    plugins_refresh: 'Refresh',
    plugins_empty: 'No plugins found. Place plugins into the folder or install from the store.',
    plugins_extensions: 'Extensions',
    plugins_by: 'Author',
    plugins_version: 'Version',
    plugins_install_btn: 'Install File (.pkit)',
    plugins_installed_success: 'Plugin installed successfully!',

    // Marketplace / Store
    plugins_subtab_installed: 'Installed',
    plugins_subtab_store: 'Plugin Store',
    store_search_placeholder: 'Search by name or extension (.psd, .3d, .docx)...',
    store_install: 'Install',
    store_installing: 'Installing...',
    store_installed: 'Installed',
    store_update: 'Update',
    store_empty: 'No plugins found',
    store_failed_load: 'Failed to load plugin store from network',

    save: 'Save',
    close_settings: 'Close',
  }
};

export type TranslationKey = keyof typeof translations.en;

export const currentLanguage = writable<AppLanguage>('ru');

export function t(key: TranslationKey, lang: AppLanguage = 'ru'): string {
  return translations[lang]?.[key] ?? translations.en[key] ?? key;
}
