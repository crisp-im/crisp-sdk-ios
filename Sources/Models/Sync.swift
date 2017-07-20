//
//  Sync.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class Sync: NSObject, NSCoding, Mappable {

    var compose: Compose? = nil
    var messages: [Message] = []

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        compose     <- map["compose"]
        messages     <- map["messages"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.compose = aDecoder.decodeObject(forKey: "compose") as? Compose
        self.messages = aDecoder.decodeObject(forKey: "messages") as! [Message]
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.compose, forKey: "compose")
        aCoder.encode(self.messages, forKey: "messages")
    }
}
