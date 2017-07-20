//
//  Compose.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

/**

 Type of an compose message

 - start: The user is composing a message
 - stop: The user stop to compose or have remove his message

 */
enum ComposeType: String {
    case start = "start"
    case stop = "stop"
}

class Compose: NSObject, NSCoding, Mappable {

    var sessionId: String       = ""
    var excerpt: String         = ""
    var timestamp: Date         = Date()
    var type: ComposeType       = .stop
    var user: User?             = nil

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        sessionId		<- map["session_id"]
        excerpt			<- map["excerpt"]
        timestamp		<- (map["timestamp"], DateTransform())
        type            <- (map["type"], EnumTransform<ComposeType>())
        user            <- map["user"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.sessionId = aDecoder.decodeObject(forKey: "sessionId") as! String
        self.excerpt = aDecoder.decodeObject(forKey: "excerpt") as! String
        self.timestamp = aDecoder.decodeObject(forKey: "timestamp") as! Date
        self.type = ComposeType(rawValue: aDecoder.decodeObject(forKey: "type") as! String)!
        self.user = aDecoder.decodeObject(forKey: "user") as? User
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.sessionId, forKey: "sessionId")
        aCoder.encode(self.excerpt, forKey: "excerpt")
        aCoder.encode(self.timestamp, forKey: "timestamp")
        aCoder.encode(self.type.rawValue, forKey: "type")
        aCoder.encode(self.user, forKey: "user")
    }
}
