//
//  TaskListRouter.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import UIKit

final class TaskListRouter: TaskListRouterProtocol {
    weak var viewController: UIViewController?
    
    static func assemble() -> UIViewController {
        let view = TaskListViewController()
        let presenter = TaskListPresenter()
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
        
        view.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.output = presenter
        router.viewController = view
        
        return UINavigationController(rootViewController: view)
    }
    
    func openCreate() {
        let alert = UIAlertController(
            title: "Следующий шаг",
            message: "Экран создания задачи подключим на следующем этапе",
            preferredStyle: .alert
            )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController?.present(alert, animated: true)
    }
    
    func openEdit(todo: TodoModel) {
        let sheet = UIAlertController(title: todo.title, message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Редактировать", style: .default) { [weak self] _ in
            let alert = UIAlertController(title: "Следующий шаг", message: "Экран редактирования подключим следующим шагом", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.viewController?.present(alert, animated: true)
        })

        sheet.addAction(UIAlertAction(title: "Поделиться", style: .default) { [weak self] _ in
            let text = [todo.title, todo.taskDescription].filter { !$0.isEmpty }.joined(separator: "\n")
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            self?.viewController?.present(activityVC, animated: true)
        })

        sheet.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            let alert = UIAlertController(title: "Удаление", message: "Пока удаление доступно свайпом в списке", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.viewController?.present(alert, animated: true)
        })

        sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        if let popover = sheet.popoverPresentationController {
            popover.sourceView = viewController?.view
            popover.sourceRect = CGRect(x: viewController?.view.bounds.midX ?? 0,
                                        y: viewController?.view.bounds.midY ?? 0,
                                        width: 1,
                                        height: 1)
        }

        viewController?.present(sheet, animated: true)
    }
}
