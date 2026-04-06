//
//  TaskDetailsInteractorTests.swift
//  ToDoAppTests
//
//  Created by Сергей Скориков on 05.04.2026.
//

import Foundation

import XCTest
@testable import ToDoApp

final class TaskDetailsInteractorTests: XCTestCase {

    private var repository: TodoRepositoryMock!
    private var presenter: TaskDetailsInteractorOutputMock!

    override func setUp() {
        super.setUp()
        repository = TodoRepositoryMock()
        presenter = TaskDetailsInteractorOutputMock()
    }

    override func tearDown() {
        presenter = nil
        repository = nil
        super.tearDown()
    }

    func test_saveTask_inCreateMode_callsRepositoryCreate() {
        let sut = TaskDetailsInteractor(repository: repository, mode: .create)
        sut.presenter = presenter

        repository.createResult = .success(())

        sut.saveTask(title: "New task", description: "Description")

        XCTAssertEqual(repository.createCallCount, 1)
        XCTAssertEqual(repository.createdTitle, "New task")
        XCTAssertEqual(repository.createdDescription, "Description")

        XCTAssertEqual(repository.updateCallCount, 0)
        XCTAssertEqual(presenter.didSaveTaskCallCount, 1)
        XCTAssertEqual(presenter.didFailSavingTaskCallCount, 0)
    }

    func test_saveTask_inCreateMode_whenRepositoryFails_notifiesPresenterAboutError() {
        let sut = TaskDetailsInteractor(repository: repository, mode: .create)
        sut.presenter = presenter

        let error = NSError(domain: "test.create", code: 1)
        repository.createResult = .failure(error)

        sut.saveTask(title: "New task", description: "Description")

        XCTAssertEqual(repository.createCallCount, 1)
        XCTAssertEqual(presenter.didSaveTaskCallCount, 0)
        XCTAssertEqual(presenter.didFailSavingTaskCallCount, 1)

        let receivedError = presenter.receivedError as NSError?
        XCTAssertEqual(receivedError?.domain, "test.create")
        XCTAssertEqual(receivedError?.code, 1)
    }

    func test_saveTask_inEditMode_callsRepositoryUpdateWithUpdatedModel() {
        let existingDate = Date(timeIntervalSince1970: 1_700_000_000)
        let todo = TodoModel(
            id: UUID(),
            remoteID: 77,
            title: "Old title",
            taskDescription: "Old description",
            createdAt: existingDate,
            updatedAt: existingDate,
            isCompleted: true,
            userId: 12,
            isImported: true
        )

        let sut = TaskDetailsInteractor(repository: repository, mode: .edit(todo))
        sut.presenter = presenter

        repository.updateResult = .success(())

        sut.saveTask(title: "New title", description: "New description")

        XCTAssertEqual(repository.createCallCount, 0)
        XCTAssertEqual(repository.updateCallCount, 1)

        XCTAssertEqual(repository.updatedTodo?.id, todo.id)
        XCTAssertEqual(repository.updatedTodo?.remoteID, 77)
        XCTAssertEqual(repository.updatedTodo?.title, "New title")
        XCTAssertEqual(repository.updatedTodo?.taskDescription, "New description")
        XCTAssertEqual(repository.updatedTodo?.createdAt, existingDate)
        XCTAssertEqual(repository.updatedTodo?.isCompleted, true)
        XCTAssertEqual(repository.updatedTodo?.userId, 12)
        XCTAssertEqual(repository.updatedTodo?.isImported, true)

        XCTAssertEqual(presenter.didSaveTaskCallCount, 1)
        XCTAssertEqual(presenter.didFailSavingTaskCallCount, 0)
    }

    func test_saveTask_inEditMode_whenRepositoryFails_notifiesPresenterAboutError() {
        let existingDate = Date(timeIntervalSince1970: 1_700_000_000)
        let todo = TodoModel(
            id: UUID(),
            remoteID: 1,
            title: "Old title",
            taskDescription: "Old description",
            createdAt: existingDate,
            updatedAt: existingDate,
            isCompleted: false,
            userId: 5,
            isImported: false
        )

        let sut = TaskDetailsInteractor(repository: repository, mode: .edit(todo))
        sut.presenter = presenter

        let error = NSError(domain: "test.update", code: 2)
        repository.updateResult = .failure(error)

        sut.saveTask(title: "Edited", description: "Edited description")

        XCTAssertEqual(repository.updateCallCount, 1)
        XCTAssertEqual(presenter.didSaveTaskCallCount, 0)
        XCTAssertEqual(presenter.didFailSavingTaskCallCount, 1)

        let receivedError = presenter.receivedError as NSError?
        XCTAssertEqual(receivedError?.domain, "test.update")
        XCTAssertEqual(receivedError?.code, 2)
    }
}

private final class TodoRepositoryMock: TodoRepositoryProtocol {
    var createResult: Result<Void, Error> = .success(())
    var updateResult: Result<Void, Error> = .success(())

    private(set) var createCallCount = 0
    private(set) var updateCallCount = 0

    private(set) var createdTitle: String?
    private(set) var createdDescription: String?
    private(set) var updatedTodo: TodoModel?

    func fetchAll(completion: @escaping (Result<[TodoModel], Error>) -> Void) {
        XCTFail("fetchAll should not be called")
    }

    func search(query: String, completion: @escaping (Result<[TodoModel], Error>) -> Void) {
        XCTFail("search should not be called")
    }

    func create(title: String, description: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        createCallCount += 1
        createdTitle = title
        createdDescription = description
        completion(createResult)
    }

    func update(_ todo: TodoModel, completion: @escaping (Result<Void, Error>) -> Void) {
        updateCallCount += 1
        updatedTodo = todo
        completion(updateResult)
    }

    func delete(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        XCTFail("delete should not be called")
    }

    func toggle(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        XCTFail("toggle should not be called")
    }

    func saveImported(_ todos: [TodoDTO], completion: @escaping (Result<Void, Error>) -> Void) {
        XCTFail("saveImported should not be called")
    }

    func isEmpty(completion: @escaping (Result<Bool, Error>) -> Void) {
        XCTFail("isEmpty should not be called")
    }
}

private final class TaskDetailsInteractorOutputMock: TaskDetailsInteractorOutputProtocol {
    private(set) var didSaveTaskCallCount = 0
    private(set) var didFailSavingTaskCallCount = 0
    private(set) var receivedError: Error?

    func didSaveTask() {
        didSaveTaskCallCount += 1
    }

    func didFailSavingTask(_ error: Error) {
        didFailSavingTaskCallCount += 1
        receivedError = error
    }
}
