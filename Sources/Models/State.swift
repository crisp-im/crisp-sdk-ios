//
//  State.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class State: NSObject, NSCoding, Mappable {

//    var alert: Alert? = nil
    var maximized: Bool = false
    var `operator`: Operator? = nil
    var scroll: Int = 0
    var textarea: String = ""
    var triggers: [String] = []

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
//        alert       <- map["alert"]
        maximized   <- map["maximized"]
        `operator`   <- map["operator"]
        scroll      <- map["scroll"]
        textarea   <- map["textarea"]
        triggers   <- map["triggers"]
    }

    required init?(coder aDecoder: NSCoder) {
//        self.alert = aDecoder.decodeObject(forKey: "alert") as? Alert
        self.maximized = aDecoder.decodeBool(forKey: "maximized")
        self.`operator` = aDecoder.decodeObject(forKey: "operator") as? Operator
        self.scroll = aDecoder.decodeInteger(forKey: "scroll")
        self.textarea = aDecoder.decodeObject(forKey: "textarea") as! String
        self.triggers = aDecoder.decodeObject(forKey: "triggers") as! [String]
        super.init()
    }

    func encode(with aCoder: NSCoder) {
//        aCoder.encode(self.alert, forKey: "alert")
        aCoder.encode(self.maximized, forKey: "maximized")
        aCoder.encode(self.`operator`, forKey: "operator")
        aCoder.encode(self.scroll, forKey: "scroll")
        aCoder.encode(self.textarea, forKey: "textarea")
        aCoder.encode(self.triggers, forKey: "triggers")
    }
}
