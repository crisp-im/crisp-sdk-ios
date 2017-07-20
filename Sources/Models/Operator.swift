//
//  Operator.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class Operator: NSObject, NSCoding, Mappable {
    var avatar: String? = nil
    var nickname: String = ""
    var timestamp: Int32 = 0
    var userId: String = ""

    override init() {
        super.init()
    }
    
    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        avatar          <- map["avatar"]
        nickname        <- map["nickname"]
        timestamp       <- (map["timestamp"], TimestampMsToS)
        userId          <- map["user_id"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        self.nickname = aDecoder.decodeObject(forKey: "nickname") as! String
        self.timestamp = aDecoder.decodeInt32(forKey: "timestamp")
        self.userId = aDecoder.decodeObject(forKey: "userId") as! String
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.avatar, forKey: "avatar")
        aCoder.encode(self.nickname, forKey: "nickname")
        aCoder.encode(self.timestamp, forKey: "timestamp")
        aCoder.encode(self.userId, forKey: "userId")
    }
}
