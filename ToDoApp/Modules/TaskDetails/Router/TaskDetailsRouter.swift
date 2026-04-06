//
//  TaskDetailsRouter.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 04.04.2026.
//

import UIKit

final class TaskDetailsRouter: TaskDetailsRouterProtocol {

    // MARK: - Properties

    weak var viewController: UIViewController?

    // MARK: - TaskDetailsRouterProtocol

    func close() {
        if let navigationController = viewController?.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            viewController?.dismiss(animated: true)
        }
    }
}
