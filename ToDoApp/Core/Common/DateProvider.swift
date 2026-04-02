//
//  DateProvider.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

protocol DateProviderProtocol {
    var now: Date { get }
}

struct DefaultDateProvider: DateProviderProtocol {
    var now: Date {
        Date()
    }
}
