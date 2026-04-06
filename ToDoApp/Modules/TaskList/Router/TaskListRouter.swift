//
//  TaskListRouter.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import UIKit

/// Handles navigation from the task list screen.
final class TaskListRouter: TaskListRouterProtocol {

    // MARK: - Properties

    weak var viewController: UIViewController?

    // MARK: - TaskListRouterProtocol

    func openCreate() {
        let repository = CoreDataTodoRepository(stack: .shared)

        let taskDetailsVC = TaskDetailsModuleBuilder.build(
            mode: .create,
            repository: repository
        )

        viewController?.navigationController?.pushViewController(taskDetailsVC, animated: true)
    }

    func openEdit(todo: TodoModel) {
        let repository = CoreDataTodoRepository(stack: .shared)

        let taskDetailsVC = TaskDetailsModuleBuilder.build(
            mode: .edit(todo),
            repository: repository
        )

        viewController?.navigationController?.pushViewController(taskDetailsVC, animated: true)
    }
}
