//
//  TaskListPresenterProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapAdd()
    func didSelectItem(at index: Int)
    func didDeleteItem(at index: Int)
    func didSearch(text: String)
    func didToggleStatus(at index: Int)
}
