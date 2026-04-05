//
//  TodoAPIService.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

final class TodoAPIService: TodoAPIServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos?limit=0") else {
            completion(.failure(AppError.invalidURL))
            return
        }

        session.dataTask(with: url) { [decoder] data, response, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(AppError.networkFailed(error.localizedDescription)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(AppError.networkFailed(L10n.networkIncorrectResponse)))
                }
                return
            }

            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(AppError.noData))
                }
                return
            }

            Task { @MainActor in
                do {
                    let decoded = try decoder.decode(TodoListResponseDTO.self, from: data)
                    completion(.success(decoded.todos))
                } catch {
                    completion(.failure(AppError.decodingFailed))
                }
            }
        }.resume()
    }
}
