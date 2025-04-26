//
//  RealmManager.swift
//  Mazaady
//
//  Created by Aser Eid on 26/04/2025.
//

import RealmSwift
import Realm

class RealmManager {
    static let shared = RealmManager()
    private let realm = try! Realm()
    
    private init() {}
    
    func save<T: Object>(_ object: T) {
        try? realm.write {
            realm.add(object, update: .modified)
        }
    }
    
    func saveList<T: Object>(_ objects: [T]) {
        try? realm.write {
            realm.add(objects, update: .modified)
        }
    }
    
    func fetchList<T: Object>(_ type: T.Type) -> [T] {
        Array(realm.objects(type))
    }
    
    func fetchFirst<T: Object>(_ type: T.Type) -> T? {
        realm.objects(type).first
    }
    
    func clear<T: Object>(_ type: T.Type) {
        try? realm.write {
            let objects = realm.objects(type)
            realm.delete(objects)
        }
    }
}

