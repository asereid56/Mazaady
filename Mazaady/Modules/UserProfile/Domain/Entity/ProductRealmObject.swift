//
//  ProductRealmObject.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import RealmSwift
import Realm

class ProductRealmObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var image: String
    @Persisted var price: Int
    @Persisted var currency: String
    @Persisted var offer: Int?
    @Persisted var endDate: Double?
    
    convenience init(entity: ProductEntity) {
        self.init()
        self.id = entity.id
        self.name = entity.name
        self.image = entity.image
        self.price = entity.price
        self.currency = entity.currency
        self.offer = entity.offer
        self.endDate = entity.endDate
    }
    
    func toEntity() -> ProductEntity {
        .init(id: id, name: name, image: image, price: price, currency: currency, offer: offer, endDate: endDate)
    }
}
