//
//  Message.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

/**

 Type of an message

 - text: The normal text or markdown
 - file: can be an image or a file
 - animation: An usual Gif

 */
enum MessageType: String {
    case text       = "text"
    case file       = "file"
    case animation  = "animation"
}

enum MessageFrom: String {
    case user       = "user"
    case operators  = "operator"
}

enum MessageOrigin: String {
    case diff       = "diff"
    case network    = "network"
}

class Message: NSObject, NSCoding, Mappable {

    var isMe: Bool = false
    var contentString: String? = "" {
        didSet {
            let md = SwiftyMarkdown(string: contentString!)
            contentAttributedString = Smiley.replace(md.attributedString())
        }
    }
    var contentAttributedString: NSAttributedString? = nil
    var contentObject: MessageContent? = nil
    var fingerprint: Int = Int(1_000_000_000 - arc4random_uniform(100_000_000 - 1))
    var websiteId: String? = LocalStore().websiteId.get() ?? ""
    var sessionId: String? = LocalStore().sessionId.get() ?? ""
    var timestamp: Date = Date()
    var user: User? = nil

    var index: Index? = nil
    var mentions: [String] = []
    var preview: [Preview] = []

    var read: Bool = false
    var stamped: Bool = false
    var error: Bool = false

    var type: MessageType = .text
    var from: MessageFrom = .user
    var origin: MessageOrigin = .network
    
    
    private var height: CGFloat? = nil

    override init() {
        super.init()
        checkRecepetion()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    public func mapping(map: Map) {
        fingerprint         <- map["fingerprint"]
        index               <- map["index"]
        mentions            <- map["mentions"]
        websiteId            <- map["website_id"]
        sessionId            <- map["session_id"]
        read                <- map["read"]
        stamped            <- map["stamped"]
        timestamp           <- (map["timestamp"], DateTransform())
        user                <- map["user"]
        type                <- (map["type"], EnumTransform<MessageType>())
        from                <- (map["from"], EnumTransform<MessageFrom>())
        origin              <- (map["origin"], EnumTransform<MessageOrigin>())
        preview             <- map["preview"]
        isMe                <- map["is_me"]

        if type == .text {
            contentString   <- map["content"]
        } else {
            contentObject   <- map["content"]
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.isMe = aDecoder.decodeBool(forKey: "isMe")
        self.contentAttributedString = aDecoder.decodeObject(forKey: "contentAttributedString") as? NSAttributedString
        self.contentObject = aDecoder.decodeObject(forKey: "contentObject") as? MessageContent
        self.fingerprint = aDecoder.decodeInteger(forKey: "fingerprint")
        self.websiteId = aDecoder.decodeObject(forKey: "websiteId") as? String
        self.sessionId = aDecoder.decodeObject(forKey: "sessionId") as? String
        self.timestamp = aDecoder.decodeObject(forKey: "timestamp") as! Date
        self.user = aDecoder.decodeObject(forKey: "user") as? User
        self.index = aDecoder.decodeObject(forKey: "index") as? Index
        self.mentions = aDecoder.decodeObject(forKey: "mentions") as! [String]
        self.preview = aDecoder.decodeObject(forKey: "preview") as! [Preview]
        self.read = aDecoder.decodeBool(forKey: "read")
        self.stamped = aDecoder.decodeBool(forKey: "stamped")
        self.type = MessageType(rawValue: aDecoder.decodeObject(forKey: "type") as! String)!
        self.from = MessageFrom(rawValue: aDecoder.decodeObject(forKey: "from") as! String)!
        self.origin = MessageOrigin(rawValue: aDecoder.decodeObject(forKey: "origin") as! String)!
        
        if self.stamped == false, self.read == false {
            self.error = true
        }
        
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.isMe, forKey: "isMe")
        aCoder.encode(self.contentAttributedString, forKey: "contentAttributedString")
        aCoder.encode(self.contentObject, forKey: "contentObject")
        aCoder.encode(self.fingerprint, forKey: "fingerprint")
        aCoder.encode(self.websiteId, forKey: "websiteId")
        aCoder.encode(self.sessionId, forKey: "sessionId")
        aCoder.encode(self.timestamp, forKey: "timestamp")
        aCoder.encode(self.user, forKey: "user")
        aCoder.encode(self.index, forKey: "index")
        aCoder.encode(self.mentions, forKey: "mentions")
        aCoder.encode(self.preview, forKey: "preview")
        aCoder.encode(self.read, forKey: "read")
        aCoder.encode(self.stamped, forKey: "stamped")
        aCoder.encode(self.type.rawValue, forKey: "type")
        aCoder.encode(self.from.rawValue, forKey: "from")
        aCoder.encode(self.origin.rawValue, forKey: "origin")
    }
    
    func getHeight() -> CGFloat {
        guard height == nil else { return height! }
        if type == .text {
            if (preview.startIndex != preview.endIndex) {
                return getLinkBubbleHeight()
            } else {
                return getTextBubbleHeight()
            }
        } else if type == .animation {
            return getImageBubbleHeight()
        } else if type == .file {
            if contentObject?.type?.range(of: "image") != nil {
                return getImageBubbleHeight()
            } else {
                return getFileBubbleHeight()
            }
        }
        return 0.0
    }
    
    private func getLinkBubbleHeight() -> CGFloat {
        let _height = contentAttributedString!.height(withConstrainedWidth: UIScreen.main.bounds.width - 110) + 20 + 34
        height = _height
        return _height
    }
    
    private func getTextBubbleHeight() -> CGFloat {
        let _height = contentAttributedString!.height(withConstrainedWidth: UIScreen.main.bounds.width - 110) + 20
        height = _height
        return _height
    }
    
    private func getImageBubbleHeight() -> CGFloat {
        let _height: CGFloat = 150.0
        height = _height
        return _height
    }
    
    private func getFileBubbleHeight() -> CGFloat {
        let _height = contentObject!.name!.height(withConstrainedWidth: UIScreen.main.bounds.width - 110, font: UIFont.systemFont(ofSize: 14)) + 20 + 34
        height = _height
        return _height
    }
    
    func checkRecepetion() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if self.stamped == false && self.read == false {
                self.error = true
                sharedStore.messages.value[self.fingerprint] = self
            }
        }
    }
}

