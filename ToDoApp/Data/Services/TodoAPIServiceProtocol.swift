//
//  TodoAPIServiceProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Describes a service that loads todo items from a remote API.
protocol TodoAPIServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void)
}
