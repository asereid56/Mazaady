//
//  ProfileViewModel.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: ProfileEntity?
    @Published private(set) var products: [ProductEntity] = []
    @Published private(set) var advertisements: [Advertisement] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var selectedTab: SelectedTab = .products {
        didSet {
            if selectedTab == .products {
                fetchProducts()
                fetchAdvertisements()
            }
        }
    }
    private var productsFetched = false
    private var advertisementsFetched = false
    
    enum SelectedTab {
        case products
        case reviews
        case followers
    }
    
    // MARK: Use Cases
    private let userUseCase: UserProfileUseCase
    private let productUseCase: ProductUseCase
    private let advertismentUseCase: AdvertisementUseCase
    
    init(
        userUseCase: UserProfileUseCase,
        productUseCase: ProductUseCase,
        advertismentUseCase: AdvertisementUseCase
    ) {
        self.userUseCase = userUseCase
        self.productUseCase = productUseCase
        self.advertismentUseCase = advertismentUseCase
    }
    
    func fetchProfile() {
        isLoading = true
        errorMessage = nil
        
        let request = UserProfileRequest()
        userUseCase.execute(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let entity):
                    self.profile = entity
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchProducts() {
        guard !productsFetched else { return }
        isLoading = true
        errorMessage = nil
        
        let request = ProductsRequest()
        productUseCase.execute(request: request) { [weak self] result in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let products):
                    self.products = products
                    self.productsFetched = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    
                }
            }
        }
    }
    
    func fetchAdvertisements() {
        guard !advertisementsFetched else { return }
        isLoading = true
        errorMessage = nil
        
        let request = AdvertisementsRequest()
        advertismentUseCase.execute(request: request) { [weak self] result in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let advertisements):
                    self.advertisements = advertisements.advertisements
                    self.advertisementsFetched = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func selectTab(_ tab: SelectedTab) {
        selectedTab = tab
    }
}
