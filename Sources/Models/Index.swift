//
//  Index.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class Index: NSObject, NSCoding, Mappable {

    var current: Int = 0
    var total: Int = 0

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        current     <- map["current"]
        total       <- map["total"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.current = aDecoder.decodeInteger(forKey: "current")
        self.total = aDecoder.decodeInteger(forKey: "total")
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.current, forKey: "current")
        aCoder.encode(self.total, forKey: "total")
    }
}
