//
//  TaskDetailsViewProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 03.04.2026.
//

import Foundation

/// Describes UI updates for the task details screen.
protocol TaskDetailsViewProtocol: AnyObject {
    func display(
        title: String,
        description: String,
        screenTitle: String,
        dateText: String?
    )
    func showLoading(_ isLoading: Bool)
    func showError(_ message: String)
}
