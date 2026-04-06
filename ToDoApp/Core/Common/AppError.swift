//
//  AppError.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// App-specific error cases.
enum AppError: LocalizedError {

    // MARK: - Cases

    case invalidURL
    case noData
    case decodingFailed
    case objectNotFound
    case persistenceFailed(String)
    case networkFailed(String)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.errorInvalidURL
        case .noData:
            return L10n.errorNoData
        case .decodingFailed:
            return L10n.errorDecodingFailed
        case .objectNotFound:
            return L10n.errorObjectNotFound
        case .persistenceFailed(let message):
            return String(format: L10n.errorPersistenceFailedFormat, message)
        case .networkFailed(let message):
            return String(format: L10n.errorNetworkFailedFormat, message)
        }
    }
}
