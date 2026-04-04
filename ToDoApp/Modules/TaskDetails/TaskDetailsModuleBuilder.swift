//
//  TaskDetailsModuleBuilder.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 04.04.2026.
//

import UIKit

enum TaskDetailsModuleBuilder {
    static func build(mode: TaskDetailsMode,
                      repository: TodoRepositoryProtocol) -> UIViewController {
        let view = TaskDetailsViewController()
        let interactor = TaskDetailsInteractor(repository: repository, mode: mode)
        let router = TaskDetailsRouter()
        let presenter = TaskDetailsPresenter(
            view: view,
            interactor: interactor,
            router: router,
            mode: mode
        )
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
        
        return view
    }
}
