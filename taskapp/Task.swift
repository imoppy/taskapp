//
//  Task.swift
//  taskapp
//
//  Created by 若原 旬 on 2022/03/10.
//

import RealmSwift

class Task: Object {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var contents = ""
    @objc dynamic var date = Date()

    override static func primaryKey() -> String? {
        return "id"
    }
}
