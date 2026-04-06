//
//  TaskListInteractorProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Describes business logic actions for the task list screen.
protocol TaskListInteractorProtocol: AnyObject {

    // MARK: - Actions

    func preloadTodosIfNeeded()
    func loadTodos()
    func search(query: String)
    func deleteTodo(id: UUID)
    func toggleTodo(id: UUID)
}
