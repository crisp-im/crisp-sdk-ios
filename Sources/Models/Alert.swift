//
//  Alert.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

enum AlertState: String {
    case lock = "lock"
    case hide = "hide"
    case show = "show"
}

class Alert: NSObject, NSCoding, Mappable {

    var emailForm: AlertState?
    var newMessage: AlertState?
    var waitReply: AlertState?
    var warnReply: AlertState?

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        emailForm       <- (map["email_form"], EnumTransform<AlertState>())
        newMessage      <- (map["new_messages"], EnumTransform<AlertState>())
        waitReply       <- (map["wait_reply"], EnumTransform<AlertState>())
        warnReply       <- (map["warn_reply"], EnumTransform<AlertState>())
    }

    required init?(coder aDecoder: NSCoder) {
        self.emailForm = aDecoder.decodeObject(forKey: "emailForm") as? AlertState
        self.newMessage = aDecoder.decodeObject(forKey: "newMessage") as? AlertState
        self.waitReply = aDecoder.decodeObject(forKey: "waitReply") as? AlertState
        self.warnReply = aDecoder.decodeObject(forKey: "warnReply") as? AlertState
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.emailForm, forKey: "emailForm")
        aCoder.encode(self.newMessage, forKey: "newMessage")
        aCoder.encode(self.waitReply, forKey: "waitReply")
        aCoder.encode(self.warnReply, forKey: "warnReply")
    }
}
