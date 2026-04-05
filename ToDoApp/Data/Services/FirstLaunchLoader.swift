//
//  FirstLaunchLoader.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

final class FirstLaunchLoader {
    private let repository: TodoRepositoryProtocol
    private let apiService: TodoAPIServiceProtocol
    private let store: KeyValueStoreProtocol
    
    private let preloadKey = "hasPreloadedTodos"
    
    init(repository: TodoRepositoryProtocol,
         apiService: TodoAPIServiceProtocol,
         store: KeyValueStoreProtocol) {
        self.repository = repository
        self.apiService = apiService
        self.store = store
    }
    
    func preloadIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
        if store.bool(forKey: preloadKey) {
            completion(.success(()))
            return
        }
        
        repository.isEmpty { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let isEmpty):
                if isEmpty == false {
                    self.store.set(true, forKey: self.preloadKey)
                    completion(.success(()))
                    return
                }
                
                self.apiService.fetchTodos { apiResult in
                    switch apiResult {
                    case .failure(let error):
                        completion(.failure(error))
                        
                    case .success(let todos):
                        self.repository.saveImported(todos) { saveResult in
                            switch saveResult {
                            case .failure(let error):
                                completion(.failure(error))
                                
                            case .success:
                                self.store.set(true, forKey: self.preloadKey)
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }
}
