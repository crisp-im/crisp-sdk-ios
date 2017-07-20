//
//  TimeZone.swift
//  Crisp
//
//  Created by Quentin de Quelen on 12/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import UIKit

class Timezone {
    var current: Int {
        get {
            return TimeZone.current.secondsFromGMT() / 60
        }
    }
}

class Locales {
    var current: [String] {
        get {
            return NSLocale.preferredLanguages
        }
    }
}

class UserAgent {
    var current: String {
        get {
            return "\(UIDevice.current.model) \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        }
    }
}
