# ToDoApp

ToDoApp — тестовое iOS-приложение для ведения списка задач. Приложение позволяет просматривать, добавлять, редактировать, удалять и искать задачи, а также загружает начальные данные из `dummyjson` при первом запуске и сохраняет их локально с помощью `CoreData`.

## Возможности

- Отображение списка задач на главном экране
- Отображение названия, описания, даты создания и статуса выполнения задачи
- Добавление новой задачи
- Редактирование существующей задачи
- Удаление задачи
- Поиск по задачам
- Загрузка задач из `https://dummyjson.com/todos` при первом запуске
- Сохранение данных в `CoreData`
- Восстановление данных при повторном запуске приложения
- Поддержка локализации

## Технологии

- Swift
- UIKit
- CoreData
- URLSession
- XCTest
- VIPER

## Архитектура

Приложение построено с использованием архитектуры VIPER.

### Основные модули

- `TaskList` — экран списка задач
- `TaskDetails` — экран создания и редактирования задачи

### Структура модулей

Каждый модуль разделен на следующие компоненты:

- `View` — отображение интерфейса и обработка действий пользователя
- `Interactor` — бизнес-логика
- `Presenter` — подготовка данных для отображения
- `Entity` — модели данных
- `Router` — навигация между экранами

## Структура проекта

## Структура проекта

ToDoApp/
├── App/
│   ├── AppDelegate.swift
│   ├── Info.plist
│   └── SceneDelegate.swift
├── Core/
│   ├── Common/
│   │   ├── AppColors.swift
│   │   ├── AppError.swift
│   │   ├── DateFormatter+Extensions.swift
│   │   ├── DateProvider.swift
│   │   ├── KeyValueStore.swift
│   │   └── L10n.swift
│   └── Persistence/
│       ├── CoreDataStack.swift
│       └── ToDoApp.xcdatamodeld
├── Data/
│   ├── Repositories/
│   │   ├── CoreDataTodoRepository.swift
│   │   └── TodoRepositoryProtocol.swift
│   └── Services/
│       ├── FirstLaunchLoader.swift
│       ├── FirstLaunchLoaderProtocol.swift
│       ├── TodoAPIService.swift
│       └── TodoAPIServiceProtocol.swift
├── Modules/
│   ├── TaskDetails/
│   │   ├── TaskDetailsModuleBuilder.swift
│   │   ├── Entity/
│   │   │   └── TaskDetailsMode.swift
│   │   ├── Interactor/
│   │   │   ├── TaskDetailsInteractor.swift
│   │   │   ├── TaskDetailsInteractorOutputProtocol.swift
│   │   │   └── TaskDetailsInteractorProtocol.swift
│   │   ├── Presenter/
│   │   │   ├── TaskDetailsPresenter.swift
│   │   │   └── TaskDetailsPresenterProtocol.swift
│   │   ├── Router/
│   │   │   ├── TaskDetailsRouter.swift
│   │   │   └── TaskDetailsRouterProtocol.swift
│   │   └── View/
│   │       ├── TaskDetailsViewProtocol.swift
│   │       └── TaskDetailsViewController.swift
│   └── TaskList/
│       ├── TaskListModuleBuilder.swift
│       ├── Entity/
│       │   ├── TaskListCellViewModel.swift
│       │   ├── TodoDTO.swift
│       │   ├── TodoListResponseDTO.swift
│       │   └── TodoModel.swift
│       ├── Interactor/
│       │   ├── TaskListInteractor.swift
│       │   └── TaskListInteractorProtocol.swift
│       ├── Presenter/
│       │   ├── TaskListInteractorOutput.swift
│       │   ├── TaskListPresenter.swift
│       │   └── TaskListPresenterProtocol.swift
│       ├── Router/
│       │   ├── TaskListRouter.swift
│       │   └── TaskListRouterProtocol.swift
│       └── View/
│           ├── TaskListViewController.swift
│           ├── TaskListViewProtocol.swift
│           └── TodoCell.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── en.lproj/
│   │   ├── Localizable.strings
│   │   └── Localizable.stringsdict
│   └── ru.lproj/
│       ├── Localizable.strings
│       └── Localizable.stringsdict
└── ToDoAppTests/
    ├── CoreDataTodoRepositoryTests.swift
    ├── FirstLaunchLoaderTests.swift
    ├── TaskDetailsInteractorTests.swift
    ├── TaskDetailsPresenterTests.swift
    ├── TaskListInteractorTests.swift
    ├── TaskListPresenterTests.swift
    ├── TaskListRouterTests.swift
    └── TodoAPIServiceTests.swift

## Работа с данными

### API

Для загрузки задач из сети используется `TodoAPIService`, который получает данные из `https://dummyjson.com/todos`.

### Первый запуск

`FirstLaunchLoader` отвечает за первичную загрузку задач. При первом запуске приложение:
1. Проверяет, пусто ли локальное хранилище
2. Запрашивает задачи из API
3. Сохраняет полученные данные в `CoreData`
4. Устанавливает флаг завершенной первичной загрузки

### Локальное хранение

Для локального хранения используется `CoreData`. Все операции чтения, поиска, создания, обновления и удаления задач инкапсулированы в `CoreDataTodoRepository`.

## Многопоточность

- Сетевые запросы выполняются асинхронно через `URLSession`
- Операции с `CoreData` выполняются в фоне через `CoreDataStack.performBackgroundTask`
- Это позволяет не блокировать основной поток и сохранять отзывчивость интерфейса

## Тесты

В проекте добавлены unit-тесты для основных компонентов приложения:

- `CoreDataTodoRepositoryTests`
- `FirstLaunchLoaderTests`
- `TodoAPIServiceTests`
- `TaskListInteractorTests`
- `TaskListPresenterTests`
- `TaskListRouterTests`
- `TaskDetailsInteractorTests`
- `TaskDetailsPresenterTests`

Тесты покрывают:
- сохранение и загрузку задач
- поиск, удаление и обновление
- первичную загрузку данных
- обработку сетевых ответов и ошибок
- логику presenter/interactor
- навигацию router

## Локализация

Приложение поддерживает локализацию через:
- `en.lproj/Localizable.strings`
- `ru.lproj/Localizable.strings`

Также используется `Localizable.stringsdict` для корректного отображения plural forms.

## Запуск проекта

1. Открыть проект в Xcode
2. Выбрать target `ToDoApp`
3. Запустить приложение на симуляторе или устройстве
4. При первом запуске приложение загрузит задачи из API и сохранит их локально

## Требования

- iOS 15.0+
- Xcode 16.0+
- Swift 5.9+

## Примечание

Проект выполнен в рамках тестового задания и ориентирован на чистую модульную структуру, разделение ответственности между слоями и покрытие ключевой бизнес-логики unit-тестами.
