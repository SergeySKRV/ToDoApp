//
//  TaskListInteractorOutput.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Describes callbacks from the task list interactor.
protocol TaskListInteractorOutput: AnyObject {

    // MARK: - Output

    func didLoadTodos(_ todos: [TodoModel])
    func didFail(with error: Error)
}
