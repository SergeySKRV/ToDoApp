//
//  TaskListRouterProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import UIKit

/// Describes navigation actions for the task list screen.
protocol TaskListRouterProtocol: AnyObject {

    // MARK: - Navigation

    func openCreate()
    func openEdit(todo: TodoModel)
}
