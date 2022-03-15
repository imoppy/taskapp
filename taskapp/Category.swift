//
//  Category.swift
//  taskapp
//
//  Created by 若原 旬 on 2022/03/15.
//

import RealmSwift

class Category: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
