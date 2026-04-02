//
//  CoreDataTodoRepository.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import CoreData
import Foundation

final class CoreDataTodoRepository: TodoRepositoryProtocol {
    private let stack: CoreDataStack
    private let dateProvider: DateProviderProtocol
    
    init(stack: CoreDataStack = .shared,
         dateProvider: DateProviderProtocol = DefaultDateProvider()) {
        self.stack = stack
        self.dateProvider = dateProvider
    }
    
    func fetchAll(completion: @escaping (Result<[TodoModel], Error>) -> Void) {
        stack.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
                request.sortDescriptors = [
                    NSSortDescriptor(key: "createdAt", ascending: false)
                ]
                
                let items = try context.fetch(request)
                let models = items.map { self.mapToDomain($0) }
                
                DispatchQueue.main.async {
                    completion(.success(models))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceFailed(error.localizedDescription)))
                }
            }
        }
    }
    
    func search(query: String, completion: @escaping (Result<[TodoModel], Error>) -> Void) {
        stack.performBackgroundTask { context in
            do {
                let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
                request.sortDescriptors = [
                    NSSortDescriptor(key: "createdAt", ascending: false)
                ]
                
                if trimmedQuery.isEmpty == false {
                    request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                        NSPredicate(format: "title CONTAINS[cd] %@", trimmedQuery),
                        NSPredicate(format: "taskDescription CONTAINS[cd] %@", trimmedQuery)
                    ])
                }
                
                let items = try context.fetch(request)
                let models = items.map { self.mapToDomain($0) }
                
                DispatchQueue.main.async {
                    completion(.success(models))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceFailed(error.localizedDescription)))
                }
            }
        }
    }
    
    func create(title: String, description: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        stack.performBackgroundTask { context in
            do {
                let item = TodoItem(context: context)
                item.id = UUID()
                item.remoteID = 0
                item.title = title
                item.taskDescription = description ?? ""
                item.createdAt = self.dateProvider.now
                item.updatedAt = self.dateProvider.now
                item.isCompleted = false
                item.userId = 0
                item.isImported = false
                
                try context.save()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceFailed(error.localizedDescription)))
                }
            }
        }
    }
    
    func update(_ todo: TodoModel, completion: @escaping (Result<Void, Error>) -> Void) {
        stack.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %@", todo.id as CVarArg)
                
                guard let item = try context.fetch(request).first else {
                    DispatchQueue.main.async {
                        completion(.failure(AppError.objectNotFound))
                    }
                    return
                }
                
                item.title = todo.title
                item.taskDescription = todo.taskDescription
                item.isCompleted = todo.isCompleted
                item.updatedAt = self.dateProvider.now
                item.remoteID = Int64(todo.remoteID ?? 0)
                item.userId = Int64(todo.userId ?? 0)
                item.isImported = todo.isImported
                
                try context.save()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceFailed(error.localizedDescription)))
                }
            }
        }
    }
    
    func delete(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        stack.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                
                guard let item = try context.fetch(request).first else {
                    DispatchQueue.main.async {
                        completion(.failure(AppError.objectNotFound))
                    }
                    return
                }
                
                context.delete(item)
                try context.save()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceFailed(error.localizedDescription)))
                }
            }
        }
    }
    
    func saveImported(_ todos: [TodoDTO], completion: @escaping (Result<Void, Error>) -> Void) {
        stack.performBackgroundTask { context in
            do {
                for dto in todos {
                    let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
                    request.fetchLimit = 1
                    request.predicate = NSPredicate(format: "remoteID == %11d", dto.id)
                    
                    let existingItem = try context.fetch(request).first
                    if let existingItem {
                        existingItem.title = dto.todo
                        existingItem.isCompleted = dto.completed
                        existingItem.userId = Int64(dto.userId)
                        existingItem.updatedAt = self.dateProvider.now
                    } else {
                        let item = TodoItem(context: context)
                        item.id = UUID()
                        item.remoteID = Int64(dto.id)
                        item.title = dto.todo
                        item.taskDescription = ""
                        item.createdAt = self.dateProvider.now
                        item.updatedAt = self.dateProvider.now
                        item.isCompleted = dto.completed
                        item.userId = Int64(dto.userId)
                        item.isImported = true
                    }
                }
                if context.hasChanges {
                    try context.save()
                }
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceFailed(error.localizedDescription)))
                }
            }
        }
    }
    
    func isEmpty(completion: @escaping (Result<Bool, Error>) -> Void) {
        stack.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
                let count = try context.count(for: request)
                
                DispatchQueue.main.async {
                    completion(.success(count == 0))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(AppError.persistenceFailed(error.localizedDescription)))
                }
            }
        }
    }
}


private extension CoreDataTodoRepository {
    func mapToDomain(_ item: TodoItem) -> TodoModel {
        TodoModel(
            id: item.id ?? UUID(),
            remoteID: item.remoteID == 0 ? nil : Int(item.remoteID),
            title: item.title ?? "",
            taskDescription: item.taskDescription ?? "",
            createdAt: item.createdAt ?? dateProvider.now,
            updatedAt: item.updatedAt ?? dateProvider.now,
            isCompleted: item.isCompleted,
            userId: item.userId == 0 ? nil : Int(item.userId),
            isImported: item.isImported
            )
    }
}
