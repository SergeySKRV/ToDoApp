//
//  TaskListCellViewModel.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

struct TaskListCellViewModel: Equatable {
    let id: UUID
    let title: String
    let description: String
    let createdAtText: String
    let statusText: String
    let isCompleted: Bool
}
