//
//  TaskDetailsInteractorProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 03.04.2026.
//

import Foundation

/// Describes business logic for creating or updating a task.
protocol TaskDetailsInteractorProtocol: AnyObject {
    func saveTask(title: String, description: String)
}
