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
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var selectedTab: SelectedTab = .products {
        didSet {
            if selectedTab == .products {
                fetchProducts()
            }
        }
    }
    private var productsFetched = false
    
    enum SelectedTab {
        case products
        case reviews
        case followers
    }
    
    // MARK: Use Cases
    private let useCase: UserProfileUseCase
    private let productUseCase: ProductUseCase
    
    init(useCase: UserProfileUseCase, productUseCase: ProductUseCase) {
        self.useCase = useCase
        self.productUseCase = productUseCase
    }
    
    func fetchProfile() {
        isLoading = true
        errorMessage = nil
        
        let request = UserProfileRequest()
        useCase.execute(request: request) { [weak self] result in
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
                    print("Asooor \(products)")
                    self.productsFetched = true 
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
