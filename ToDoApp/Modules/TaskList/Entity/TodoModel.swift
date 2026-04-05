//
//  TodoModel.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

struct TodoModel: Equatable {
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
