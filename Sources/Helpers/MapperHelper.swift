//
//  MapperHelper.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

let TimestampMsToS = TransformOf<Int32, Int64>(fromJSON: { (value: Int64?) -> Int32? in
    return value! > 140000000 ? Int32(value! / 1000) : Int32(value!)
}, toJSON: { (value: Int32?) ->  Int64? in
    if let value = value {
        return value > 140000000 ? Int64(value) : Int64(value * 1000)
    }
    return nil
})




class DateTransform: TransformType {
    typealias Object = Date
    typealias JSON = Double
    
    init() {}
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        if let timeInt = value as? Double {
            return Date(timeIntervalSince1970: TimeInterval(timeInt / 1000))
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> Double? {
        if let date = value {
            return Double(date.timeIntervalSince1970 * 1000)
        }
        return nil
    }
}
