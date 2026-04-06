//
//  TaskDetailsPresenterTests.swift
//  ToDoAppTests
//
//  Created by Сергей Скориков on 05.04.2026.
//

import XCTest
@testable import ToDoApp

final class TaskDetailsPresenterTests: XCTestCase {

    private var view: TaskDetailsViewMock!
    private var interactor: TaskDetailsInteractorMock!
    private var router: TaskDetailsRouterMock!

    override func setUp() {
        super.setUp()
        view = TaskDetailsViewMock()
        interactor = TaskDetailsInteractorMock()
        router = TaskDetailsRouterMock()
    }

    override func tearDown() {
        view = nil
        interactor = nil
        router = nil
        super.tearDown()
    }

    func test_viewDidLoad_createMode_displaysEmptyFieldsAndCreateTitle() {
        let sut = makeSUT(mode: .create)

        sut.viewDidLoad()

        XCTAssertEqual(view.displayedTitle, "")
        XCTAssertEqual(view.displayedDescription, "")
        XCTAssertEqual(view.displayedScreenTitle, L10n.taskCreateTitle)
        XCTAssertNil(view.displayedDateText)
    }

    func test_viewDidLoad_editMode_displaysTodoData() {
        let todo = makeTodo(
            title: "Buy milk",
            description: "2 bottles",
            createdAt: makeDate(day: 5, month: 4, year: 2026)
        )
        let sut = makeSUT(mode: .edit(todo))

        sut.viewDidLoad()

        XCTAssertEqual(view.displayedTitle, "Buy milk")
        XCTAssertEqual(view.displayedDescription, "2 bottles")
        XCTAssertEqual(view.displayedScreenTitle, L10n.taskEditTitle)
        XCTAssertEqual(view.displayedDateText, DateFormatter.todoDate.string(from: todo.createdAt))
    }

    func test_didTapSave_createMode_withEmptyTitleAndDescription_closesScreen() {
        let sut = makeSUT(mode: .create)

        sut.didTapSave(title: "   ", description: "   ", isCompleted: false)

        XCTAssertEqual(router.closeCallCount, 1)
        XCTAssertFalse(view.showLoadingCalledWithTrue)
        XCTAssertFalse(interactor.saveTaskCalled)
    }

    func test_didTapSave_createMode_withEmptyTitleAndFilledDescription_showsValidationError() {
        let sut = makeSUT(mode: .create)

        sut.didTapSave(title: "   ", description: "Some description", isCompleted: false)

        XCTAssertEqual(view.shownErrorMessage, L10n.errorEnterTaskTitle)
        XCTAssertEqual(router.closeCallCount, 0)
        XCTAssertFalse(interactor.saveTaskCalled)
    }

    func test_didTapSave_createMode_withValidTitle_startsLoadingAndSavesTrimmedTitle() {
        let sut = makeSUT(mode: .create)

        sut.didTapSave(title: "  New task  ", description: "Description", isCompleted: false)

        XCTAssertTrue(view.showLoadingCalledWithTrue)
        XCTAssertTrue(interactor.saveTaskCalled)
        XCTAssertEqual(interactor.savedTitle, "New task")
        XCTAssertEqual(interactor.savedDescription, "Description")
    }

    func test_didTapSave_editMode_withoutChanges_closesScreen() {
        let todo = makeTodo(title: "Buy milk", description: "2 bottles")
        let sut = makeSUT(mode: .edit(todo))
        sut.viewDidLoad()

        sut.didTapSave(title: "Buy milk", description: "2 bottles", isCompleted: false)

        XCTAssertEqual(router.closeCallCount, 1)
        XCTAssertFalse(interactor.saveTaskCalled)
    }

    func test_didTapSave_editMode_withOnlyWhitespaceDifference_closesScreen() {
        let todo = makeTodo(title: "Buy milk", description: "2 bottles")
        let sut = makeSUT(mode: .edit(todo))
        sut.viewDidLoad()

        sut.didTapSave(title: "  Buy milk  ", description: "  2 bottles  ", isCompleted: false)

        XCTAssertEqual(router.closeCallCount, 1)
        XCTAssertFalse(interactor.saveTaskCalled)
    }

    func test_didTapSave_editMode_withChangedData_startsLoadingAndSavesTrimmedTitle() {
        let todo = makeTodo(title: "Buy milk", description: "2 bottles")
        let sut = makeSUT(mode: .edit(todo))
        sut.viewDidLoad()

        sut.didTapSave(title: "  Buy bread  ", description: "Fresh", isCompleted: false)

        XCTAssertTrue(view.showLoadingCalledWithTrue)
        XCTAssertTrue(interactor.saveTaskCalled)
        XCTAssertEqual(interactor.savedTitle, "Buy bread")
        XCTAssertEqual(interactor.savedDescription, "Fresh")
    }

    func test_didTapSave_editMode_withEmptyTitle_showsValidationError() {
        let todo = makeTodo(title: "Buy milk", description: "2 bottles")
        let sut = makeSUT(mode: .edit(todo))
        sut.viewDidLoad()

        sut.didTapSave(title: "   ", description: "Updated description", isCompleted: false)

        XCTAssertEqual(view.shownErrorMessage, L10n.errorEnterTaskTitle)
        XCTAssertFalse(interactor.saveTaskCalled)
        XCTAssertEqual(router.closeCallCount, 0)
    }

    func test_didTapClose_closesScreen() {
        let sut = makeSUT(mode: .create)

        sut.didTapClose()

        XCTAssertEqual(router.closeCallCount, 1)
    }

    func test_didSaveTask_stopsLoadingAndClosesScreen() {
        let sut = makeSUT(mode: .create)

        sut.didSaveTask()

        XCTAssertTrue(view.showLoadingCalledWithFalse)
        XCTAssertEqual(router.closeCallCount, 1)
    }

    func test_didFailSavingTask_stopsLoadingAndShowsError() {
        let sut = makeSUT(mode: .create)
        let error = NSError(domain: "test", code: 123, userInfo: [NSLocalizedDescriptionKey: "Save failed"])

        sut.didFailSavingTask(error)

        XCTAssertTrue(view.showLoadingCalledWithFalse)
        XCTAssertEqual(view.shownErrorMessage, "Save failed")
    }
}

private extension TaskDetailsPresenterTests {
    func makeSUT(mode: TaskDetailsMode) -> TaskDetailsPresenter {
        TaskDetailsPresenter(
            view: view,
            interactor: interactor,
            router: router,
            mode: mode
        )
    }

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

private final class TaskDetailsViewMock: TaskDetailsViewProtocol {
    private(set) var displayedTitle: String?
    private(set) var displayedDescription: String?
    private(set) var displayedScreenTitle: String?
    private(set) var displayedDateText: String?

    private(set) var shownErrorMessage: String?

    private(set) var showLoadingCalls: [Bool] = []

    var showLoadingCalledWithTrue: Bool {
        showLoadingCalls.contains(true)
    }

    var showLoadingCalledWithFalse: Bool {
        showLoadingCalls.contains(false)
    }

    func display(title: String, description: String, screenTitle: String, dateText: String?) {
        displayedTitle = title
        displayedDescription = description
        displayedScreenTitle = screenTitle
        displayedDateText = dateText
    }

    func showLoading(_ isLoading: Bool) {
        showLoadingCalls.append(isLoading)
    }

    func showError(_ message: String) {
        shownErrorMessage = message
    }
}

private final class TaskDetailsInteractorMock: TaskDetailsInteractorProtocol {
    private(set) var saveTaskCalled = false
    private(set) var savedTitle: String?
    private(set) var savedDescription: String?

    func saveTask(title: String, description: String) {
        saveTaskCalled = true
        savedTitle = title
        savedDescription = description
    }
}

private final class TaskDetailsRouterMock: TaskDetailsRouterProtocol {
    private(set) var closeCallCount = 0

    func close() {
        closeCallCount += 1
    }
}
