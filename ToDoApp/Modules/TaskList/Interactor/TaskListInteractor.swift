//
//  TaskListInteractor.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

final class TaskListInteractor: TaskListInteractorProtocol {
    weak var output: TaskListInteractorOutput?

    private let repository: TodoRepositoryProtocol
    private let firstLaunchLoader: FirstLaunchLoader

    init(repository: TodoRepositoryProtocol, firstLaunchLoader: FirstLaunchLoader) {
        self.repository = repository
        self.firstLaunchLoader = firstLaunchLoader
    }

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
        repository.toggle(id: id) { [weak self] result in
            switch result {
            case .success:
                self?.loadTodos()
            case .failure(let error):
                self?.output?.didFail(with: error)
            }
        }
    }
}
