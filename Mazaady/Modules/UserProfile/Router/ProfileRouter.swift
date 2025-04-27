//
//  ProfileRouter.swift
//  Mazaady
//
//  Created by Aser Eid on 27/04/2025.
//

import Foundation

final class ProfileRouter {
    weak var viewController: ProfileViewController?
    
    init(viewController: ProfileViewController?) {
        self.viewController = viewController
    }
    
    static func create() -> ProfileViewController {
        let userProfileUseCase = UserProfileUseCase()
        let advertisingUseCase = AdvertisementUseCase()
        let tagsUseCase = TagUseCase()
        let productUseCase = ProductUseCase()
        
        let router = ProfileRouter(viewController: nil)
        
        let viewModel = ProfileViewModel(
            router: router,
            userUseCase: userProfileUseCase,
            productUseCase: productUseCase,
            advertismentUseCase: advertisingUseCase,
            tagUseCase: tagsUseCase
        )
        
        let vc = ProfileViewController(viewModel: viewModel)
        router.viewController = vc
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
    
    // Navigation
    
    func navigateToLanguageSelection(onConfirm: @escaping (String) -> Void) {
        let languageVC = LanguageViewController()
        languageVC.modalPresentationStyle = .formSheet
        languageVC.onConfirm = { [weak self] langCode in
            onConfirm(langCode)
            self?.viewController?.dismiss(animated: true)
        }
        viewController?.present(languageVC, animated: true)
    }
}
