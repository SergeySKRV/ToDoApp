//
//  CoreDataTodoRepositoryTests.swift
//  ToDoAppTests
//
//  Created by Сергей Скориков on 06.04.2026.
//

import Foundation

import XCTest
@testable import ToDoApp

final class CoreDataTodoRepositoryTests: XCTestCase {

    private var stack: CoreDataStack!
    private var dateProvider: DateProviderMock!
    private var repository: CoreDataTodoRepository!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(inMemory: true)
        dateProvider = DateProviderMock()
        dateProvider.now = Date(timeIntervalSince1970: 1_700_000_000)
        repository = CoreDataTodoRepository(stack: stack, dateProvider: dateProvider)
    }

    override func tearDown() {
        repository = nil
        dateProvider = nil
        stack = nil
        super.tearDown()
    }

    func test_isEmpty_returnsTrue_forFreshStore() {
        let exp = expectation(description: "isEmpty")
        var resultValue: Bool?

        repository.isEmpty { result in
            if case .success(let isEmpty) = result {
                resultValue = isEmpty
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(resultValue, true)
    }

    func test_create_thenFetchAll_returnsCreatedTodo() {
        let createExp = expectation(description: "create")

        repository.create(title: "Buy milk", description: "2 liters") { result in
            if case .failure(let error) = result {
                XCTFail("Expected success, got error: \(error)")
            }
            createExp.fulfill()
        }

        wait(for: [createExp], timeout: 1.0)

        let fetchExp = expectation(description: "fetch")
        var todos: [TodoModel] = []

        repository.fetchAll { result in
            switch result {
            case .success(let models):
                todos = models
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
            fetchExp.fulfill()
        }

        wait(for: [fetchExp], timeout: 1.0)

        XCTAssertEqual(todos.count, 1)
        XCTAssertEqual(todos.first?.title, "Buy milk")
        XCTAssertEqual(todos.first?.taskDescription, "2 liters")
        XCTAssertEqual(todos.first?.isCompleted, false)
        XCTAssertEqual(todos.first?.isImported, false)
        XCTAssertEqual(todos.first?.remoteID, nil)
        XCTAssertEqual(todos.first?.userId, nil)
        XCTAssertEqual(todos.first?.createdAt, dateProvider.now)
        XCTAssertEqual(todos.first?.updatedAt, dateProvider.now)
    }

    func test_create_withNilDescription_savesEmptyDescription() {
        let createExp = expectation(description: "create nil description")

        repository.create(title: "Task", description: nil) { _ in
            createExp.fulfill()
        }

        wait(for: [createExp], timeout: 1.0)

        let fetchExp = expectation(description: "fetch")
        var todos: [TodoModel] = []

        repository.fetchAll { result in
            if case .success(let models) = result {
                todos = models
            }
            fetchExp.fulfill()
        }

        wait(for: [fetchExp], timeout: 1.0)

        XCTAssertEqual(todos.count, 1)
        XCTAssertEqual(todos.first?.taskDescription, "")
    }

    func test_fetchAll_returnsItemsSortedByCreatedAtDescending() {
        dateProvider.now = Date(timeIntervalSince1970: 100)
        let exp1 = expectation(description: "create 1")
        repository.create(title: "Old", description: nil) { _ in exp1.fulfill() }
        wait(for: [exp1], timeout: 1.0)

        dateProvider.now = Date(timeIntervalSince1970: 200)
        let exp2 = expectation(description: "create 2")
        repository.create(title: "New", description: nil) { _ in exp2.fulfill() }
        wait(for: [exp2], timeout: 1.0)

        let fetchExp = expectation(description: "fetch sorted")
        var todos: [TodoModel] = []

        repository.fetchAll { result in
            if case .success(let models) = result {
                todos = models
            }
            fetchExp.fulfill()
        }

        wait(for: [fetchExp], timeout: 1.0)

        XCTAssertEqual(todos.map(\.title), ["New", "Old"])
    }

    func test_search_findsByTitleAndDescription_caseInsensitive() {
        let exp1 = expectation(description: "create 1")
        repository.create(title: "Buy milk", description: "From store") { _ in exp1.fulfill() }
        wait(for: [exp1], timeout: 1.0)

        let exp2 = expectation(description: "create 2")
        repository.create(title: "Walk", description: "Take Milk home") { _ in exp2.fulfill() }
        wait(for: [exp2], timeout: 1.0)

        let searchExp = expectation(description: "search")
        var todos: [TodoModel] = []

        repository.search(query: "milk") { result in
            if case .success(let models) = result {
                todos = models
            }
            searchExp.fulfill()
        }

        wait(for: [searchExp], timeout: 1.0)

        XCTAssertEqual(todos.count, 2)
    }

    func test_search_withEmptyTrimmedQuery_returnsAll() {
        let exp1 = expectation(description: "create 1")
        repository.create(title: "One", description: nil) { _ in exp1.fulfill() }
        wait(for: [exp1], timeout: 1.0)

        let exp2 = expectation(description: "create 2")
        repository.create(title: "Two", description: nil) { _ in exp2.fulfill() }
        wait(for: [exp2], timeout: 1.0)

        let searchExp = expectation(description: "search all")
        var todos: [TodoModel] = []

        repository.search(query: "   ") { result in
            if case .success(let models) = result {
                todos = models
            }
            searchExp.fulfill()
        }

        wait(for: [searchExp], timeout: 1.0)

        XCTAssertEqual(todos.count, 2)
    }

    func test_update_updatesExistingTodoAndKeepsCreatedAt() {
        let createExp = expectation(description: "create")
        repository.create(title: "Initial", description: "Desc") { _ in createExp.fulfill() }
        wait(for: [createExp], timeout: 1.0)

        let fetchExp = expectation(description: "fetch")
        var createdTodo: TodoModel!
        repository.fetchAll { result in
            if case .success(let models) = result {
                createdTodo = models.first
            }
            fetchExp.fulfill()
        }
        wait(for: [fetchExp], timeout: 1.0)

        let oldCreatedAt = createdTodo.createdAt

        dateProvider.now = Date(timeIntervalSince1970: 1_800_000_000)

        let updated = TodoModel(
            id: createdTodo.id,
            remoteID: 55,
            title: "Updated",
            taskDescription: "Updated description",
            createdAt: createdTodo.createdAt,
            updatedAt: createdTodo.updatedAt,
            isCompleted: true,
            userId: 77,
            isImported: true
        )

        let updateExp = expectation(description: "update")
        repository.update(updated) { result in
            if case .failure(let error) = result {
                XCTFail("Expected success, got error: \(error)")
            }
            updateExp.fulfill()
        }

        wait(for: [updateExp], timeout: 1.0)

        let refetchExp = expectation(description: "refetch")
        var fetched: TodoModel!
        repository.fetchAll { result in
            if case .success(let models) = result {
                fetched = models.first
            }
            refetchExp.fulfill()
        }
        wait(for: [refetchExp], timeout: 1.0)

        XCTAssertEqual(fetched.title, "Updated")
        XCTAssertEqual(fetched.taskDescription, "Updated description")
        XCTAssertEqual(fetched.isCompleted, true)
        XCTAssertEqual(fetched.remoteID, 55)
        XCTAssertEqual(fetched.userId, 77)
        XCTAssertEqual(fetched.isImported, true)
        XCTAssertEqual(fetched.createdAt, oldCreatedAt)
        XCTAssertEqual(fetched.updatedAt, dateProvider.now)
    }

    func test_update_withUnknownID_returnsObjectNotFound() {
        let todo = TodoModel(
            id: UUID(),
            remoteID: nil,
            title: "Missing",
            taskDescription: "Missing",
            createdAt: dateProvider.now,
            updatedAt: dateProvider.now,
            isCompleted: false,
            userId: nil,
            isImported: false
        )

        let exp = expectation(description: "update missing")

        repository.update(todo) { result in
            guard case .failure(let error) = result,
                  case AppError.objectNotFound = error else {
                XCTFail("Expected AppError.objectNotFound")
                return
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_delete_removesTodo() {
        let createExp = expectation(description: "create")
        repository.create(title: "Delete me", description: nil) { _ in createExp.fulfill() }
        wait(for: [createExp], timeout: 1.0)

        let fetchExp = expectation(description: "fetch")
        var todo: TodoModel!
        repository.fetchAll { result in
            if case .success(let models) = result {
                todo = models.first
            }
            fetchExp.fulfill()
        }
        wait(for: [fetchExp], timeout: 1.0)

        let deleteExp = expectation(description: "delete")
        repository.delete(id: todo.id) { result in
            if case .failure(let error) = result {
                XCTFail("Expected success, got error: \(error)")
            }
            deleteExp.fulfill()
        }
        wait(for: [deleteExp], timeout: 1.0)

        let refetchExp = expectation(description: "refetch")
        var todos: [TodoModel] = []
        repository.fetchAll { result in
            if case .success(let models) = result {
                todos = models
            }
            refetchExp.fulfill()
        }
        wait(for: [refetchExp], timeout: 1.0)

        XCTAssertTrue(todos.isEmpty)
    }

    func test_delete_withUnknownID_returnsObjectNotFound() {
        let exp = expectation(description: "delete missing")

        repository.delete(id: UUID()) { result in
            guard case .failure(let error) = result,
                  case AppError.objectNotFound = error else {
                XCTFail("Expected AppError.objectNotFound")
                return
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_saveImported_createsImportedTodos() {
        let todos = [
            TodoDTO(id: 1, todo: "Imported 1", completed: false, userId: 10),
            TodoDTO(id: 2, todo: "Imported 2", completed: true, userId: 20)
        ]

        let saveExp = expectation(description: "save imported")
        repository.saveImported(todos) { result in
            if case .failure(let error) = result {
                XCTFail("Expected success, got error: \(error)")
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)

        let fetchExp = expectation(description: "fetch imported")
        var models: [TodoModel] = []
        repository.fetchAll { result in
            if case .success(let todos) = result {
                models = todos
            }
            fetchExp.fulfill()
        }
        wait(for: [fetchExp], timeout: 1.0)

        XCTAssertEqual(models.count, 2)
        XCTAssertTrue(models.allSatisfy(\.isImported))
        XCTAssertTrue(models.contains(where: { $0.remoteID == 1 && $0.title == "Imported 1" && $0.userId == 10 }))
        XCTAssertTrue(models.contains(where: { $0.remoteID == 2 && $0.title == "Imported 2" && $0.userId == 20 && $0.isCompleted == true }))
    }

    func test_saveImported_updatesExistingRemoteTodoInsteadOfDuplicating() {
        let initial = [TodoDTO(id: 1, todo: "Initial", completed: false, userId: 10)]
        let save1 = expectation(description: "save 1")
        repository.saveImported(initial) { _ in save1.fulfill() }
        wait(for: [save1], timeout: 1.0)

        dateProvider.now = Date(timeIntervalSince1970: 1_900_000_000)

        let updated = [TodoDTO(id: 1, todo: "Updated imported", completed: true, userId: 99)]
        let save2 = expectation(description: "save 2")
        repository.saveImported(updated) { _ in save2.fulfill() }
        wait(for: [save2], timeout: 1.0)

        let fetchExp = expectation(description: "fetch updated imported")
        var models: [TodoModel] = []
        repository.fetchAll { result in
            if case .success(let todos) = result {
                models = todos
            }
            fetchExp.fulfill()
        }
        wait(for: [fetchExp], timeout: 1.0)

        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models.first?.remoteID, 1)
        XCTAssertEqual(models.first?.title, "Updated imported")
        XCTAssertEqual(models.first?.isCompleted, true)
        XCTAssertEqual(models.first?.userId, 99)
        XCTAssertEqual(models.first?.updatedAt, dateProvider.now)
    }

    func test_isEmpty_returnsFalse_afterInsert() {
        let createExp = expectation(description: "create")
        repository.create(title: "Task", description: nil) { _ in createExp.fulfill() }
        wait(for: [createExp], timeout: 1.0)

        let emptyExp = expectation(description: "isEmpty false")
        var resultValue: Bool?

        repository.isEmpty { result in
            if case .success(let isEmpty) = result {
                resultValue = isEmpty
            }
            emptyExp.fulfill()
        }

        wait(for: [emptyExp], timeout: 1.0)

        XCTAssertEqual(resultValue, false)
    }
}

private final class DateProviderMock: DateProviderProtocol {
    var now: Date = Date()
}
