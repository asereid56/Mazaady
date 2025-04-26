//
//  AdvertisementRealmObject.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import RealmSwift

class AdvertisementRealmObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var image: String

    convenience init(entity: Advertisement) {
        self.init()
        self.id = entity.id
        self.image = entity.image
    }

    func toEntity() -> Advertisement {
        Advertisement(id: id, image: image)
    }
}
