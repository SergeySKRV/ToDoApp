//
//  TaskDetailsInteractorProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 03.04.2026.
//

import Foundation

protocol TaskDetailsInteractorProtocol: AnyObject {
    func saveTask(title: String, description: String)
}
