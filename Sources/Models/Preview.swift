//
//  Preview.swift
//  Crisp
//
//  Created by Quentin de Quelen on 27/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class Preview: NSObject, NSCoding, Mappable {

    var url: String?                 = ""
    var website: String?             = ""
    var title: String?				= ""
    var previewExcerpt: String?      = ""
    var previewImage: String?		= ""
    var previewEmbed: String?		= ""
    var stamped: Bool				= false

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        url             <- map["url"]
        website         <- map["website"]
        title           <- map["title"]
        previewExcerpt  <- map["preview.excerpt"]
        previewImage    <- map["preview.image"]
        previewEmbed    <- map["preview.embed"]
        stamped         <- map["stamped"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.url = aDecoder.decodeObject(forKey: "url") as? String
        self.website = aDecoder.decodeObject(forKey: "website") as? String
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        self.previewExcerpt = aDecoder.decodeObject(forKey: "previewExcerpt") as? String
        self.previewImage = aDecoder.decodeObject(forKey: "previewImage") as? String
        self.previewEmbed = aDecoder.decodeObject(forKey: "previewEmbed") as? String
        self.stamped = aDecoder.decodeBool(forKey: "stamped")
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.website, forKey: "website")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.previewExcerpt, forKey: "previewExcerpt")
        aCoder.encode(self.previewImage, forKey: "previewImage")
        aCoder.encode(self.previewEmbed, forKey: "previewEmbed")
        aCoder.encode(self.stamped, forKey: "stamped")
    }
}
