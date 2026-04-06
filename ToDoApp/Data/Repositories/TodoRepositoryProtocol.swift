//
//  TodoRepositoryProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Describes data operations for todo items.
protocol TodoRepositoryProtocol {

    // MARK: - Fetching

    func fetchAll(completion: @escaping (Result<[TodoModel], Error>) -> Void)
    func search(query: String, completion: @escaping (Result<[TodoModel], Error>) -> Void)
    func isEmpty(completion: @escaping (Result<Bool, Error>) -> Void)

    // MARK: - Mutating

    func create(title: String, description: String?, completion: @escaping (Result<Void, Error>) -> Void)
    func update(_ todo: TodoModel, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    func toggle(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    func saveImported(_ todos: [TodoDTO], completion: @escaping (Result<Void, Error>) -> Void)
}
