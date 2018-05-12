//
//  Item.swift
//  Todoey
//
//  Created by Yassine Sabeq on 5/10/18.
//  Copyright © 2018 Yassine Sabeq. All rights reserved.
//

import Foundation

class Item : Codable { // since Swift 4 , Codable means that the class conform to both Codable and Decodable Protocols
    
    var title : String = ""
    var done : Bool = false
    
}
