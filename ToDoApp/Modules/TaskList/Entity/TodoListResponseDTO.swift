//
//  TodoListResponseDTO.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Data transfer object that represents the todo list response from the API.
struct TodoListResponseDTO: Decodable {

    // MARK: - Properties

    let todos: [TodoDTO]
    let total: Int
    let skip: Int
    let limit: Int
}
