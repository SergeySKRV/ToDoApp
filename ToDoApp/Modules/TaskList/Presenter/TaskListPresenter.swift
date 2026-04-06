//
//  TaskListPresenter.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Prepares task list data for display and handles user actions from the task list screen.
final class TaskListPresenter: TaskListPresenterProtocol {

    // MARK: - Properties

    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorProtocol?
    var router: TaskListRouterProtocol?

    private var todos: [TodoModel] = []

    // MARK: - TaskListPresenterProtocol

    func viewDidLoad() {
        view?.showLoading(true)
        interactor?.preloadTodosIfNeeded()
    }

    func viewWillAppear() {
        view?.showLoading(true)
        interactor?.loadTodos()
    }

    func didTapAdd() {
        router?.openCreate()
    }

    func didSelectItem(at index: Int) {
        guard todos.indices.contains(index) else { return }
        router?.openEdit(todo: todos[index])
    }

    func didDeleteItem(at index: Int) {
        guard todos.indices.contains(index) else { return }
        interactor?.deleteTodo(id: todos[index].id)
    }

    func didSearch(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            interactor?.loadTodos()
        } else {
            interactor?.search(query: trimmed)
        }
    }

    func didToggleStatus(at index: Int) {
        guard todos.indices.contains(index) else { return }
        interactor?.toggleTodo(id: todos[index].id)
    }

    // MARK: - Private

    private func map(_ todos: [TodoModel]) -> [TaskListCellViewModel] {
        todos.map {
            TaskListCellViewModel(
                id: $0.id,
                title: $0.title,
                description: $0.taskDescription.isEmpty ? L10n.taskWithoutDescription : $0.taskDescription,
                createdAtText: DateFormatter.todoDate.string(from: $0.createdAt),
                statusText: $0.isCompleted ? L10n.taskCompleted : L10n.taskNotCompleted,
                isCompleted: $0.isCompleted
            )
        }
    }
}

// MARK: - TaskListInteractorOutput

extension TaskListPresenter: TaskListInteractorOutput {

    func didLoadTodos(_ todos: [TodoModel]) {
        self.todos = todos
        view?.showLoading(false)
        view?.showTodos(map(todos))
    }

    func didFail(with error: Error) {
        view?.showLoading(false)
        view?.showError(error.localizedDescription)
    }
}
