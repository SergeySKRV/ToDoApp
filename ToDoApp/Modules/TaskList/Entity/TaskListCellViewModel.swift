//
//  TaskListCellViewModel.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// View model used to display a todo item in the task list cell.
struct TaskListCellViewModel: Equatable {

    // MARK: - Properties

    let id: UUID
    let title: String
    let description: String
    let createdAtText: String
    let statusText: String
    let isCompleted: Bool
}
