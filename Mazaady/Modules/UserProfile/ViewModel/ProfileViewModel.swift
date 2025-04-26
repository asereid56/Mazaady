//
//  ProfileViewModel.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Foundation
import Combine
import Realm
import RealmSwift

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
                    RealmManager.shared.save(ProfileRealmObject(entity: entity))
                case .failure(let error):
                    if error.localizedDescription.contains("offline") {
                        if let savedProfile = RealmManager.shared.fetchFirst(ProfileRealmObject.self) {
                            self.profile = savedProfile.toEntity()
                            self.errorMessage = error.localizedDescription
                        }
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
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
                    let realmProducts = products.map { ProductRealmObject(entity: $0) }
                    RealmManager.shared.saveList(realmProducts)
                case .failure(let error):
                    if error.localizedDescription.contains("offline") {
                        let savedProducts = RealmManager.shared.fetchList(ProductRealmObject.self).map { $0.toEntity() }
                        self.products = savedProducts
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
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
                case .success(let advertisementsEntity):
                    self.advertisements = advertisementsEntity.advertisements
                    self.advertisementsFetched = true
                    let realmAdvertisements = advertisementsEntity.advertisements.map { AdvertisementRealmObject(entity: $0) }
                    RealmManager.shared.saveList(realmAdvertisements)

                case .failure(let error):
                    if error.localizedDescription.contains("offline") {
                        let savedAdvertisements = RealmManager.shared.fetchList(AdvertisementRealmObject.self).map { $0.toEntity() }
                        self.advertisements = savedAdvertisements
                        self.advertisementsFetched = true
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
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
                self.isLoading = false

                switch result {
                case .success(let tagsEntity):
                    self.tagsFetched = true
                    self.tags = tagsEntity.tags
                    let realmTags = tagsEntity.tags.map { TagRealmObject(entity: $0) }
                    RealmManager.shared.saveList(realmTags)

                case .failure(let error):
                    if error.localizedDescription.contains("offline") {
                        let savedTags = RealmManager.shared.fetchList(TagRealmObject.self).map { $0.toEntity() }
                        self.tags = savedTags
                        self.tagsFetched = true
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
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
