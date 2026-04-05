//
//  FirstLaunchLoaderProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 06.04.2026.
//

import Foundation

protocol FirstLaunchLoaderProtocol {
    func preloadIfNeeded(completion: @escaping (Result<Void, Error>) -> Void)
}
