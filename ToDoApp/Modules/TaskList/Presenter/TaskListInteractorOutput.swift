//
//  TaskListInteractorOutput.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

protocol TaskListInteractorOutput: AnyObject {
    func didLoadTodos(_ todos: [TodoModel])
    func didFail(with error: Error)
}
