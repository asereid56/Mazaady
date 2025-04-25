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
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let useCase: UserProfileUseCase

    init(useCase: UserProfileUseCase) {
        self.useCase = useCase
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
}
