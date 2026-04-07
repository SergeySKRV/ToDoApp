//
//  TaskDetailsPresenterProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 03.04.2026.
//

import Foundation

protocol TaskDetailsPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapSave(title: String, description: String, isCompleted: Bool)
    func didTapClose()
}
