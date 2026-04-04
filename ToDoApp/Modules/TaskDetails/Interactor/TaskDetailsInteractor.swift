//
//  TaskDetailsInteractor.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 03.04.2026.
//

import Foundation

final class TaskDetailsInteractor: TaskDetailsInteractorProtocol {
    weak var presenter: TaskDetailsInteractorOutputProtocol?

    private let repository: TodoRepositoryProtocol
    private let mode: TaskDetailsMode

    init(repository: TodoRepositoryProtocol, mode: TaskDetailsMode) {
        self.repository = repository
        self.mode = mode
    }

    func saveTask(title: String, description: String) {
        switch mode {
        case .create:
            repository.create(title: title, description: description) { [weak self] result in
                switch result {
                case .success:
                    self?.presenter?.didSaveTask()
                case .failure(let error):
                    self?.presenter?.didFailSavingTask(error)
                }
            }

        case .edit(let todo):
            let updated = TodoModel(
                id: todo.id,
                remoteID: todo.remoteID,
                title: title,
                taskDescription: description,
                createdAt: todo.createdAt,
                updatedAt: Date(),
                isCompleted: todo.isCompleted,
                userId: todo.userId,
                isImported: todo.isImported
            )

            repository.update(updated) { [weak self] result in
                switch result {
                case .success:
                    self?.presenter?.didSaveTask()
                case .failure(let error):
                    self?.presenter?.didFailSavingTask(error)
                }
            }
        }
    }
}
