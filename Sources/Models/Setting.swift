//
//  Setting.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper

enum ColorTheme: String {
    case blue = "blue"
}

class Setting: NSObject, NSCoding, Mappable {

    var activityMetrics: Bool = false
    var availabilityTooltip: Bool = false
    var blockedLocales: [String] = []
    var blockedPages: [String] = []
    var checkDomain: Bool = false
    var colorTheme: ColorTheme = .blue
    var emailVisitor: Bool = false
    var forceIdentity: Bool = false
    var hideOnAway: Bool = false
    var ignorePrivacy: Bool = false
    var lastOperatorFace: Bool = false
    var locale: String = ""
    var logo: String = ""
    var positionReverse: Bool = false
    var rating: Bool = true
    var textTheme: String = "default"
    var tile: String = ""
    var transcript: Bool = false
    var welcomeMessage: String = "default"

    override init() {
        super.init()
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        activityMetrics     <- map["activity_metrics"]
        availabilityTooltip <- map["availability_tooltip"]
        blockedLocales      <- map["blocked_locales"]
        blockedPages        <- map["blocked_pages"]
        checkDomain         <- map["check_domain"]
        colorTheme          <- (map["color_theme"], EnumTransform<ColorTheme>())
        emailVisitor        <- map["email_visitors"]
        forceIdentity       <- map["force_identify"]
        hideOnAway          <- map["hide_on_away"]
        ignorePrivacy       <- map["ignore_privacy"]
        lastOperatorFace     <- map["last_operator_face"]
        locale              <- map["locale"]
        logo                <- map["logo"]
        positionReverse     <- map["position_reverse"]
        rating              <- map["rating"]
        textTheme           <- map["text_theme"]
        tile                <- map["tile"]
        transcript          <- map["transcript"]
        welcomeMessage      <- map["welcome_message"]
    }

    required init?(coder aDecoder: NSCoder) {
        self.activityMetrics = aDecoder.decodeBool(forKey: "activityMetrics")
        self.availabilityTooltip = aDecoder.decodeBool(forKey: "availabilityTooltip")
        self.blockedLocales = aDecoder.decodeObject(forKey: "blockedLocales") as! [String]
        self.blockedPages = aDecoder.decodeObject(forKey: "blockedPages") as! [String]
        self.checkDomain = aDecoder.decodeBool(forKey: "checkDomain")
        self.colorTheme = ColorTheme(rawValue: aDecoder.decodeObject(forKey: "colorTheme") as! String)!
        self.emailVisitor = aDecoder.decodeBool(forKey: "emailVisitor")
        self.forceIdentity = aDecoder.decodeBool(forKey: "forceIdentity")
        self.hideOnAway = aDecoder.decodeBool(forKey: "hideOnAway")
        self.ignorePrivacy = aDecoder.decodeBool(forKey: "ignorePrivacy")
        self.lastOperatorFace = aDecoder.decodeBool(forKey: "lastOperatorFace")
        self.locale = aDecoder.decodeObject(forKey: "locale") as! String
        self.logo = aDecoder.decodeObject(forKey: "logo") as! String
        self.positionReverse = aDecoder.decodeBool(forKey: "positionReverse")
        self.rating = aDecoder.decodeBool(forKey: "rating")
        self.textTheme = aDecoder.decodeObject(forKey: "textTheme") as! String
        self.tile = aDecoder.decodeObject(forKey: "tile") as! String
        self.transcript = aDecoder.decodeBool(forKey: "transcript")
        self.welcomeMessage = aDecoder.decodeObject(forKey: "welcomeMessage") as! String
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.activityMetrics, forKey: "activityMetrics")
        aCoder.encode(self.availabilityTooltip, forKey: "availabilityTooltip")
        aCoder.encode(self.blockedLocales, forKey: "blockedLocales")
        aCoder.encode(self.blockedPages, forKey: "blockedPages")
        aCoder.encode(self.checkDomain, forKey: "checkDomain")
        aCoder.encode(self.colorTheme.rawValue, forKey: "colorTheme")
        aCoder.encode(self.emailVisitor, forKey: "emailVisitor")
        aCoder.encode(self.forceIdentity, forKey: "forceIdentity")
        aCoder.encode(self.hideOnAway, forKey: "hideOnAway")
        aCoder.encode(self.ignorePrivacy, forKey: "ignorePrivacy")
        aCoder.encode(self.lastOperatorFace, forKey: "lastOperatorFace")
        aCoder.encode(self.locale, forKey: "locale")
        aCoder.encode(self.logo, forKey: "logo")
        aCoder.encode(self.positionReverse, forKey: "positionReverse")
        aCoder.encode(self.rating, forKey: "rating")
        aCoder.encode(self.textTheme, forKey: "textTheme")
        aCoder.encode(self.tile, forKey: "tile")
        aCoder.encode(self.transcript, forKey: "transcript")
        aCoder.encode(self.welcomeMessage, forKey: "welcomeMessage")
    }
}
