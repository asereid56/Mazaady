//
//  ProfileViewController.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import UIKit
import Kingfisher
import Combine

class ProfileViewController: UIViewController {
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var userProfileUserName: UILabel!
    @IBOutlet weak var userProfileCity: UILabel!
    @IBOutlet weak var userFollowing: UILabel!
    @IBOutlet weak var userFollowers: UILabel!
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    @IBOutlet weak var changeLanguageLabel: UIButton!
    
    private var cancellables: Set<AnyCancellable> = []
    let viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setupBindings()
        configureUI()
        viewModel.fetchProfile()
        setupLanguageButton()
    }
    
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.progressView.startAnimating() : self?.progressView.stopAnimating()
            }
            .store(in: &cancellables)
        
        viewModel.$profile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                if let profile = profile {
                    self?.updateUI(with: profile)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showError(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }
    
    private func configureUI() {
        userProfileImage.layer.cornerRadius = 18
        userProfileImage.clipsToBounds = true
        progressView.hidesWhenStopped = true
    }
    
    private func updateUI(with profile: ProfileEntity) {
        if let imageUrl = URL(string: profile.image) {
            userProfileImage.kf.setImage(
                with: imageUrl,
                placeholder: UIImage(named: "profilePlaceholder"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        }
        
        userProfileName.text = profile.name
        userProfileUserName.text = "@\(profile.userName)"
        userProfileCity.text = profile.countryName + "," + profile.cityName
        userFollowing.text = "\(profile.followingCount)"
        userFollowers.text = "\(profile.followersCount)"
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupLanguageButton() {
        // Set appropriate title for the button
        changeLanguageLabel.setTitle(NSLocalizedString("English", comment: ""), for: .normal)
    }
    
    @IBAction func changeLanguageButton(_ sender: Any) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
