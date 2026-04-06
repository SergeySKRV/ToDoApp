//
//  TodoModel.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Domain model that represents a todo item inside the app.
struct TodoModel: Equatable {

    // MARK: - Properties

    let id: UUID
    let remoteID: Int?
    let title: String
    let taskDescription: String
    let createdAt: Date
    let updatedAt: Date
    let isCompleted: Bool
    let userId: Int?
    let isImported: Bool
}
