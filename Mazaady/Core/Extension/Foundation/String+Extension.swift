//
//  String+Extension.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import Foundation

extension String {
    func localized(comment: String = "") -> String {
        guard let path = Bundle.main.path(forResource: LanguageManager.shared.currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: comment)
        }
        return bundle.localizedString(forKey: self, value: nil, table: nil)
    }
}
