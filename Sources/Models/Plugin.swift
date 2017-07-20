//
//  Plugin.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class Plugin: NSObject, NSCoding, Mappable {
    var customization: [String : AnyObject] = [:]
    var debranding: [String : AnyObject] = [:]
    var triggers: [String : AnyObject] = [:]

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        customization    <- map["urn:crisp.chat:customization:0"]
        debranding      <- map["urn:crisp.chat:debranding:0"]
        triggers        <- map["urn:crisp.chat:triggers:0"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.customization = aDecoder.decodeObject(forKey: "customization") as! [String : AnyObject]
        self.debranding = aDecoder.decodeObject(forKey: "debranding") as! [String : AnyObject]
        self.triggers = aDecoder.decodeObject(forKey: "triggers") as! [String : AnyObject]
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.customization, forKey: "customization")
        aCoder.encode(self.debranding, forKey: "debranding")
        aCoder.encode(self.triggers, forKey: "triggers")
    }
}
