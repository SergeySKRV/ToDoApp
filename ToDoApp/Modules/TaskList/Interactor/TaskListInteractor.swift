//
//  TaskListInteractor.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Handles business logic for loading, searching, deleting, and updating todo items.
final class TaskListInteractor: TaskListInteractorProtocol {

    // MARK: - Properties

    weak var output: TaskListInteractorOutput?

    private let repository: TodoRepositoryProtocol
    private let firstLaunchLoader: FirstLaunchLoaderProtocol

    // MARK: - Init

    init(
        repository: TodoRepositoryProtocol,
        firstLaunchLoader: FirstLaunchLoaderProtocol
    ) {
        self.repository = repository
        self.firstLaunchLoader = firstLaunchLoader
    }

    // MARK: - TaskListInteractorProtocol

    func preloadTodosIfNeeded() {
        firstLaunchLoader.preloadIfNeeded { [weak self] result in
            switch result {
            case .success:
                self?.loadTodos()
            case .failure(let error):
                self?.output?.didFail(with: error)
            }
        }
    }

    func loadTodos() {
        repository.fetchAll { [weak self] result in
            switch result {
            case .success(let todos):
                self?.output?.didLoadTodos(todos)
            case .failure(let error):
                self?.output?.didFail(with: error)
            }
        }
    }

    func search(query: String) {
        repository.search(query: query) { [weak self] result in
            switch result {
            case .success(let todos):
                self?.output?.didLoadTodos(todos)
            case .failure(let error):
                self?.output?.didFail(with: error)
            }
        }
    }

    func deleteTodo(id: UUID) {
        repository.delete(id: id) { [weak self] result in
            switch result {
            case .success:
                self?.loadTodos()
            case .failure(let error):
                self?.output?.didFail(with: error)
            }
        }
    }

    func toggleTodo(id: UUID) {
        repository.fetchAll { [weak self] result in
            switch result {
            case .failure(let error):
                self?.output?.didFail(with: error)

            case .success(let todos):
                guard let current = todos.first(where: { $0.id == id }) else {
                    self?.output?.didFail(with: AppError.objectNotFound)
                    return
                }

                let updated = TodoModel(
                    id: current.id,
                    remoteID: current.remoteID,
                    title: current.title,
                    taskDescription: current.taskDescription,
                    createdAt: current.createdAt,
                    updatedAt: Date(),
                    isCompleted: !current.isCompleted,
                    userId: current.userId,
                    isImported: current.isImported
                )

                self?.repository.update(updated) { updateResult in
                    switch updateResult {
                    case .success:
                        self?.loadTodos()
                    case .failure(let error):
                        self?.output?.didFail(with: error)
                    }
                }
            }
        }
    }
}
