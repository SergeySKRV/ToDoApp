//
//  TodoDTO.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Data transfer object that represents a todo item received from the API.
struct TodoDTO: Decodable {

    // MARK: - Properties

    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
