//
//  advertisementsEntity.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Foundation

struct AdvertismentsEntity: BaseResponse {
    let advertisements: [Advertisement]
}

struct Advertisement: Codable {
    let id: Int
    let image: String
}
