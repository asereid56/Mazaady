//
//  LanguageViewController.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import UIKit

class LanguageViewController: UIViewController {

    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var serachView: UISearchBar!
    @IBOutlet weak var languageTableView: UITableView!
    
    var onConfirm: ((String) -> Void)? = nil
    private var filteredLanguages: [LanguageEntity] = []

    var languages: [LanguageEntity] = [
        LanguageEntity(id: "en", name: "English".localized(), isSelected: Locale.current.language.languageCode?.identifier == "en"),
        LanguageEntity(id: "ar", name: "Arabic".localized(), isSelected: Locale.current.language.languageCode?.identifier == "ar")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white90
        languageLabel.text = "Language".localized()
        configureSearchBarAppearance()
        setupTableView()
        loadCurrentLanguage()
        setupSheetPresentation()
        filteredLanguages = languages
        serachView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let attribute: UISemanticContentAttribute = LanguageManager.shared.currentLanguage == "ar" ? .forceRightToLeft : .forceLeftToRight
        navigationController?.view.semanticContentAttribute = attribute
        view.semanticContentAttribute = attribute
    }
    
    private func setupTableView() {
        languageTableView.dataSource = self
        languageTableView.delegate = self
        languageTableView.register(UINib(nibName: "LanguageCell", bundle: nil), forCellReuseIdentifier: "LanguageCell")
    }
    
    private func configureSearchBarAppearance() {
        if let textField = serachView.value(forKey: "searchField") as? UITextField {
            if let iconView = textField.leftView as? UIImageView {
                iconView.tintColor = .pink100
                iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
            }
            textField.placeholder = "Search".localized()
        }
    }
    
    private func loadCurrentLanguage() {
        languages = languages.map {
            var lang = $0
            lang.isSelected = lang.id == LanguageManager.shared.currentLanguage
            return lang
        }
    }
    
    private func setupSheetPresentation() {
        if #available(iOS 15.0, *), let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
}


extension LanguageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLanguages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
        cell.configure(with: filteredLanguages[indexPath.row])
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLanguage = filteredLanguages[indexPath.row]
        
        languages = languages.map {
            var lang = $0
            lang.isSelected = (lang.id == selectedLanguage.id)
            return lang
        }
        
        filteredLanguages = languages.filter {
            guard let searchText = serachView.text?.lowercased(), !searchText.isEmpty else { return true }
            return $0.name.lowercased().contains(searchText)
        }
        
        LanguageManager.shared.setLanguage(code: selectedLanguage.id)
        onConfirm?(selectedLanguage.id)
        
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: true)
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


extension LanguageViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredLanguages = languages.filter {
            searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased())
        }
        languageTableView.reloadData()
    }
}
