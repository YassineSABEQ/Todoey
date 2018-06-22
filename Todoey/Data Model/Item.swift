//
//  Item.swift
//  Todoey
//
//  Created by Yassine Sabeq on 6/17/18.
//  Copyright © 2018 Yassine Sabeq. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdAt: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
