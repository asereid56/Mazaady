//
//  CustomFont.swift
//  Mazaady
//
//  Created by Aser Eid on 27/04/2025.
//

import Foundation

struct CustomFont {
    private struct PrimaryEnglishFontName {
        static let regularFont = "Nunito-Regular"
        static let boldFont = "Nunito-Bold"
    }
    
    enum FontName {

        case title
        case body
        
        var localized: String {
            
            switch self {
            case .title:
                return PrimaryEnglishFontName.boldFont
            case .body:
                return PrimaryEnglishFontName.regularFont
            }
        }
    }
    
    enum FontSize: CGFloat {
        /// 8
        case xxSmall = 8
        /// 10
        case xSmall = 10
        /// 12
        case small = 12
        /// 14
        case medium = 14
        /// 16
        case large = 16
        /// 18
        case xLarge = 18
        /// 24
        case xxLarge = 24
    }
}
