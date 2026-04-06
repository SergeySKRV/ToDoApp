//
//  DateFormatter+Extensions.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

extension DateFormatter {

    // MARK: - Formatters

    /// Formatter for todo creation dates.
    static let todoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
}
