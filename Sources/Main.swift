//
//  Main.swift
//  Crisp
//
//  Created by Quentin de Quelen on 12/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import UIKit
import EasyTipView

public let Crisp: CrispMain = CrispMain()

open class CrispMain: NSObject {

    var websiteId: String!

    public var chat         = sharedChatbox
    public var preferences  = sharedPreferences
    public var session      = SessionInterface()
    public var user         = UserInterface()
    public var message      = MessageInterface()

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
    public func initialize(websiteId: String) {
        System.log("crisp start initalized", type: .verbose)
        
        self.websiteId = websiteId
        if websiteId != LocalStore().websiteId.get() {
            UserDefaults.standard.set(nil, forKey: "CrispSession")
            UserDefaults.standard.set(nil, forKey: "CrispMessages")
            UserDefaults.standard.set("", forKey: "CrispSDKSessionId")
        }
        LocalStore().websiteId.set(websiteId)
        self.chat = ChatBox()
        generateGlobalConfig()

        sharedNetwork.connect()
        System.log("crisp is initalized", type: .verbose)
    }

    // MARK: Private functions

    private func generateGlobalConfig() {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = .systemFont(ofSize: 13)
        preferences.drawing.foregroundColor = .white
        preferences.drawing.backgroundColor = .black
        EasyTipView.globalPreferences = preferences
    }

}

public class SessionInterface {
    
    // MARK: Session Setter
    
    /**
     
     - parameter segment: an unique of segment
     
     Replace existing crisp segments by new one
     
     # Exemple
     
     ```
     Crisp.user.set(segment: "pro")
     ```
     */
    public func set(segment: String) {
        sharedStore.session?.segments = [segment]
        sharedNetwork.sessionSetSegments(segments: [segment])
    }
    
    /**
     
     - parameter segment: an array of segment
     
     Replace existing crisp segments by news
     
     # Exemple
     
     ```
     Crisp.user.set(segments: ["paid", "pro"])
     ```
     */
    public func set(segments: [String]) {
        sharedStore.session?.segments = segments
        sharedNetwork.sessionSetSegments(segments: segments)
    }
    
    /**
     
     - parameter segment: an unique of segment
     
     Append an unique of segment to existing crisp segments
     
     # Exemple
     
     ```
     Crisp.user.append(segment: "paid")
     ```
     */
    public func append(segment: String) {
        var localSegments: Array<String>  = sharedStore.session?.segments ?? []
        localSegments.append(segment)
        let definitiveSegment = Array(Set(localSegments))
        
        guard sharedStore.session != nil else { return }
        sharedStore.session?.segments = definitiveSegment
        sharedNetwork.sessionSetSegments(segments: sharedStore.session!.segments)
    }
    
    /**
     
     - parameter segments: an array of segment
     
     Append an array of segment to existing crisp segments
     
     # Exemple
     
     ```
     Crisp.user.append(segments: ["paid", "pro"])
     ```
     */
    public func append(segments: [String]) {
        var localSegments: Array<String>  = sharedStore.session?.segments ?? []
        localSegments.append(contentsOf: segments)
        let definitiveSegment = Array(Set(localSegments))
        
        guard sharedStore.session != nil else { return }
        sharedStore.session?.segments = definitiveSegment
        sharedNetwork.sessionSetSegments(segments: sharedStore.session!.segments)
    }
    
    /**
     
     - parameter data: Key value for data, the value must be readable String/Int/Double/Float/Boolean
     
     Set the session data for given key, with a value (value must be either a string, boolean or number)
     
     # Exemple
     
     
     ```
     Crisp.user.set(data: ["paid_user":true])
     ```
     */
    public func set(data: [String:Any]) {
        sharedStore.session?.data = data
        sharedNetwork.sessionSetData(data: data)
    }
    
    /**
     
     - parameter data: Must be an String/Int/Double/Float/Boolean but nothing else
     - parameter forKey: The key to clasify the data
     
     Add the session data for given key, with a value (value must be either a string, boolean or number)
     
     # Exemple
     
     
     ```
     Crisp.user.append(data: true, forKey: "paid_user")
     ```
     */
    public func append(data: Any, forKey key: String) {
        guard sharedStore.session != nil else {return}
        guard sharedStore.session?.data != nil  else { return }
        
        guard sharedStore.session != nil else { return }
        sharedStore.session!.data![key] = data
        sharedNetwork.sessionSetData(data: sharedStore.session!.data!)
    }
    
    // MARK: Session Getter
    
    /**
     Returns the current session segments (or `nil` if not set)
     */
    public var segments: [String]? {
        return sharedStore.session?.segments
    }
    /**
      Returns the current session data
    */
    public var data: [String: Any]? {
        return sharedStore.session?.data
    }
    /**
     Returns the number of unread messages in chat
    */
    public var unread: Int {
        return sharedStore.unread
    }
    /**
     Returns the current session identifier (or `nil` if not yet loaded)
    */
    public var identifier: String? {
        return LocalStore().sessionId.get()
    }
}

public class UserInterface {
    
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
    public func set(email: String) {
        sharedStore.session?.email = email
        sharedNetwork.sessionSetEmail(email: email)
    }
    
    /**
     
     - parameter email: The user avatar
     
     Sets the user avatar (must be a valid avatar)
     
     # Exemple
     
     Set user avatar with
     
     ```
     Crisp.user.set(avatar: "http://your.website.com/user_id/size")
     ```
     */
    public func set(avatar: String) {
        sharedStore.session?.avatar = avatar
        sharedNetwork.sessionSetAvatar(avatar: avatar)
    }
    
    /**
     
     - parameter email: The user nickname
     
     Sets the user nickname
     
     # Exemple
     
     Set user nickname with
     
     ```
     Crisp.user.set(nickname: "Quentin de Quelen")
     ```
     */
    public func set(nickname: String) {
        sharedStore.session?.nickname = nickname
        sharedNetwork.sessionSetNickname(nickname: nickname)
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
    public func set(phone: String) {
        sharedStore.session?.phone = phone
        sharedNetwork.sessionSetPhone(phone: phone)
    }
    
    
    // MARK: User Getter
    
    /**
     Returns the user email (or `nil` if not set)
     */
    public var email: String? {
        return sharedStore.session?.email
    }
    
    /**
     Returns the user avatar (or `nil` if not set)
     */
    public var avatar: String? {
        return sharedStore.session?.avatar
    }
    
    /**
     Returns the user nickname (or `nil` if not set)
     */
    public var nickname: String? {
        return sharedStore.session?.nickname
    }
    
    /**
     Returns the user phone (or `nil` if not set)
     */
    public var phone: String? {
        return sharedStore.session?.phone
    }
    
    
}

public class MessageInterface {
    
    // MARK: Message Setter
    
    /**
     
     - parameter text: The text to pre-fill
     
     Pre-fill the current message text in the chatbox
     
     # Exemple
     
        Set a prefilled chatbox input message with 
     
     ```
     Crisp.message.set(text: "Hi! I'd like to get help.")
     ```
     
     */
    public func set(text: String) {
        CrispNotifier.post(.eventChangeInputText, object: text as AnyObject)
    }
    
    // MARK: Message Getter
    
    /**
     Returns the current message text entered in the chatbox but not yet sent
     */
    public var text: String {
        return LocalStore().sessionId.get() ?? ""
    }
}
