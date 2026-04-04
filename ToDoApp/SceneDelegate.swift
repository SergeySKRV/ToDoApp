//
//  SceneDelegate.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 01.04.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let rootViewController = TaskListModuleBuilder.build()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.isHidden = true

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) {
        try? CoreDataStack.shared.saveViewContext()
    }
}
