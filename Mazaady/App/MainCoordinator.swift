//
//  MainCoordinator.swift
//  Mazaady
//
//  Created by Aser Eid on 24/04/2025.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}


class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBarController = MainTabBarController()
        navigationController.setViewControllers([tabBarController], animated: true)
    }
}
