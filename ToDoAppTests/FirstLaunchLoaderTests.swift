//
//  FirstLaunchLoaderTests.swift
//  ToDoAppTests
//
//  Created by Сергей Скориков on 05.04.2026.
//

import XCTest
@testable import ToDoApp

final class FirstLaunchLoaderTests: XCTestCase {

    // MARK: - Properties

    private var repository: TodoRepositoryMock!
    private var apiService: TodoAPIServiceMock!
    private var store: KeyValueStoreMock!
    private var sut: FirstLaunchLoader!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        repository = TodoRepositoryMock()
        apiService = TodoAPIServiceMock()
        store = KeyValueStoreMock()
        sut = FirstLaunchLoader(
            repository: repository,
            apiService: apiService,
            store: store
        )
    }

    override func tearDown() {
        sut = nil
        store = nil
        apiService = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_preloadIfNeeded_whenAlreadyPreloaded_completesWithoutOtherWork() {
        store.boolResult = true

        let exp = expectation(description: "completion")

        sut.preloadIfNeeded { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(store.requestedKeys, ["hasPreloadedTodos"])
        XCTAssertEqual(repository.isEmptyCallCount, 0)
        XCTAssertEqual(apiService.fetchTodosCallCount, 0)
        XCTAssertEqual(repository.saveImportedCallCount, 0)
        XCTAssertTrue(store.setCalls.isEmpty)
    }

    func test_preloadIfNeeded_whenRepositoryNotEmpty_setsFlagAndCompletes() {
        store.boolResult = false
        repository.isEmptyResult = .success(false)

        let exp = expectation(description: "completion")

        sut.preloadIfNeeded { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.isEmptyCallCount, 1)
        XCTAssertEqual(apiService.fetchTodosCallCount, 0)
        XCTAssertEqual(repository.saveImportedCallCount, 0)

        XCTAssertEqual(store.setCalls.count, 1)
        XCTAssertEqual(store.setCalls.first?.value, true)
        XCTAssertEqual(store.setCalls.first?.key, "hasPreloadedTodos")
    }

    func test_preloadIfNeeded_whenRepositoryEmpty_fetchesAndSavesTodos_andSetsFlag() {
        store.boolResult = false
        repository.isEmptyResult = .success(true)

        let todos = [
            TodoDTO(id: 1, todo: "Buy milk", completed: false, userId: 10),
            TodoDTO(id: 2, todo: "Pay bills", completed: true, userId: 11)
        ]
        apiService.fetchTodosResult = .success(todos)
        repository.saveImportedResult = .success(())

        let exp = expectation(description: "completion")

        sut.preloadIfNeeded { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.isEmptyCallCount, 1)
        XCTAssertEqual(apiService.fetchTodosCallCount, 1)
        XCTAssertEqual(repository.saveImportedCallCount, 1)

        XCTAssertEqual(repository.savedImportedTodos.count, 2)

        XCTAssertEqual(repository.savedImportedTodos[0].id, 1)
        XCTAssertEqual(repository.savedImportedTodos[0].todo, "Buy milk")
        XCTAssertEqual(repository.savedImportedTodos[0].completed, false)
        XCTAssertEqual(repository.savedImportedTodos[0].userId, 10)

        XCTAssertEqual(repository.savedImportedTodos[1].id, 2)
        XCTAssertEqual(repository.savedImportedTodos[1].todo, "Pay bills")
        XCTAssertEqual(repository.savedImportedTodos[1].completed, true)
        XCTAssertEqual(repository.savedImportedTodos[1].userId, 11)

        XCTAssertEqual(store.setCalls.count, 1)
        XCTAssertEqual(store.setCalls.first?.value, true)
        XCTAssertEqual(store.setCalls.first?.key, "hasPreloadedTodos")
    }

    func test_preloadIfNeeded_whenIsEmptyFails_returnsError() {
        store.boolResult = false
        let error = NSError(domain: "test.isEmpty", code: 1)
        repository.isEmptyResult = .failure(error)

        let exp = expectation(description: "completion")
        var receivedError: NSError?

        sut.preloadIfNeeded { result in
            if case .failure(let error as NSError) = result {
                receivedError = error
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError?.domain, "test.isEmpty")
        XCTAssertEqual(receivedError?.code, 1)

        XCTAssertEqual(apiService.fetchTodosCallCount, 0)
        XCTAssertEqual(repository.saveImportedCallCount, 0)
        XCTAssertTrue(store.setCalls.isEmpty)
    }

    func test_preloadIfNeeded_whenFetchFails_returnsError_andDoesNotSetFlag() {
        store.boolResult = false
        repository.isEmptyResult = .success(true)

        let error = NSError(domain: "test.api", code: 2)
        apiService.fetchTodosResult = .failure(error)

        let exp = expectation(description: "completion")
        var receivedError: NSError?

        sut.preloadIfNeeded { result in
            if case .failure(let error as NSError) = result {
                receivedError = error
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.isEmptyCallCount, 1)
        XCTAssertEqual(apiService.fetchTodosCallCount, 1)
        XCTAssertEqual(repository.saveImportedCallCount, 0)

        XCTAssertEqual(receivedError?.domain, "test.api")
        XCTAssertEqual(receivedError?.code, 2)
        XCTAssertTrue(store.setCalls.isEmpty)
    }

    func test_preloadIfNeeded_whenSaveImportedFails_returnsError_andDoesNotSetFlag() {
        store.boolResult = false
        repository.isEmptyResult = .success(true)

        let todos = [
            TodoDTO(id: 1, todo: "Buy milk", completed: false, userId: 10)
        ]
        apiService.fetchTodosResult = .success(todos)

        let error = NSError(domain: "test.save", code: 3)
        repository.saveImportedResult = .failure(error)

        let exp = expectation(description: "completion")
        var receivedError: NSError?

        sut.preloadIfNeeded { result in
            if case .failure(let error as NSError) = result {
                receivedError = error
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(repository.isEmptyCallCount, 1)
        XCTAssertEqual(apiService.fetchTodosCallCount, 1)
        XCTAssertEqual(repository.saveImportedCallCount, 1)

        XCTAssertEqual(repository.savedImportedTodos.count, 1)
        XCTAssertEqual(repository.savedImportedTodos[0].id, 1)
        XCTAssertEqual(repository.savedImportedTodos[0].todo, "Buy milk")
        XCTAssertEqual(repository.savedImportedTodos[0].completed, false)
        XCTAssertEqual(repository.savedImportedTodos[0].userId, 10)

        XCTAssertEqual(receivedError?.domain, "test.save")
        XCTAssertEqual(receivedError?.code, 3)
        XCTAssertTrue(store.setCalls.isEmpty)
    }
}

// MARK: - TodoRepositoryMock

private final class TodoRepositoryMock: TodoRepositoryProtocol {

    var isEmptyResult: Result<Bool, Error> = .success(true)
    var saveImportedResult: Result<Void, Error> = .success(())

    private(set) var isEmptyCallCount = 0
    private(set) var saveImportedCallCount = 0
    private(set) var savedImportedTodos: [TodoDTO] = []

    func fetchAll(completion: @escaping (Result<[TodoModel], Error>) -> Void) {
        XCTFail("fetchAll should not be called")
    }

    func search(query: String, completion: @escaping (Result<[TodoModel], Error>) -> Void) {
        XCTFail("search should not be called")
    }

    func create(title: String, description: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        XCTFail("create should not be called")
    }

    func update(_ todo: TodoModel, completion: @escaping (Result<Void, Error>) -> Void) {
        XCTFail("update should not be called")
    }

    func delete(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        XCTFail("delete should not be called")
    }

    func toggle(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        XCTFail("toggle should not be called")
    }

    func saveImported(_ todos: [TodoDTO], completion: @escaping (Result<Void, Error>) -> Void) {
        saveImportedCallCount += 1
        savedImportedTodos = todos
        completion(saveImportedResult)
    }

    func isEmpty(completion: @escaping (Result<Bool, Error>) -> Void) {
        isEmptyCallCount += 1
        completion(isEmptyResult)
    }
}

// MARK: - TodoAPIServiceMock

private final class TodoAPIServiceMock: TodoAPIServiceProtocol {

    var fetchTodosResult: Result<[TodoDTO], Error> = .success([])

    private(set) var fetchTodosCallCount = 0

    func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
        fetchTodosCallCount += 1
        completion(fetchTodosResult)
    }
}

// MARK: - KeyValueStoreMock

private final class KeyValueStoreMock: KeyValueStoreProtocol {

    var boolResult = false

    private(set) var requestedKeys: [String] = []
    private(set) var setCalls: [(value: Bool, key: String)] = []

    func bool(forKey key: String) -> Bool {
        requestedKeys.append(key)
        return boolResult
    }

    func set(_ value: Bool, forKey key: String) {
        setCalls.append((value: value, key: key))
    }
}
