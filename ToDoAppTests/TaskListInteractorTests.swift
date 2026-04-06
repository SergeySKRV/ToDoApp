//
//  TaskListInteractorTests.swift
//  ToDoAppTests
//
//  Created by Сергей Скориков on 06.04.2026.
//

import XCTest
@testable import ToDoApp

final class TaskListInteractorTests: XCTestCase {

    private var repository: TodoRepositoryMock!
    private var firstLaunchLoader: FirstLaunchLoaderMock!
    private var output: TaskListInteractorOutputMock!
    private var sut: TaskListInteractor!

    override func setUp() {
        super.setUp()
        repository = TodoRepositoryMock()
        firstLaunchLoader = FirstLaunchLoaderMock()
        output = TaskListInteractorOutputMock()
        sut = TaskListInteractor(repository: repository, firstLaunchLoader: firstLaunchLoader)
        sut.output = output
    }

    override func tearDown() {
        sut = nil
        output = nil
        firstLaunchLoader = nil
        repository = nil
        super.tearDown()
    }

    func test_preloadTodosIfNeeded_whenLoaderSucceeds_loadsTodos() {
        let todos = [makeTodo(title: "Task 1")]
        firstLaunchLoader.preloadResult = .success(())
        repository.fetchAllResults = [.success(todos)]

        let exp = expectation(description: "preload success then load todos")

        output.didLoadTodosHandler = { loadedTodos in
            XCTAssertEqual(loadedTodos, todos)
            exp.fulfill()
        }

        sut.preloadTodosIfNeeded()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(firstLaunchLoader.preloadIfNeededCallCount, 1)
        XCTAssertEqual(repository.fetchAllCallCount, 1)
        XCTAssertEqual(output.didFailCallCount, 0)
    }

    func test_preloadTodosIfNeeded_whenLoaderFails_sendsErrorToOutput() {
        let error = NSError(domain: "test.preload", code: 1)
        firstLaunchLoader.preloadResult = .failure(error)

        let exp = expectation(description: "preload failure")

        output.didFailHandler = { receivedError in
            let nsError = receivedError as NSError
            XCTAssertEqual(nsError.domain, "test.preload")
            XCTAssertEqual(nsError.code, 1)
            exp.fulfill()
        }

        sut.preloadTodosIfNeeded()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(firstLaunchLoader.preloadIfNeededCallCount, 1)
        XCTAssertEqual(repository.fetchAllCallCount, 0)
        XCTAssertEqual(output.didFailCallCount, 1)
    }

    func test_loadTodos_whenRepositorySucceeds_sendsTodosToOutput() {
        let todos = [makeTodo(title: "Task 1"), makeTodo(title: "Task 2")]
        repository.fetchAllResults = [.success(todos)]

        let exp = expectation(description: "load todos success")

        output.didLoadTodosHandler = { loadedTodos in
            XCTAssertEqual(loadedTodos, todos)
            exp.fulfill()
        }

        sut.loadTodos()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.fetchAllCallCount, 1)
        XCTAssertEqual(output.didFailCallCount, 0)
    }

    func test_loadTodos_whenRepositoryFails_sendsErrorToOutput() {
        let error = NSError(domain: "test.load", code: 2)
        repository.fetchAllResults = [.failure(error)]

        let exp = expectation(description: "load todos failure")

        output.didFailHandler = { receivedError in
            let nsError = receivedError as NSError
            XCTAssertEqual(nsError.domain, "test.load")
            XCTAssertEqual(nsError.code, 2)
            exp.fulfill()
        }

        sut.loadTodos()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.fetchAllCallCount, 1)
        XCTAssertEqual(output.didFailCallCount, 1)
    }

    func test_search_whenRepositorySucceeds_sendsTodosToOutput() {
        let todos = [makeTodo(title: "Milk")]
        repository.searchResult = .success(todos)

        let exp = expectation(description: "search success")

        output.didLoadTodosHandler = { loadedTodos in
            XCTAssertEqual(loadedTodos, todos)
            exp.fulfill()
        }

        sut.search(query: "milk")

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.searchQueries, ["milk"])
        XCTAssertEqual(output.didFailCallCount, 0)
    }

    func test_search_whenRepositoryFails_sendsErrorToOutput() {
        let error = NSError(domain: "test.search", code: 3)
        repository.searchResult = .failure(error)

        let exp = expectation(description: "search failure")

        output.didFailHandler = { receivedError in
            let nsError = receivedError as NSError
            XCTAssertEqual(nsError.domain, "test.search")
            XCTAssertEqual(nsError.code, 3)
            exp.fulfill()
        }

        sut.search(query: "milk")

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.searchQueries, ["milk"])
        XCTAssertEqual(output.didFailCallCount, 1)
    }

    func test_deleteTodo_whenRepositorySucceeds_reloadsTodos() {
        let todoID = UUID()
        repository.deleteResult = .success(())
        repository.fetchAllResults = [.success([makeTodo(title: "Reloaded")])]

        let exp = expectation(description: "delete success then reload")

        output.didLoadTodosHandler = { _ in
            exp.fulfill()
        }

        sut.deleteTodo(id: todoID)

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.deletedIDs, [todoID])
        XCTAssertEqual(repository.fetchAllCallCount, 1)
        XCTAssertEqual(output.didFailCallCount, 0)
    }

    func test_deleteTodo_whenRepositoryFails_sendsErrorToOutput() {
        let error = NSError(domain: "test.delete", code: 4)
        repository.deleteResult = .failure(error)

        let exp = expectation(description: "delete failure")

        output.didFailHandler = { receivedError in
            let nsError = receivedError as NSError
            XCTAssertEqual(nsError.domain, "test.delete")
            XCTAssertEqual(nsError.code, 4)
            exp.fulfill()
        }

        sut.deleteTodo(id: UUID())

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(output.didFailCallCount, 1)
    }

    func test_toggleTodo_whenTodoExists_updatesToggledTodoAndReloads() {
        let todo = makeTodo(title: "Task", isCompleted: false)

        let reloadedTodo = TodoModel(
            id: todo.id,
            remoteID: todo.remoteID,
            title: todo.title,
            taskDescription: todo.taskDescription,
            createdAt: todo.createdAt,
            updatedAt: todo.updatedAt,
            isCompleted: true,
            userId: todo.userId,
            isImported: todo.isImported
        )

        repository.fetchAllResults = [
            .success([todo]),
            .success([reloadedTodo])
        ]
        repository.updateResult = .success(())

        let exp = expectation(description: "toggle success then reload")

        output.didLoadTodosHandler = { loadedTodos in
            if loadedTodos.first?.isCompleted == true {
                exp.fulfill()
            }
        }

        sut.toggleTodo(id: todo.id)

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.fetchAllCallCount, 2)
        XCTAssertEqual(repository.updateCallCount, 1)
        XCTAssertEqual(repository.updatedTodo?.id, todo.id)
        XCTAssertEqual(repository.updatedTodo?.isCompleted, true)
        XCTAssertEqual(output.didFailCallCount, 0)
    }

    func test_toggleTodo_whenFetchFails_sendsErrorToOutput() {
        let error = NSError(domain: "test.toggle.fetch", code: 5)
        repository.fetchAllResults = [.failure(error)]

        let exp = expectation(description: "toggle fetch failure")

        output.didFailHandler = { receivedError in
            let nsError = receivedError as NSError
            XCTAssertEqual(nsError.domain, "test.toggle.fetch")
            XCTAssertEqual(nsError.code, 5)
            exp.fulfill()
        }

        sut.toggleTodo(id: UUID())

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.updateCallCount, 0)
        XCTAssertEqual(output.didFailCallCount, 1)
    }

    func test_toggleTodo_whenTodoNotFound_sendsObjectNotFound() {
        repository.fetchAllResults = [.success([])]

        let exp = expectation(description: "toggle object not found")

        output.didFailHandler = { receivedError in
            guard case AppError.objectNotFound = receivedError else {
                XCTFail("Expected AppError.objectNotFound")
                return
            }
            exp.fulfill()
        }

        sut.toggleTodo(id: UUID())

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.updateCallCount, 0)
        XCTAssertEqual(output.didFailCallCount, 1)
    }

    func test_toggleTodo_whenUpdateFails_sendsErrorToOutput() {
        let todo = makeTodo(title: "Task", isCompleted: false)
        let error = NSError(domain: "test.toggle.update", code: 6)

        repository.fetchAllResults = [.success([todo])]
        repository.updateResult = .failure(error)

        let exp = expectation(description: "toggle update failure")

        output.didFailHandler = { receivedError in
            let nsError = receivedError as NSError
            XCTAssertEqual(nsError.domain, "test.toggle.update")
            XCTAssertEqual(nsError.code, 6)
            exp.fulfill()
        }

        sut.toggleTodo(id: todo.id)

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.fetchAllCallCount, 1)
        XCTAssertEqual(repository.updateCallCount, 1)
        XCTAssertEqual(output.didFailCallCount, 1)
    }

    private func makeTodo(title: String, isCompleted: Bool = false) -> TodoModel {
        let date = Date(timeIntervalSince1970: 1_700_000_000)

        return TodoModel(
            id: UUID(),
            remoteID: 10,
            title: title,
            taskDescription: "Description",
            createdAt: date,
            updatedAt: date,
            isCompleted: isCompleted,
            userId: 99,
            isImported: false
        )
    }
}

private final class FirstLaunchLoaderMock: FirstLaunchLoaderProtocol {
    var preloadResult: Result<Void, Error> = .success(())
    private(set) var preloadIfNeededCallCount = 0

    func preloadIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
        preloadIfNeededCallCount += 1
        completion(preloadResult)
    }
}

private final class TaskListInteractorOutputMock: TaskListInteractorOutput {
    private(set) var didFailCallCount = 0

    var didLoadTodosHandler: (([TodoModel]) -> Void)?
    var didFailHandler: ((Error) -> Void)?

    func didLoadTodos(_ todos: [TodoModel]) {
        didLoadTodosHandler?(todos)
    }

    func didFail(with error: Error) {
        didFailCallCount += 1
        didFailHandler?(error)
    }
}

private final class TodoRepositoryMock: TodoRepositoryProtocol {
    var fetchAllResults: [Result<[TodoModel], Error>] = []
    var searchResult: Result<[TodoModel], Error> = .success([])
    var createResult: Result<Void, Error> = .success(())
    var updateResult: Result<Void, Error> = .success(())
    var deleteResult: Result<Void, Error> = .success(())
    var toggleResult: Result<Void, Error> = .success(())
    var saveImportedResult: Result<Void, Error> = .success(())
    var isEmptyResult: Result<Bool, Error> = .success(true)

    private(set) var fetchAllCallCount = 0
    private(set) var searchQueries: [String] = []
    private(set) var createdTitles: [String] = []
    private(set) var createdDescriptions: [String?] = []
    private(set) var updateCallCount = 0
    private(set) var updatedTodo: TodoModel?
    private(set) var deletedIDs: [UUID] = []
    private(set) var toggledIDs: [UUID] = []
    private(set) var savedImportedTodos: [[TodoDTO]] = []
    private(set) var isEmptyCallCount = 0

    func fetchAll(completion: @escaping (Result<[TodoModel], Error>) -> Void) {
        fetchAllCallCount += 1
        if fetchAllResults.isEmpty {
            completion(.success([]))
        } else {
            completion(fetchAllResults.removeFirst())
        }
    }

    func search(query: String, completion: @escaping (Result<[TodoModel], Error>) -> Void) {
        searchQueries.append(query)
        completion(searchResult)
    }

    func create(title: String, description: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        createdTitles.append(title)
        createdDescriptions.append(description)
        completion(createResult)
    }

    func update(_ todo: TodoModel, completion: @escaping (Result<Void, Error>) -> Void) {
        updateCallCount += 1
        updatedTodo = todo
        completion(updateResult)
    }

    func delete(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        deletedIDs.append(id)
        completion(deleteResult)
    }

    func toggle(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        toggledIDs.append(id)
        completion(toggleResult)
    }

    func saveImported(_ todos: [TodoDTO], completion: @escaping (Result<Void, Error>) -> Void) {
        savedImportedTodos.append(todos)
        completion(saveImportedResult)
    }

    func isEmpty(completion: @escaping (Result<Bool, Error>) -> Void) {
        isEmptyCallCount += 1
        completion(isEmptyResult)
    }
}
