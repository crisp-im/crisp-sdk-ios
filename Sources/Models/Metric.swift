//
//  Metric.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

class Metric: NSObject, NSCoding, Mappable {
    
    var count: Int32 = 0
    var last: Int32 = 0
    var mean: Int32 = 0

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        count          <- map["count"]
        last           <- (map["last"], TimestampMsToS)
        mean           <- map["mean"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.count = aDecoder.decodeInt32(forKey: "count")
        self.last = aDecoder.decodeInt32(forKey: "last")
        self.mean = aDecoder.decodeInt32(forKey: "mean")
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.count, forKey: "count")
        aCoder.encode(self.last, forKey: "last")
        aCoder.encode(self.mean, forKey: "mean")
    }
}
