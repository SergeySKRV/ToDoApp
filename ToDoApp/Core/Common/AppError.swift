//
//  AppError.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

enum AppError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed
    case objectNotFound
    case persistenceError(String)
    case networkFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data"
        case .decodingFailed:
            return "Failed to decode data"
        case .objectNotFound:
            return "Object not found"
        case .persistenceError(let message):
            return "Persistence error: \(message)"
        case .networkFailed(let message):
            return "Network error: \(message)"
        }
    }
}
