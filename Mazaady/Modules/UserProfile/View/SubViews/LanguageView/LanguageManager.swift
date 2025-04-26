//
//  LanguageManager.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import Foundation
import UIKit

class LanguageManager {
    static let shared = LanguageManager()
    private let userDefaults = UserDefaults.standard
    
    var currentLanguage: String {
        return userDefaults.string(forKey: "SelectedLanguage") ?? "en"
    }
    
    var isRTL: Bool {
        return currentLanguage == "ar"
    }
    
    func setLanguage(code: String) {
        userDefaults.set(code, forKey: "SelectedLanguage")
        userDefaults.synchronize()
        applyLanguageSettings()
    }
    
    private func applyLanguageSettings() {
        let semantic: UISemanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = semantic
        UINavigationBar.appearance().semanticContentAttribute = semantic
        UITabBar.appearance().semanticContentAttribute = semantic
    }
}
