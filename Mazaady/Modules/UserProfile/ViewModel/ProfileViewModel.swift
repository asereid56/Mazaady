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
    @Published private(set) var tags: [Tag] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private var selectedTagIndices = Set<Int>()
    @Published var selectedTab: SelectedTab = .products {
        didSet {
            if selectedTab == .products {
                fetchProducts(searchText: "")
                fetchAdvertisements()
                fetchTags()
            }
        }
    }
    var productsFetched = false
    var advertisementsFetched = false
    var tagsFetched = false
    
    enum SelectedTab {
        case products
        case reviews
        case followers
    }
    
    // MARK: Use Cases
    private let userUseCase: UserProfileUseCase
    private let productUseCase: ProductUseCase
    private let advertismentUseCase: AdvertisementUseCase
    private let tagUseCase: TagUseCase
    
    init(
        userUseCase: UserProfileUseCase,
        productUseCase: ProductUseCase,
        advertismentUseCase: AdvertisementUseCase,
        tagUseCase: TagUseCase
    ) {
        self.userUseCase = userUseCase
        self.productUseCase = productUseCase
        self.advertismentUseCase = advertismentUseCase
        self.tagUseCase = tagUseCase
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
    
    func fetchProducts(searchText: String) {
        guard !productsFetched else { return }
        isLoading = true
        errorMessage = nil
        
        let request = ProductsRequest(query: searchText)
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
    
    func fetchTags() {
        guard !tagsFetched else { return }
        isLoading = true
        errorMessage = nil
        
        let request = TagRequest()
        tagUseCase.execute(request: request) { [weak self] result in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let tags):
                    self.tagsFetched = true
                    self.tags = tags.tags
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func selectTab(_ tab: SelectedTab) {
        selectedTab = tab
    }
    
    func isTagSelected(at index: Int) -> Bool {
        selectedTagIndices.contains(index)
    }

    func toggleTagSelection(at index: Int) {
        if selectedTagIndices.contains(index) {
            selectedTagIndices.remove(index)
        } else {
            selectedTagIndices.insert(index)
        }
    }
}
