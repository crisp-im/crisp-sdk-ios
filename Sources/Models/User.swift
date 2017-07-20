//
//  User.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class User: NSObject, NSCoding, Mappable {
    
    var avatar: String? = nil
    var nickname: String = ""
    var email: String? = nil
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
        email           <- map["email"]
        userId          <- map["user_id"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        self.nickname = aDecoder.decodeObject(forKey: "nickname") as! String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.userId = aDecoder.decodeObject(forKey: "userId") as! String
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.avatar, forKey: "avatar")
        aCoder.encode(self.nickname, forKey: "nickname")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.userId, forKey: "userId")
    }
}
