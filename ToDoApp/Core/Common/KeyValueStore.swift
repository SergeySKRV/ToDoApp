//
//  KeyValueStore.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

/// Abstraction for storing boolean values by key.
protocol KeyValueStoreProtocol {
    func bool(forKey: String) -> Bool
    func set(_ value: Bool, forKey: String)
}

/// UserDefaults-based implementation of KeyValueStoreProtocol.
final class UserDefaultsStore: KeyValueStoreProtocol {

    // MARK: - Properties

    private let defaults: UserDefaults

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - KeyValueStoreProtocol

    func bool(forKey key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func set(_ value: Bool, forKey: String) {
        defaults.set(value, forKey: forKey)
    }
}
