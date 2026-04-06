//
//  TaskDetailsPresenter.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 04.04.2026.
//

import Foundation

final class TaskDetailsPresenter {

    // MARK: - Properties

    private weak var view: TaskDetailsViewProtocol?
    private let interactor: TaskDetailsInteractorProtocol
    private let router: TaskDetailsRouterProtocol
    private let mode: TaskDetailsMode

    private var initialTitle: String = ""
    private var initialDescription: String = ""

    // MARK: - Init

    init(
        view: TaskDetailsViewProtocol,
        interactor: TaskDetailsInteractorProtocol,
        router: TaskDetailsRouterProtocol,
        mode: TaskDetailsMode
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.mode = mode
    }
}

// MARK: - TaskDetailsPresenterProtocol

extension TaskDetailsPresenter: TaskDetailsPresenterProtocol {

    func viewDidLoad() {
        switch mode {
        case .create:
            initialTitle = ""
            initialDescription = ""

            view?.display(
                title: "",
                description: "",
                screenTitle: L10n.taskCreateTitle,
                dateText: nil
            )

        case .edit(let todo):
            initialTitle = todo.title
            initialDescription = todo.taskDescription

            view?.display(
                title: todo.title,
                description: todo.taskDescription,
                screenTitle: L10n.taskEditTitle,
                dateText: DateFormatter.todoDate.string(from: todo.createdAt)
            )
        }
    }

    func didTapSave(title: String, description: String, isCompleted: Bool) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .create:
            if trimmedTitle.isEmpty && normalizedDescription.isEmpty {
                router.close()
                return
            }

            guard trimmedTitle.isEmpty == false else {
                view?.showError(L10n.errorEnterTaskTitle)
                return
            }

            view?.showLoading(true)
            interactor.saveTask(title: trimmedTitle, description: description)

        case .edit:
            let initialTrimmedTitle = initialTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let initialNormalizedDescription = initialDescription.trimmingCharacters(in: .whitespacesAndNewlines)

            let hasChanges =
                trimmedTitle != initialTrimmedTitle ||
                normalizedDescription != initialNormalizedDescription

            if hasChanges == false {
                router.close()
                return
            }

            guard trimmedTitle.isEmpty == false else {
                view?.showError(L10n.errorEnterTaskTitle)
                return
            }

            view?.showLoading(true)
            interactor.saveTask(
                title: trimmedTitle,
                description: description
            )
        }
    }

    func didTapClose() {
        router.close()
    }
}

// MARK: - TaskDetailsInteractorOutputProtocol

extension TaskDetailsPresenter: TaskDetailsInteractorOutputProtocol {

    func didSaveTask() {
        view?.showLoading(false)
        router.close()
    }

    func didFailSavingTask(_ error: Error) {
        view?.showLoading(false)
        view?.showError(error.localizedDescription)
    }
}
