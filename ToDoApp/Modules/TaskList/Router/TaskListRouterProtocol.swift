//
//  TaskListRouterProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import UIKit

protocol TaskListRouterProtocol: AnyObject {
    func openCreate()
    func openEdit(todo: TodoModel)
}
