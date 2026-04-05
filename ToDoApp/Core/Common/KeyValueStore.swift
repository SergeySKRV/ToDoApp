//
//  KeyValueStore.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import Foundation

protocol KeyValueStoreProtocol {
    func bool(forKey: String) -> Bool
    func set(_ value: Bool, forKey: String)
}

final class UserDefaultsStore: KeyValueStoreProtocol {
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func bool(forKey key: String) -> Bool {
        defaults.bool(forKey: key)
    }
    
    func set(_ value: Bool, forKey: String) {
        defaults.set(value, forKey: forKey)
    }
}
