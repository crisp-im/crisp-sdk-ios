//
//  Chatbox.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class Session: NSObject, NSCoding, Mappable {
    var activeOperators: [Operator] = []
    var avatar: String? = nil
    var avatarBuster: Int32 = 0
    var data: [String:Any]? = [:]
    var domain: String = ""
    var lastActive: Int32 = 0

    var nickname: String = ""
    var phone: String? = nil
    var email: String? = nil

    var plugins: [Plugin] = []
    var responseMetrics: Metric? = nil
    var segments: [String] = []
    var sessionId: String = ""
    var settings: Setting? = nil
    var storage: Storage? = nil
    var sync: Sync? = nil
    var usersAvailable: Bool = false
    var website: String = ""

    // MARK: ObjectMapper

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        activeOperators      <- map["active_operators"]
        avatar              <- map["avatar"]
        avatarBuster        <- (map["avatar_buster"], TimestampMsToS)
        data                <- map["data"]
        domain              <- map["domain"]
        lastActive          <- (map["last_active"], TimestampMsToS)
        nickname            <- map["nickname"]
        phone               <- map["phone"]
        email               <- map["email"]
        plugins             <- map["plugins"]
        responseMetrics     <- map["response_metrics"]
        segments            <- map["segments"]
        sessionId           <- map["session_id"]
        settings            <- map["settings"]
        storage             <- map["storage"]
        sync                <- map["sync"]
        usersAvailable       <- map["users_available"]
        website             <- map["website"]
    }

    // MARK: NSCoding

    required init?(coder aDecoder: NSCoder) {
        self.activeOperators = aDecoder.decodeObject(forKey: "activeOperators") as! [Operator]
        self.avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        self.avatarBuster = aDecoder.decodeInt32(forKey: "avatarBuster")
        self.data = aDecoder.decodeObject(forKey: "data") as? [String : Any]
        self.domain = aDecoder.decodeObject(forKey: "domain") as! String
        self.lastActive = aDecoder.decodeInt32(forKey: "lastActive")
        self.nickname = aDecoder.decodeObject(forKey: "nickname") as! String
        self.phone = aDecoder.decodeObject(forKey: "phone") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.plugins = aDecoder.decodeObject(forKey: "plugins") as! [Plugin]
        self.responseMetrics = aDecoder.decodeObject(forKey: "responseMetrics") as? Metric
        self.segments = aDecoder.decodeObject(forKey: "segments") as! [String]
        self.sessionId = aDecoder.decodeObject(forKey: "sessionId") as! String
        self.settings = aDecoder.decodeObject(forKey: "settings") as? Setting
        self.storage = aDecoder.decodeObject(forKey: "storage") as? Storage
        self.sync = aDecoder.decodeObject(forKey: "sync") as? Sync
        self.usersAvailable = aDecoder.decodeBool(forKey: "usersAvailable")
        self.website = aDecoder.decodeObject(forKey: "website") as! String

        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.activeOperators, forKey: "activeOperators")
        aCoder.encode(self.avatar, forKey: "avatar")
        aCoder.encode(self.avatarBuster, forKey: "avatarBuster")
        aCoder.encode(self.data, forKey: "data")
        aCoder.encode(self.domain, forKey: "domain")
        aCoder.encode(self.lastActive, forKey: "lastActive")
        aCoder.encode(self.nickname, forKey: "nickname")
        aCoder.encode(self.phone, forKey: "phone")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.plugins, forKey: "plugins")
        aCoder.encode(self.responseMetrics, forKey: "responseMetrics")
        aCoder.encode(self.segments, forKey: "segments")
        aCoder.encode(self.sessionId, forKey: "sessionId")
        aCoder.encode(self.settings, forKey: "settings")
        aCoder.encode(self.storage, forKey: "storage")
        aCoder.encode(self.sync, forKey: "sync")
        aCoder.encode(self.usersAvailable, forKey: "usersAvailable")
        aCoder.encode(self.website, forKey: "website")
    }
}
