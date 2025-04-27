//
//  AppFont.swift
//  Mazaady
//
//  Created by Aser Eid on 27/04/2025.
//

import Foundation
import UIKit

extension UILabel {
    func applyFont(name: CustomFont.FontName, size: CustomFont.FontSize) {
        self.font = UIFont(name: name.localized, size: size.rawValue)
    }
}

extension UIButton {
    func applyFont(name: CustomFont.FontName, size: CustomFont.FontSize) {
        self.titleLabel?.font = UIFont(name: name.localized, size: size.rawValue)
    }
}

extension UITextField {
    func applyFont(name: CustomFont.FontName, size: CustomFont.FontSize) {
        self.font = UIFont(name: name.localized, size: size.rawValue)
    }
}

extension UITextView {
    func applyFont(name: CustomFont.FontName, size: CustomFont.FontSize) {
        self.font = UIFont(name: name.localized, size: size.rawValue)
    }
}
