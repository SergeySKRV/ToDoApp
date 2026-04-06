//
//  TaskListRouterTests.swift
//  ToDoAppTests
//
//  Created by Сергей Скориков on 06.04.2026.
//

import XCTest
import UIKit
@testable import ToDoApp

final class TaskListRouterTests: XCTestCase {

    // MARK: - Tests

    func test_openCreate_pushesViewController() {
        let navigationController = NavigationControllerSpy()
        let root = UIViewController()
        let sut = TaskListRouter()

        navigationController.viewControllers = [root]
        sut.viewController = root

        sut.openCreate()

        XCTAssertEqual(navigationController.pushCallCount, 1)
        XCTAssertNotNil(navigationController.pushedViewController)
    }

    func test_openEdit_pushesViewController() {
        let navigationController = NavigationControllerSpy()
        let root = UIViewController()
        let sut = TaskListRouter()

        navigationController.viewControllers = [root]
        sut.viewController = root

        let todo = TodoModel(
            id: UUID(),
            remoteID: 1,
            title: "Test",
            taskDescription: "Description",
            createdAt: Date(),
            updatedAt: Date(),
            isCompleted: false,
            userId: 10,
            isImported: false
        )

        sut.openEdit(todo: todo)

        XCTAssertEqual(navigationController.pushCallCount, 1)
        XCTAssertNotNil(navigationController.pushedViewController)
    }

    func test_openCreate_whenViewControllerHasNoNavigationController_doesNotCrash() {
        let root = UIViewController()
        let sut = TaskListRouter()
        sut.viewController = root

        sut.openCreate()
    }

    func test_openEdit_whenViewControllerHasNoNavigationController_doesNotCrash() {
        let root = UIViewController()
        let sut = TaskListRouter()
        sut.viewController = root

        let todo = TodoModel(
            id: UUID(),
            remoteID: nil,
            title: "Test",
            taskDescription: "Description",
            createdAt: Date(),
            updatedAt: Date(),
            isCompleted: false,
            userId: nil,
            isImported: false
        )

        sut.openEdit(todo: todo)
    }
}

// MARK: - NavigationControllerSpy

private final class NavigationControllerSpy: UINavigationController {

    private(set) var pushCallCount = 0
    private(set) var pushedViewController: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushCallCount += 1
        pushedViewController = viewController
        super.pushViewController(viewController, animated: false)
    }
}
