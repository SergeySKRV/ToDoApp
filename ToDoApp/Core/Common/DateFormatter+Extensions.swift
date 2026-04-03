//
//  DateFormatter+Extensions.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

extension DateFormatter {
    static let todoDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "dd/MM/yy"
            return formatter
    }()
}
