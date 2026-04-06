//
//  FirstLaunchLoaderProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 06.04.2026.
//

import Foundation

/// Describes a service that preloads initial todo data on first launch.
protocol FirstLaunchLoaderProtocol {
    func preloadIfNeeded(completion: @escaping (Result<Void, Error>) -> Void)
}
