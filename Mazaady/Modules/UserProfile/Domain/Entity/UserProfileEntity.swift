//
//  UserProfileMapper.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import Foundation

struct ProfileEntity: BaseResponse {
    let id: Int
    let name: String
    let image: String
    let userName: String
    let followingCount: Int
    let followersCount: Int
    let countryName: String
    let cityName: String
}
