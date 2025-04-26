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
    
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var searchButton: UIButton!
    
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
        setupTagsCollectionView()
    }
    
    private func setupCollectionView() {
        productsCollectionView.register(UINib(nibName: "ProductCell", bundle: nil),
                                        forCellWithReuseIdentifier: "ProductCell")
        productsCollectionView.dataSource = self
        productsCollectionView.delegate = self
        productsCollectionView.isScrollEnabled = false
        productsCollectionView.backgroundColor = .clear
        
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
    
    private func setupTagsCollectionView() {
        tagsCollectionView.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        tagsCollectionView.isScrollEnabled = false
        tagsCollectionView.backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tagsCollectionView.collectionViewLayout = layout
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.updateContentViewHeight()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                self?.productsCollectionView.reloadData()
                if products.isEmpty {
                    self?.emptyView.isHidden = false
                    self?.emptyLabel.text = "Try search by another word..."
                } else {
                    self?.emptyView.isHidden = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.updateContentViewHeight()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$advertisements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.adsTableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.updateContentViewHeight()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$tags
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tags in
                self?.tagsCollectionView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.updateContentViewHeight()
                }
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
        searchButton.layer.cornerRadius = 10
        searchButton.layer.opacity = 0.4
        searchButton.setTitleColor(.pink100, for: .normal)
        searchButton.backgroundColor = .pink100
        searchButton.layer.cornerRadius = 10
        searchButton.layer.masksToBounds = true
        searchButton.tintColor = .pink100
        configureSearchBarAppearance()
        viewModel.selectTab(.products)
    }
    
    private func configureSearchBarAppearance() {
        if let textField = searchView.value(forKey: "searchField") as? UITextField {
            if let iconView = textField.leftView as? UIImageView {
                iconView.tintColor = .pink100
                iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
            }
            textField.placeholder = "Search".localized()
        }
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
        if LanguageManager.shared.currentLanguage == "ar" {
            changeLanguageLabel.setTitle("Arabic".localized(), for: .normal)
        } else {
            changeLanguageLabel.setTitle("English".localized(), for: .normal)
        }
        followersLabel.text = "Followers".localized(comment: "")
        followingLabel.text = "Following".localized()
        productLabel.text = "Products".localized()
        reviewLabel.text = "Reviews".localized()
        followersButtonLabel.text = "Followers".localized()
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
            tagsCollectionView.isHidden = false
            
        case .reviews:
            reviewLabel.textColor = UIColor(named: "Pink100")
            reviewLine.isHidden = false
            productsCollectionView.isHidden = true
            emptyView.isHidden = false
            emptyLabel.text = NSLocalizedString("No Reviews Yet", comment: "")
            adsTableView.isHidden = true
            tagsCollectionView.isHidden = true
            
        case .followers:
            followersButtonLabel.textColor = UIColor(named: "Pink100")
            followersLine.isHidden = false
            productsCollectionView.isHidden = true
            emptyView.isHidden = false
            emptyLabel.text = NSLocalizedString("No Followers Yet", comment: "")
            adsTableView.isHidden = true
            tagsCollectionView.isHidden = true
            
        }
    }
    
    private func updateContentViewHeight() {
        [productsCollectionView, tagsCollectionView, adsTableView].forEach { view in
            guard let view = view else { return }
            view.constraints.filter { $0.firstAttribute == .height }.forEach { $0.constant = view.contentSize.height }
        }
        contentView.layoutIfNeeded()
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
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        viewModel.productsFetched = false
        let searchText = searchView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        viewModel.fetchProducts(searchText: searchText)
    }
    
    @IBAction func changeLanguageButton(_ sender: Any) {
        let vc = LanguageViewController()
            vc.modalPresentationStyle = .formSheet
            vc.onConfirm = { [weak self] langCode in
                LanguageManager.shared.setLanguage(code: langCode)
                self?.reloadApplication()
            }
            self.present(vc, animated: true)
    }
    
    private func reloadApplication() {
        guard let window = view.window ?? UIApplication.shared.windows.first else { return }
        
        let navController = UINavigationController()
        navController.view.semanticContentAttribute = LanguageManager.shared.isRTL ? .forceRightToLeft : .forceLeftToRight
        
        let newCoordinator = MainCoordinator(navigationController: navController)
        newCoordinator.start()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = navController
        }, completion: nil)
    }
}


// MARK: - UICollectionViewDataSource & Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == productsCollectionView {
            return viewModel.products.count
        } else {
            return viewModel.tags.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == productsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            let product = viewModel.products[indexPath.item]
            cell.configure(with: product)
            return cell
        } else if collectionView == tagsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
            let tag = viewModel.tags[indexPath.item]
            cell.configure(with: tag.name, isSelected: viewModel.isTagSelected(at: indexPath.item))
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tagsCollectionView {
            viewModel.toggleTagSelection(at: indexPath.item)
            tagsCollectionView.reloadItems(at: [indexPath])
        }
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

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tagsCollectionView  {
            
            let tag = viewModel.tags[indexPath.item]
            let font = UIFont.systemFont(ofSize: 14, weight: .medium)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            
            let textWidth = (tag.name as NSString)
                .size(withAttributes: attributes)
                .width
            
            return CGSize(
                width: textWidth + 16,
                height: 24
            )
        }
        return CGSize(width: 100, height: 100)
    }
}
