//
//  Main.swift
//  Crisp
//
//  Created by Baptiste Jamin on 29/12/2017.
//  Copyright © 2017 crisp.im. All rights reserved.
//

import Foundation

public let Crisp: CrispMain = CrispMain()

@objc open class CrispMain: NSObject {
    
    var websiteId: String!
    var tokenId: String!
    
    public var session      = SessionInterface()
    public var user         = UserInterface()
    
    // MARK: Public functions
    /**
     
     - parameter websiteId: Your website_ID (should be valid)
     
     Initiate the crisp SDK. Should be the first call of crisp in the app. Place it on the AppDelegate
     
     Warning: If the websiteID is not valid the app will crash
     
     # Exemple
     
     ```
     Crisp.initialize(websiteId: "c46126bf-9865-4cd1-82ee-dbe93bd42485")
     ```
     */
    @objc public func initialize(websiteId: String) {
        self.websiteId = websiteId
        self.tokenId = ""
    }    
}

@objc public class SessionInterface : NSObject {
    
    // MARK: Session Setter
    
    /**
     
     - parameter segment: an unique of segment
     
     Replace existing crisp segments by new one
     
     # Exemple
     
     ```
     Crisp.user.set(segment: "pro")
     ```
     */
    @objc public func set(segment: String) {
        CrispView.execute(script: "window.$crisp.push([\"set\", \"session:segments\", [[\"" + segment + "\"]]])");
    }
    
    /**
     
     - parameter data: Key value for data, the value must be readable String/Int/Double/Float/Boolean
     
     Set the session data for given key, with a value (value must be either a string, boolean or number)
     
     # Exemple
     
     
     ```
     Crisp.user.set(data: ["paid_user":true])
     ```
     */
    @objc public func set(data: [String:Any]) {
        do {
            var pendingData = "";
            for (key, value) in data {
                pendingData = "\(pendingData)['\(key)','\(value)']"
            }
            
            CrispView.execute(script: "window.$crisp.push([\"set\", \"session:data\", [["+pendingData+"]]])")
        } catch {
        }
    }
    
    /**
     
     Resets the user session
     */
    @objc public func reset() {
        CrispView.execute(script: "window.$crisp.push([\"do\", \"session:reset\", [true]])");
        CrispView.isLoaded = false
        CrispView._load()
    }
}

@objc public class UserInterface : NSObject {
    
    // MARK: User Setter
    
    /**
     
     - parameter email: The user email
     
     Sets the user email (must be a valid email)
     
     # Exemple
     
     Set user email with
     
     ```
     Crisp.user.set(email: "quentin@crisp.chat")
     ```
     */
    @objc public func set(email: String) {
        CrispView.execute(script: "window.$crisp.push([\"set\", \"user:email\", [\"" + email + "\"]])")
    }
    
    /**
     
     - parameter email: The user avatar
     
     Sets the user avatar (must be a valid avatar)
     
     # Exemple
     
     Set user avatar with
     
     ```
     Crisp.user.set(avatar: "http://your.website.com/avatar.png")
     ```
     */
    @objc public func set(avatar: String) {
        CrispView.execute(script: "window.$crisp.push([\"set\", \"user:avatar\", [\"" + avatar + "\"]])");
    }
    
    /**
     
     - parameter email: The user nickname
     
     Sets the user nickname
     
     # Exemple
     
     Set user nickname with
     
     ```
     Crisp.user.set(nickname: "John Doe")
     ```
     */
    @objc public func set(nickname: String) {
        CrispView.execute(script: "window.$crisp.push([\"set\", \"user:nickname\", [\"" + nickname + "\"]])")
    }
    
    /**
     
     - parameter email: The user phone
     
     Sets the user phone (must be a valid phone)
     
     # Exemple
     
     Set user phone with
     
     ```
     Crisp.user.set(phone: "+33645XXXXXX")
     ```
     */
    @objc public func set(phone: String) {
        CrispView.execute(script: "window.$crisp.push([\"set\", \"user:phone\", [\"" + phone + "\"]])");
    }
}
