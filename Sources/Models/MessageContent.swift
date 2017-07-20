//
//  MessageContent.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class MessageContent: NSObject, NSCoding, Mappable {

    var name: String? = ""
    var url: String? = ""
    var type: String? = ""

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        name    <- map["name"]
        url     <- map["url"]
        type    <- map["type"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.url = aDecoder.decodeObject(forKey: "url") as? String
        self.type = aDecoder.decodeObject(forKey: "type") as? String
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.type, forKey: "type")
    }
}
