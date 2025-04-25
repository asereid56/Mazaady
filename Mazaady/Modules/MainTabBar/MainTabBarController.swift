//
//  MainTabBarController.swift
//  Mazaady
//
//  Created by Aser Eid on 24/04/2025.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let middleTabIndex = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupTabBar()
        setupTabs()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.styleMiddleTab(selected: false)
        }
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .white
        tabBar.tintColor = UIColor(named: "Pink100")
        tabBar.unselectedItemTintColor = UIColor(named: "Gray20")
        tabBar.layer.cornerRadius = 20
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 8
    }
    
    private func setupTabs() {
        let homeVC = UIViewController()
        homeVC.view.backgroundColor = .white
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), tag: 0)
        
        let searchVC = UIViewController()
        searchVC.view.backgroundColor = .white
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        let storeVC = UIViewController()
        storeVC.view.backgroundColor = .white
        storeVC.tabBarItem = createMiddleTabBarItem()
        
        let cartVC = UIViewController()
        cartVC.view.backgroundColor = .white
        cartVC.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(named: "bag"), tag: 3)
        
        let userProfileUseCase = UserProfileUseCase()
        let advertisingUseCase = AdvertisementUseCase()
        let tagsUseCase = TagUseCase()
        let productUseCase = ProductUseCase()
        let profileViewModel = ProfileViewModel(
            userUseCase: userProfileUseCase,
            productUseCase: productUseCase,
            advertismentUseCase: advertisingUseCase,
            tagUseCase: tagsUseCase
        )
        let profileVC = ProfileViewController(viewModel: profileViewModel)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 4)
        
        viewControllers = [
            homeVC,
            searchVC,
            storeVC,
            cartVC,
            profileVC
        ]
    }
    
    private func createMiddleTabBarItem() -> UITabBarItem {
        let image = UIImage(named: "shop")
        let item = UITabBarItem(title: nil, image: image, selectedImage: image)
        
        item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 300)
        return item
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index = tabBar.items?.firstIndex(of: item) ?? 0
        styleMiddleTab(selected: index == middleTabIndex)
    }
    
    private func styleMiddleTab(selected: Bool) {
        guard tabBar.subviews.count > middleTabIndex + 1 else { return }
        
        let tabBarButtons = tabBar.subviews.filter { $0 is UIControl }
        guard middleTabIndex < tabBarButtons.count,
              let middleTabButton = tabBarButtons[middleTabIndex] as? UIControl,
              let imageView = middleTabButton.subviews.compactMap({ $0 as? UIImageView }).first else { return }
        
        middleTabButton.backgroundColor = selected ? .clear : UIColor(named: "Pink100")
        middleTabButton.layer.cornerRadius = 16
        middleTabButton.frame.size = CGSize(width: 44, height: 44)
        middleTabButton.center = CGPoint(x: tabBar.center.x, y: tabBar.bounds.midY - 10)
        
        imageView.contentMode = .scaleToFill
        imageView.frame = CGRect(x: 10, y: 10, width: 34, height: 34)
        imageView.center = CGPoint(x: middleTabButton.bounds.midX, y: middleTabButton.bounds.midY)
        imageView.tintColor = selected ? UIColor(named: "Pink100") : .white
    }
    
}
