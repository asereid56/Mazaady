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
        setupTableView()
    }
    
    private func setupCollectionView() {
        productsCollectionView.register(UINib(nibName: "ProductCell", bundle: nil),
                                        forCellWithReuseIdentifier: "ProductCell")
        productsCollectionView.dataSource = self
        productsCollectionView.delegate = self
        productsCollectionView.isScrollEnabled = false
        productsCollectionView.backgroundColor = .clear

        // Replace flow layout with our WaterfallLayout
        let layout = WaterfallLayout()
        layout.delegate = self
        layout.numberOfColumns = 3
        layout.cellPadding = 16
        productsCollectionView.collectionViewLayout = layout

        // Prototype cell for dynamic sizing
        prototypeCell = Bundle.main
            .loadNibNamed("ProductCell", owner: nil, options: nil)?
            .first as? ProductCell
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "advertisementCell", bundle: nil)
        adsTableView.register(nib, forCellReuseIdentifier: "advertisementCell")
        adsTableView.dataSource = self
        adsTableView.delegate = self
        adsTableView.rowHeight = 163
        adsTableView.estimatedRowHeight = 163
        adsTableView.separatorStyle = .none
        adsTableView.backgroundColor = .clear
        adsTableView.isScrollEnabled = false
        adsTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
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
                self?.updateContentViewHeight()
            }
            .store(in: &cancellables)
        
        viewModel.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.productsCollectionView.reloadData()
                self?.updateContentViewHeight()
            }
            .store(in: &cancellables)
        
        viewModel.$advertisements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.adsTableView.reloadData()
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
            adsTableView.isHidden = false
            
        case .reviews:
            reviewLabel.textColor = UIColor(named: "Pink100")
            reviewLine.isHidden = false
            productsCollectionView.isHidden = true
            emptyView.isHidden = false
            emptyLabel.text = NSLocalizedString("No Reviews Yet", comment: "")
            adsTableView.isHidden = true

        case .followers:
            followersButtonLabel.textColor = UIColor(named: "Pink100")
            followersLine.isHidden = false
            productsCollectionView.isHidden = true
            emptyView.isHidden = false
            emptyLabel.text = NSLocalizedString("No Followers Yet", comment: "")
            adsTableView.isHidden = true

        }
    }
    
    private func updateContentViewHeight() {
        // Calculate Products Collection View Height
        productsCollectionView.layoutIfNeeded()
        let collectionHeight = productsCollectionView.contentSize.height
        
        // Update collection view height constraint
        if let heightConstraint = productsCollectionView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = collectionHeight
        } else {
            productsCollectionView.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        }
        
        // Calculate Ads Table View Height
        let adsCount = viewModel.advertisements.count
        let rowHeight: CGFloat = 147 + 16 // Cell height + padding
        let adsHeight = CGFloat(adsCount) * rowHeight + adsTableView.contentInset.top + adsTableView.contentInset.bottom
        
        // Update ads table view height constraint
        if let adsHeightConstraint = adsTableView.constraints.first(where: { $0.firstAttribute == .height }) {
            adsHeightConstraint.constant = adsHeight
        } else {
            adsTableView.heightAnchor.constraint(equalToConstant: adsHeight).isActive = true
        }
        
        // Calculate Total Content Height
        contentView.layoutIfNeeded()
        var contentHeight: CGFloat = headerContainer.frame.height +
                                    stickyTabsContainer.frame.height
        
        if viewModel.selectedTab == .products {
            contentHeight += adsHeight + collectionHeight + 40 // Add padding between sections
        } else {
            contentHeight += 40 // Empty view padding
        }
        
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

extension ProfileViewController: WaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemAt indexPath: IndexPath,
                        withWidth itemWidth: CGFloat) -> CGFloat {
        guard let prototypeCell = prototypeCell else {
            return 100
        }
        let product = viewModel.products[indexPath.item]
        prototypeCell.configure(with: product)
        
        // Constrain width, then let Auto Layout compute fitting height
        prototypeCell.contentView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = prototypeCell.contentView
            .widthAnchor
            .constraint(equalToConstant: itemWidth)
        prototypeCell.contentView.addConstraint(widthConstraint)

        let targetSize = CGSize(width: itemWidth,
                                height: UIView.layoutFittingCompressedSize.height)
        let height = prototypeCell.contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        prototypeCell.contentView.removeConstraint(widthConstraint)
        return height
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.advertisements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "advertisementCell", for: indexPath) as! advertisementCell
        let ad = viewModel.advertisements[indexPath.row]
        cell.advertismentCell.kf.setImage(with: URL(string: ad.image))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 163
    }
}
