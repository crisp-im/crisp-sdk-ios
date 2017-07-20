//
//  Storage.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class Storage: NSObject, NSCoding, Mappable {

    var message: [Message] = []
    var state: State? = nil

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        message     <- map["message"]
        state       <- map["state"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.message = aDecoder.decodeObject(forKey: "message") as! [Message]
        self.state = aDecoder.decodeObject(forKey: "state") as? State
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.message, forKey: "message")
        aCoder.encode(self.state, forKey: "state")
    }
}
