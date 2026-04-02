//
//  TodoAPIServiceProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

protocol TodoAPIServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void)
}
