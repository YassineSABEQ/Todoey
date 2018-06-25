//
//  Category.swift
//  Todoey
//
//  Created by Yassine Sabeq on 6/17/18.
//  Copyright © 2018 Yassine Sabeq. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    var items = List<Item>()
}
