//
//  TaskDetailsInteractorOutputProtocol.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 03.04.2026.
//

import Foundation

/// Describes callbacks from the task details interactor.
protocol TaskDetailsInteractorOutputProtocol: AnyObject {
    func didSaveTask()
    func didFailSavingTask(_ error: Error)
}
