//
//  DateProvider.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Provides the current date.
protocol DateProviderProtocol {
    var now: Date { get }
}

/// Default implementation of DateProviderProtocol.
struct DefaultDateProvider: DateProviderProtocol {
    var now: Date {
        Date()
    }
}
