//
//  TaskListPresenterProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Describes user actions handled by the task list presenter.
protocol TaskListPresenterProtocol: AnyObject {

    // MARK: - Lifecycle

    func viewDidLoad()
    func viewWillAppear()

    // MARK: - Actions

    func didTapAdd()
    func didSelectItem(at index: Int)
    func didDeleteItem(at index: Int)
    func didToggleStatus(at index: Int)
    func didSearch(text: String)
}
