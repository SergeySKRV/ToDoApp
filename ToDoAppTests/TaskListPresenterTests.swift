//
//  TaskListPresenterTests.swift
//  ToDoAppTests
//
//  Created by Сергей Скориков on 05.04.2026.
//

import XCTest
@testable import ToDoApp

final class TaskListPresenterTests: XCTestCase {

    // MARK: - Properties

    private var view: TaskListViewMock!
    private var interactor: TaskListInteractorMock!
    private var router: TaskListRouterMock!
    private var sut: TaskListPresenter!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        view = TaskListViewMock()
        interactor = TaskListInteractorMock()
        router = TaskListRouterMock()

        sut = TaskListPresenter()
        sut.view = view
        sut.interactor = interactor
        sut.router = router
    }

    override func tearDown() {
        sut = nil
        view = nil
        interactor = nil
        router = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad_showsLoading_andPreloadsTodos() {
        sut.viewDidLoad()

        XCTAssertEqual(view.showLoadingCalls, [true])
        XCTAssertEqual(interactor.preloadTodosIfNeededCallCount, 1)
    }

    func test_viewWillAppear_showsLoading_andLoadsTodos() {
        sut.viewWillAppear()

        XCTAssertEqual(view.showLoadingCalls, [true])
        XCTAssertEqual(interactor.loadTodosCallCount, 1)
    }

    func test_didTapAdd_opensCreateScreen() {
        sut.didTapAdd()

        XCTAssertEqual(router.openCreateCallCount, 1)
    }

    func test_didSelectItem_withValidIndex_opensEditScreen() {
        let todos = [
            makeTodo(title: "First", description: "Desc 1"),
            makeTodo(title: "Second", description: "Desc 2")
        ]
        sut.didLoadTodos(todos)

        sut.didSelectItem(at: 1)

        XCTAssertEqual(router.openEditCallCount, 1)
        XCTAssertEqual(router.openedTodo?.title, "Second")
    }

    func test_didSelectItem_withInvalidIndex_doesNothing() {
        let todos = [
            makeTodo(title: "First", description: "Desc 1")
        ]
        sut.didLoadTodos(todos)

        sut.didSelectItem(at: 5)

        XCTAssertEqual(router.openEditCallCount, 0)
        XCTAssertNil(router.openedTodo)
    }

    func test_didDeleteItem_withValidIndex_callsInteractorDelete() {
        let todo = makeTodo(title: "First", description: "Desc 1")
        sut.didLoadTodos([todo])

        sut.didDeleteItem(at: 0)

        XCTAssertEqual(interactor.deleteTodoCallCount, 1)
        XCTAssertEqual(interactor.deletedTodoID, todo.id)
    }

    func test_didDeleteItem_withInvalidIndex_doesNothing() {
        sut.didLoadTodos([])

        sut.didDeleteItem(at: 0)

        XCTAssertEqual(interactor.deleteTodoCallCount, 0)
        XCTAssertNil(interactor.deletedTodoID)
    }

    func test_didToggleStatus_withValidIndex_callsInteractorToggle() {
        let todo = makeTodo(title: "First", description: "Desc 1")
        sut.didLoadTodos([todo])

        sut.didToggleStatus(at: 0)

        XCTAssertEqual(interactor.toggleTodoCallCount, 1)
        XCTAssertEqual(interactor.toggledTodoID, todo.id)
    }

    func test_didToggleStatus_withInvalidIndex_doesNothing() {
        sut.didLoadTodos([])

        sut.didToggleStatus(at: 0)

        XCTAssertEqual(interactor.toggleTodoCallCount, 0)
        XCTAssertNil(interactor.toggledTodoID)
    }

    func test_didSearch_withEmptyTrimmedText_callsLoadTodos() {
        sut.didSearch(text: "   ")

        XCTAssertEqual(interactor.loadTodosCallCount, 1)
        XCTAssertEqual(interactor.searchCallCount, 0)
        XCTAssertNil(interactor.searchQuery)
    }

    func test_didSearch_withNonEmptyTrimmedText_callsSearch() {
        sut.didSearch(text: "  milk  ")

        XCTAssertEqual(interactor.searchCallCount, 1)
        XCTAssertEqual(interactor.searchQuery, "milk")
        XCTAssertEqual(interactor.loadTodosCallCount, 0)
    }

    func test_didLoadTodos_hidesLoading_andShowsMappedItems() {
        let date = makeDate(day: 5, month: 4, year: 2026)
        let todos = [
            makeTodo(
                title: "Buy milk",
                description: "",
                createdAt: date,
                isCompleted: false
            ),
            makeTodo(
                title: "Pay bills",
                description: "Before Monday",
                createdAt: date,
                isCompleted: true
            )
        ]

        sut.didLoadTodos(todos)

        XCTAssertEqual(view.showLoadingCalls.last, false)
        XCTAssertEqual(view.shownTodos.count, 2)

        XCTAssertEqual(view.shownTodos[0].title, "Buy milk")
        XCTAssertEqual(view.shownTodos[0].description, L10n.taskWithoutDescription)
        XCTAssertEqual(view.shownTodos[0].createdAtText, DateFormatter.todoDate.string(from: date))
        XCTAssertEqual(view.shownTodos[0].statusText, L10n.taskNotCompleted)
        XCTAssertEqual(view.shownTodos[0].isCompleted, false)

        XCTAssertEqual(view.shownTodos[1].title, "Pay bills")
        XCTAssertEqual(view.shownTodos[1].description, "Before Monday")
        XCTAssertEqual(view.shownTodos[1].createdAtText, DateFormatter.todoDate.string(from: date))
        XCTAssertEqual(view.shownTodos[1].statusText, L10n.taskCompleted)
        XCTAssertEqual(view.shownTodos[1].isCompleted, true)
    }

    func test_didFail_hidesLoading_andShowsError() {
        let error = NSError(
            domain: "test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]
        )

        sut.didFail(with: error)

        XCTAssertEqual(view.showLoadingCalls.last, false)
        XCTAssertEqual(view.shownErrorMessage, "Something went wrong")
    }
}

// MARK: - Helpers

private extension TaskListPresenterTests {

    func makeTodo(
        id: UUID = UUID(),
        remoteID: Int? = nil,
        title: String,
        description: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isCompleted: Bool = false,
        userId: Int? = nil,
        isImported: Bool = false
    ) -> TodoModel {
        TodoModel(
            id: id,
            remoteID: remoteID,
            title: title,
            taskDescription: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isCompleted: isCompleted,
            userId: userId,
            isImported: isImported
        )
    }

    func makeDate(day: Int, month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.calendar = Calendar(identifier: .gregorian)
        return components.date ?? Date()
    }
}

// MARK: - TaskListViewMock

private final class TaskListViewMock: TaskListViewProtocol {

    private(set) var showLoadingCalls: [Bool] = []
    private(set) var shownTodos: [TaskListCellViewModel] = []
    private(set) var shownErrorMessage: String?

    func showLoading(_ isLoading: Bool) {
        showLoadingCalls.append(isLoading)
    }

    func showTodos(_ items: [TaskListCellViewModel]) {
        shownTodos = items
    }

    func showError(_ message: String) {
        shownErrorMessage = message
    }
}

// MARK: - TaskListInteractorMock

private final class TaskListInteractorMock: TaskListInteractorProtocol {

    private(set) var preloadTodosIfNeededCallCount = 0
    private(set) var loadTodosCallCount = 0
    private(set) var searchCallCount = 0
    private(set) var deleteTodoCallCount = 0
    private(set) var toggleTodoCallCount = 0

    private(set) var searchQuery: String?
    private(set) var deletedTodoID: UUID?
    private(set) var toggledTodoID: UUID?

    func preloadTodosIfNeeded() {
        preloadTodosIfNeededCallCount += 1
    }

    func loadTodos() {
        loadTodosCallCount += 1
    }

    func search(query: String) {
        searchCallCount += 1
        searchQuery = query
    }

    func deleteTodo(id: UUID) {
        deleteTodoCallCount += 1
        deletedTodoID = id
    }

    func toggleTodo(id: UUID) {
        toggleTodoCallCount += 1
        toggledTodoID = id
    }
}

// MARK: - TaskListRouterMock

private final class TaskListRouterMock: TaskListRouterProtocol {

    private(set) var openCreateCallCount = 0
    private(set) var openEditCallCount = 0
    private(set) var openedTodo: TodoModel?

    func openCreate() {
        openCreateCallCount += 1
    }

    func openEdit(todo: TodoModel) {
        openEditCallCount += 1
        openedTodo = todo
    }
}
