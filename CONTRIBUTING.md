# Contributing to Peekit

Спасибо за интерес к проекту! Peekit является частью экосистемы **Kobalt Tools** и придерживается единых стандартов разработки.

## 🛠️ Стек и требования

| Компонент | Технология | Версия |
|-----------|-----------|--------|
| Backend | Rust | 2021 Edition |
| Desktop framework | Tauri | v2.x |
| Frontend | Svelte | v5 (Runes) |
| Промо-сайт | Flutter Web | stable |

### Железные правила

- ❌ **Никакого Electron** — только Rust + Tauri v2
- ❌ **Никакого Svelte 4** — только синтаксис Runes (`$state`, `$derived`, `$effect`, `$props`)
- ✅ **RAM в фоне < 25 МБ** — проверяй через Task Manager перед PR
- ✅ **Fluent Acrylic Glassmorphism** — `backdrop-filter: blur`, поддержка тёмной и светлой темы

---

## 🚀 Локальная разработка

```bash
# Клонировать репозиторий
git clone https://github.com/kobaltgit/peekit.git
cd peekit

# Установить зависимости
npm install

# Запустить в режиме разработки
npm run tauri dev
```

**Требования:**
- [Rust](https://rustup.rs/) (stable)
- [Node.js](https://nodejs.org/) 18+
- [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) (Windows)

---

## 📋 Процесс contributing

### 1. Создай Issue

Перед началом работы — открой Issue с описанием проблемы или предложения. Это поможет избежать дублирования усилий.

### 2. Fork & Branch

```bash
git checkout -b fix/issue-name
# или
git checkout -b feat/feature-name
```

### 3. Правила коммитов

Используй [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: добавить поддержку формата .heic
fix: исправить зависание при переименовании файла
perf: оптимизировать загрузку PDF
docs: обновить README
ci: обновить workflow деплоя
```

### 4. Обновление промо-сайта

Если изменяешь или добавляешь функционал — **обязательно** отразить это в `website/`:
- `HeroSection` — основные тезисы
- `FeaturesGrid` — карточки возможностей
- `ComparisonTable` — таблица сравнения
- `SupportedFormats` — поддерживаемые форматы
- `FaqSection` — FAQ

### 5. Pull Request

- Заполни шаблон PR
- Убедись, что `npm run tauri build` завершается без ошибок
- Проверь потребление RAM в фоне (должно быть < 25 МБ)

---

## 🐛 Баг-репорты

При создании Issue с багом укажи:
- Версию Windows (10 / 11)
- Тип файла, который не открывается
- Шаги воспроизведения
- Лог из `output/peekit_debug.log` (если есть)

---

## 📄 Лицензия

Внося вклад в проект, ты соглашаешься с тем, что твои изменения будут распространяться под лицензией [MIT](LICENSE).
