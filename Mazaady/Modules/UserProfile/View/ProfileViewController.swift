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
    // MARK: - Outlets
    // User Info
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var userProfileUserName: UILabel!
    @IBOutlet weak var userProfileCity: UILabel!
    @IBOutlet weak var userFollowingCount: UILabel!
    @IBOutlet weak var userFollowersCount: UILabel!
    // Loading
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    // Language
    @IBOutlet weak var changeLanguageLabel: UIButton!
    // Tabs
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productLine: UIView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewLine: UIView!
    @IBOutlet weak var followersButtonLabel: UILabel!
    @IBOutlet weak var followersLine: UIView!
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var adsTableView: UITableView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerContainer: UIStackView!
    @IBOutlet weak var stickyTabsContainer: UIStackView!
    @IBOutlet weak var contentView: UIView!
    
    
    // MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
    private var originalTabsFrame: CGRect = .zero
    let viewModel: ProfileViewModel
    private var prototypeCell: ProductCell?
    
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
        setupTapGestures()
        viewModel.fetchProfile()
        setupScreenLocalization()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        productsCollectionView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "ProductCell")
        productsCollectionView.dataSource = self
        productsCollectionView.delegate = self
        productsCollectionView.isScrollEnabled = false
        productsCollectionView.backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        productsCollectionView.collectionViewLayout = layout
        
        // Load prototype cell for size calculations
        prototypeCell = Bundle.main.loadNibNamed("ProductCell", owner: nil, options: nil)?.first as? ProductCell
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
        
        viewModel.$selectedTab
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedTab in
                self?.updateTabAppearance(for: selectedTab)
            }
            .store(in: &cancellables)
        
        viewModel.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.productsCollectionView.reloadData()
                self?.updateContentViewHeight()
            }
            .store(in: &cancellables)
    }
    
    private func configureUI() {
        userProfileImage.layer.cornerRadius = 18
        userProfileImage.clipsToBounds = true
        progressView.hidesWhenStopped = true
        contentView.backgroundColor = .pink10
        adsTableView.backgroundColor = .clear
        tagsCollectionView.backgroundColor = .clear
        updateTabAppearance(for: .products)
        viewModel.selectTab(.products)
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
        userFollowingCount.text = "\(profile.followingCount)"
        userFollowersCount.text = "\(profile.followersCount)"
    }
    
    private func setupScreenLocalization() {
        changeLanguageLabel.setTitle(NSLocalizedString("English", comment: ""), for: .normal)
        followersLabel.text = NSLocalizedString("Followers", comment: "")
        followingLabel.text = NSLocalizedString("Following", comment: "")
        productLabel.text = NSLocalizedString("Products", comment: "")
        reviewLabel.text = NSLocalizedString("Reviews", comment: "")
        followersButtonLabel.text = NSLocalizedString("Followers", comment: "")
    }
    
    private func setupTapGestures() {
        let productTap = UITapGestureRecognizer(target: self, action: #selector(productTabTapped))
        productLabel.isUserInteractionEnabled = true
        productLabel.addGestureRecognizer(productTap)
        
        let reviewTap = UITapGestureRecognizer(target: self, action: #selector(reviewTabTapped))
        reviewLabel.isUserInteractionEnabled = true
        reviewLabel.addGestureRecognizer(reviewTap)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTabTapped))
        followersButtonLabel.isUserInteractionEnabled = true
        followersButtonLabel.addGestureRecognizer(followersTap)
    }
    
    private func updateTabAppearance(for selectedTab: ProfileViewModel.SelectedTab) {
        resetAllTabs()
        
        switch selectedTab {
        case .products:
            productLabel.textColor = UIColor(named: "Pink100")
            productLine.isHidden = false
            productsCollectionView.isHidden = false
            emptyView.isHidden = true
            
        case .reviews:
            reviewLabel.textColor = UIColor(named: "Pink100")
            reviewLine.isHidden = false
            productsCollectionView.isHidden = true
            emptyView.isHidden = false
            emptyLabel.text = NSLocalizedString("No Reviews Yet", comment: "")

        case .followers:
            followersButtonLabel.textColor = UIColor(named: "Pink100")
            followersLine.isHidden = false
            productsCollectionView.isHidden = true
            emptyView.isHidden = false
            emptyLabel.text = NSLocalizedString("No Followers Yet", comment: "")
        }
    }
    
    private func updateContentView(for selectedTab: ProfileViewModel.SelectedTab) {
        switch selectedTab {
        case .products:
            productsCollectionView.isHidden = false
            // Hide other content views here
            
        case .reviews:
            productsCollectionView.isHidden = true
            contentView.layoutIfNeeded()
            
        case .followers:
            productsCollectionView.isHidden = true
        }
    }
    
    private func updateContentViewHeight() {
        productsCollectionView.layoutIfNeeded()
        let collectionHeight = productsCollectionView.contentSize.height
        
        // Update collection view height constraint if exists
        if let heightConstraint = productsCollectionView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = collectionHeight
        } else {
            productsCollectionView.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        }
        
        // Update content view height
        contentView.layoutIfNeeded()
        let contentHeight = headerContainer.frame.height +
                           stickyTabsContainer.frame.height +
                           collectionHeight + 40 // Add padding
        contentView.frame.size.height = contentHeight
        scrollView.contentSize = contentView.frame.size
    }
    
    
    private func resetAllTabs() {
        let defaultTextColor = UIColor(named: "Gray80") ?? .gray
        
        productLabel.textColor = defaultTextColor
        productLine.isHidden = true
        
        reviewLabel.textColor = defaultTextColor
        reviewLine.isHidden = true
        
        followersButtonLabel.textColor = defaultTextColor
        followersLine.isHidden = true
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
    
    // MARK: - Actions
    @objc private func productTabTapped() {
        viewModel.selectTab(.products)
    }
    
    @objc private func reviewTabTapped() {
        viewModel.selectTab(.reviews)
    }
    
    @objc private func followersTabTapped() {
        viewModel.selectTab(.followers)
    }
    
    @IBAction func changeLanguageButton(_ sender: Any) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}


// MARK: - UICollectionViewDataSource & Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let product = viewModel.products[indexPath.item]
        cell.configure(with: product)
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 16
        let totalHorizontalInset: CGFloat = 16 * 2 // Left + Right insets
        let numberOfItemsPerRow: CGFloat = 3
        let availableWidth = collectionView.bounds.width - totalHorizontalInset - (numberOfItemsPerRow - 1) * spacing
        let itemWidth = availableWidth / numberOfItemsPerRow
        
        guard let prototypeCell = prototypeCell else {
            return CGSize(width: itemWidth, height: 100) // Fallback size
        }
        
        let product = viewModel.products[indexPath.item]
        prototypeCell.configure(with: product)
        prototypeCell.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set width constraint
        let widthConstraint = prototypeCell.contentView.widthAnchor.constraint(equalToConstant: itemWidth)
        prototypeCell.contentView.addConstraint(widthConstraint)
        
        // Calculate size
        let targetSize = CGSize(width: itemWidth, height: UIView.layoutFittingCompressedSize.height)
        let height = prototypeCell.contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        // Clean up constraint
        prototypeCell.contentView.removeConstraint(widthConstraint)
        
        return CGSize(width: itemWidth, height: height)
    }
}
