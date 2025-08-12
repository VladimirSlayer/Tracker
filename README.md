# Tracker

[Русская версия ниже](#русская-версия)

## Overview

**Tracker** is a UIKit‑based iOS app for habit & event tracking with a clean, fully programmatic interface and local persistence via **Core Data**. It features a two‑tab layout (Trackers, Statistics), first‑run onboarding, creating trackers with schedule, category, emoji & color, and daily completion marks.

* Minimum iOS: **13.4**
* Language: **Swift 5**
* UI: **UIKit** (no Main.storyboard; programmatic layout)
* Persistence: **Core Data** (`NSPersistentContainer`)
* Architecture: **MVC + Stores (Core Data) + ViewModels (for creation/selection screens)**
* External deps: **None** (Apple frameworks only)

## Features

* 🧭 **Onboarding** on first launch (skipped thereafter via `UserDefaults` flag)
* 🗂️ **Two tabs**: Trackers list and basic Statistics
* ➕ **Create trackers** of two types: **habit** and **event** (irregular)
* 🗓️ **Schedule** on specific weekdays (Mon–Sun)
* 🏷️ **Categories** management (select or create a new category)
* 😀 **Emoji** & 🎨 **Color** picker
* ✅ **Mark as completed** for the current day (toggle)
* 🔍 **Search** and **filter** by date; shows only trackers scheduled for the selected day

## Architecture

* **Presentation (UIKit)**

  * `TrackersViewController`, `StatisticsViewController`
  * Creation/selection flow: `TrackerTypeSelectionViewController`, `NewTrackerViewController`, `ScheduleViewController`, `CategorySelectionViewController`, `NewCategoryViewController`
  * Onboarding: `OnboardingViewController`, `OnboardingPageContentViewController`
* **Models** (plain Swift + convenience inits from Core Data)

  * `Tracker`, `TrackerRecord`, `TrackerCategory`, `TrackerCell`, `TrackerViewModel`, `Weekday`, `TrackerType`
* **Data / Stores (Core Data)**

  * `CoreDataStack` (singleton, `NSPersistentContainer` name `TrackerModel`)
  * Stores: `TrackerStore`, `TrackerRecordStore`, `TrackerCategoryStore` (with `NSFetchedResultsController` and delegate callbacks)
* **Delegates / Protocols**

  * `TrackerCreationDelegate`, `TrackerCategoryStoreDelegate`

### Data model (Core Data)

Entities (folder `CoreDataModels/TrackerModel.xcdatamodeld`):

* `TrackerCoreData` — `id: UUID`, `name: String`, `color: Transformable(UIColor)`, `emoji: String`, `schedule: Transformable([Weekday])`, `type: String(habit|event)`, `createdDate: Date`; relations: `category` (to `TrackerCategoryCoreData`), `records` (to many `TrackerRecordCoreData`).
* `TrackerCategoryCoreData` — `title: String`; relation: `trackers` (to many `TrackerCoreData`).
* `TrackerRecordCoreData` — `id: UUID`, `date: Date`, `trackerId: UUID`; relation: `tracker` (to `TrackerCoreData`).

> Note: color & schedule are stored as transformables; make sure secure transformers are configured when hardening for production.

## Getting started

1. **Xcode 15+**, iOS **13.4+**.
2. Open `Tracker.xcodeproj`.
3. Build & Run on Simulator or device.

### Notes

* The app builds UI programmatically; no `Main.storyboard` is used.
* First launch shows onboarding; completion toggles `UserDefaults` key `hasCompletedOnboarding`.

## Error handling & logging

* Stores use `NSFetchedResultsController` and print diagnostics on fetch/save errors.
* Completion toggling validates the date (no marking in the future).

## Roadmap

* Enrich **Statistics** tab (streaks, totals, charts)
* Unit tests with an in‑memory Core Data stack
* Migrate transformables to strongly typed transformers
* iCloud/CloudKit sync (optional)
* Accessibility & localization (EN/RU strings)

## License

Add a LICENSE file (e.g., MIT) when publishing.

---

# Русская версия

## Описание

**Tracker** — это iOS‑приложение на UIKit для отслеживания привычек и нерегулярных событий. Интерфейс полностью кодовый (без Main.storyboard), данные хранятся локально в **Core Data**. Приложение состоит из двух вкладок (Трекеры, Статистика), содержит онбординг при первом запуске, создание трекеров с расписанием, категорией, эмодзи и цветом, а также отметки выполнения по дням.

* Минимальная iOS: **13.4**
* Язык: **Swift 5**
* UI: **UIKit** (программная верстка)
* Хранилище: **Core Data** (`NSPersistentContainer`)
* Архитектура: **MVC + Stores (Core Data) + ViewModel‑экраны**
* Внешние зависимости: **нет**

## Возможности

* 🧭 **Онбординг** при первом запуске (далее пропускается через флаг `UserDefaults`)
* 🗂️ **Две вкладки**: список трекеров и простая статистика
* ➕ **Создание трекеров** двух типов: **привычка** и **нерегулярное событие**
* 🗓️ **Расписание** по дням недели (Mon–Sun)
* 🏷️ **Категории** (выбор/создание новой)
* 😀 **Эмодзи** и 🎨 **цвет**
* ✅ **Отметка выполнения** на текущую дату (переключатель)
* 🔍 **Поиск** и **фильтр по дате**; отображаются трекеры, запланированные на выбранный день

## Архитектура

* **Презентационный слой (UIKit)**

  * `TrackersViewController`, `StatisticsViewController`
  * Флоу создания/выбора: `TrackerTypeSelectionViewController`, `NewTrackerViewController`, `ScheduleViewController`, `CategorySelectionViewController`, `NewCategoryViewController`
  * Онбординг: `OnboardingViewController`, `OnboardingPageContentViewController`
* **Модели**

  * `Tracker`, `TrackerRecord`, `TrackerCategory`, `TrackerCell`, `TrackerViewModel`, `Weekday`, `TrackerType`
* **Данные / Stores (Core Data)**

  * `CoreDataStack` (синглтон, контейнер `TrackerModel`)
  * `TrackerStore`, `TrackerRecordStore`, `TrackerCategoryStore` (через `NSFetchedResultsController`)
* **Делегаты / протоколы**

  * `TrackerCreationDelegate`, `TrackerCategoryStoreDelegate`

### Модель данных (Core Data)

* `TrackerCoreData` — `id: UUID`, `name: String`, `color: Transformable(UIColor)`, `emoji: String`, `schedule: Transformable([Weekday])`, `type: String(habit|event)`, `createdDate: Date`; связи: `category`, `records`.
* `TrackerCategoryCoreData` — `title: String`; связь: `trackers`.
* `TrackerRecordCoreData` — `id: UUID`, `date: Date`, `trackerId: UUID`; связь: `tracker`.

> Примечание: `color` и `schedule` хранятся как transformable‑типы; для продакшена стоит добавить безопасные трансформеры.

## Структура проекта

См. дерево в английском разделе — папки и файлы идентичны.

## Запуск

1. **Xcode 15+**, iOS **13.4+**
2. Откройте `Tracker.xcodeproj`
3. Соберите и запустите на симуляторе или устройстве

### Заметки

* Интерфейс собирается в коде; `Main.storyboard` не используется.
* Флаг `hasCompletedOnboarding` в `UserDefaults` скрывает онбординг после первого завершения.

## Обработка ошибок

* Stores используют `NSFetchedResultsController`, ошибки выборки/сохранения логируются в консоль.
* Нельзя отмечать выполнение в будущем (проверка даты).

## Дорожная карта

* Развить вкладку **Статистика** (серии, итоги, графики)
* Юнит‑тесты с in‑memory Core Data
* Типобезопасные трансформеры для transformable полей
* Синхронизация через iCloud/CloudKit (опционально)
* Accessibility и локализация (EN/RU)

## Лицензия

Добавьте LICENSE (например, MIT) при публикации.
