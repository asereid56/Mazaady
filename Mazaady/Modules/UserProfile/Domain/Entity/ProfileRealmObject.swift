//
//  ProfileRealmObject.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import RealmSwift
import Realm

class ProfileRealmObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var image: String
    @Persisted var userName: String
    @Persisted var followingCount: Int
    @Persisted var followersCount: Int
    @Persisted var countryName: String
    @Persisted var cityName: String

    convenience init(entity: ProfileEntity) {
        self.init()
        self.id = entity.id
        self.name = entity.name
        self.image = entity.image
        self.userName = entity.userName
        self.followingCount = entity.followingCount
        self.followersCount = entity.followersCount
        self.countryName = entity.countryName
        self.cityName = entity.cityName
    }
    
    func toEntity() -> ProfileEntity {
        .init(id: id, name: name, image: image, userName: userName, followingCount: followingCount, followersCount: followersCount, countryName: countryName, cityName: cityName)
    }
}
