//
//  ProductEntity.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Foundation

struct ProductEntity: BaseResponse {
    let id: Int
    let name: String
    let image: String
    let price: Int
    let currency: String
    let offer: Int?
    let endDate: Double?
}
