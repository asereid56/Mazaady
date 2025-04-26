//
//  TagsRealm.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import RealmSwift

import RealmSwift

class TagRealmObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String

    convenience init(entity: Tag) {
        self.init()
        self.id = entity.id
        self.name = entity.name
    }

    func toEntity() -> Tag {
        Tag(id: id, name: name)
    }
}
