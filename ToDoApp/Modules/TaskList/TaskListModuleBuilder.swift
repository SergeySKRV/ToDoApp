//
//  TaskListModuleBuilder.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 04.04.2026.
//

import UIKit

/// Builds and wires the Task List module components together.
enum TaskListModuleBuilder {

    // MARK: - Build

    static func build() -> UIViewController {
        let view = TaskListViewController()
        let repository = CoreDataTodoRepository()
        let apiService = TodoAPIService()
        let store = UserDefaultsStore()

        let firstLaunchLoader = FirstLaunchLoader(
            repository: repository,
            apiService: apiService,
            store: store
        )

        let interactor = TaskListInteractor(
            repository: repository,
            firstLaunchLoader: firstLaunchLoader
        )

        let router = TaskListRouter()
        let presenter = TaskListPresenter()

        view.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter
        router.viewController = view

        return view
    }
}
