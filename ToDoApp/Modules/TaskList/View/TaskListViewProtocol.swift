//
//  TaskListViewProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Describes UI updates for the task list screen.
protocol TaskListViewProtocol: AnyObject {

    // MARK: - Display

    func showLoading(_ isLoading: Bool)
    func showTodos(_ items: [TaskListCellViewModel])
    func showError(_ message: String)
}
