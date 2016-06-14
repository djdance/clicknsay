//
//  Kids.swift
//  clicknsay
//
//  Created by Dj Dance on 06.06.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import Foundation
import RealmSwift

class Kids: Object {
    
    dynamic var name = ""
    dynamic var createdAt = NSDate()
    dynamic var ico: NSData?
    let words = List<Word>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    

}
