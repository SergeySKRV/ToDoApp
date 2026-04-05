//
//  TaskListViewProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

protocol TaskListViewProtocol: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showTodos(_ items: [TaskListCellViewModel])
    func showError(_ message: String)
}
