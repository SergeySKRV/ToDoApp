//
//  AppColors.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 03.04.2026.
//

import UIKit

/// App color palette.
enum AppColors {

    // MARK: - Backgrounds

    static let background = UIColor.black
    static let searchBackground = UIColor(white: 0.16, alpha: 1.0)
    static let bottomBarBackground = UIColor(white: 0.14, alpha: 1.0)

    static let focusedCardBackground = UIColor(
        red: 39.0 / 255.0,
        green: 39.0 / 255.0,
        blue: 41.0 / 255.0,
        alpha: 1.0
    )

    static let actionMenuBackground = UIColor(
        red: 0.75,
        green: 0.75,
        blue: 0.75,
        alpha: 1.0
    )

    // MARK: - Text

    static let primaryText = UIColor.white
    static let secondaryText = UIColor(white: 0.78, alpha: 1.0)
    static let tertiaryText = UIColor(white: 0.53, alpha: 1.0)

    // MARK: - Accent

    static let accent = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)

    // MARK: - Decoration

    static let divider = UIColor(white: 0.18, alpha: 1.0)
}
