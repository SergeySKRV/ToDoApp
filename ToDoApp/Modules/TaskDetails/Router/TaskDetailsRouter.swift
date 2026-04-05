//
//  TaskDetailsRouter.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 04.04.2026.
//

import UIKit

final class TaskDetailsRouter: TaskDetailsRouterProtocol {
    weak var viewController: UIViewController?
    
    func close() {
        if let navigationController = viewController?.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            viewController?.dismiss(animated: true)
        }
    }
}
