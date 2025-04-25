//
//  TagEntity.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import Foundation

struct TagEntity: BaseResponse {
    let tags: [Tag]
}

struct Tag: Codable {
    let id: Int
    let name: String
}
