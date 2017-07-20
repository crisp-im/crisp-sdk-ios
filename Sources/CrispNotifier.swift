//
//  NotifierHelper.swift
//  Crisp
//
//  Created by Quentin de Quelen on 28/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation

public class CrispNotifier: PublicNotifier, PrivateNotifier {
    
    /**
     
     Type of an notification
     
     - sessionLoaded
     - chatInitiated
     - messageSent
     - messageReceive
     - composeSent
     - composeReceive
     - chatOpened
     - chatClosed
     - userEmailChanged
     - userPhoneChanged
     - userNicknameChanged
     - userAvatarChanged

     */
    public enum Notification: String {
        
        // Handles the session loaded event
        case sessionLoaded   = "crisp:session:loaded"
        
        // Handles the chatbox initiated event, on the first time the user clicks on the chatbox
        case chatInitiated   = "crisp:chat:initiated"
        
        // Handles the message sent event
        case messageSent     = "crisp:message:sent"
        // Handles the message received event
        case messageReceive  = "crisp:message:received"
        // Handles the message compose sent event
        case composeSent     = "crisp:compose:sent"
        // Handles the message compose received event
        case composeReceive  = "crisp:compose:received"
        
        // Handles the chatbox opened event
        case chatOpened     = "crisp:chatbox:opened"
        // Handles the chatbox closed event
        case chatClosed    = "crisp:chatbox:closed"
        
        // Handles the user email changed event
        case userEmailChanged    = "crisp:user:email:changed"
        // Handles the user phone changed event
        case userPhoneChanged    = "crisp:user:phone:changed"
        // Handles the user nickname changed event
        case userNicknameChanged = "crisp:user:nickname:changed"
        // Handles the user avatar changed event
        case userAvatarChanged   = "crisp:user:avatar:changed"
        
        // Handles the website availability changed event
        case websiteAvailabilityChanged = "crisp:website:availability:changed"
    }
}

public protocol PublicNotifier {
    associatedtype Notification: RawRepresentable
}

public extension PublicNotifier where Notification.RawValue == String {
    /**
     
     - Parameter observer
     Object registering as an observer. This value must not be nil.
     - Parameter selector
     Selector that specifies the message the receiver sends observer to notify it of the notification posting. The method specified by aSelector must have one and only one argument (an instance of NSNotification).
     - Parameter notification
     The name of the notification for which to register the observer; that is, only notifications with this name are delivered to the observer.
     If you pass nil, the notification center doesn’t use a notification’s name to decide whether to deliver it to the observer.
     
     
     
     Receive the event `messageSent` and catch it on an handler. The data will be on the `notification.object`
     
     ## Exemple
     
     ```swift
     CrispNotifier.addObserver(observer: self, selector: #selector(crispMessageSent), notification: CrispNotifier.Notification.messageSent)
     
     @objc func crispMessageSent(_ notification: NSNotification) {
         let message = notification.object as? String
         print(message)
     }
     ```
     
     ## More 
        NotificationCenter.default.addObserver
     
    */
    public static func addObserver(observer: AnyObject, selector: Selector, notification: Notification) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: notification.rawValue), object: nil)
    }
    
    /**
     
     - Parameter observer
     Observer to remove from the dispatch table. Specify an observer to remove only entries for this observer. Must not be nil, or message will have no effect.
     
     - Parameter notification
     Name of the notification to remove from dispatch table. Specify a notification name to remove only entries that specify this notification name. When nil, the receiver does not use notification names as criteria for removal.
     
     
     
     Remove the notification handler for the event `messageSent`.
     
     ## Exemple
     
     ```swift
     CrispNotifier.removeObserver(observer: self, notification: CrispNotifier.Notification.messageSent)
     ```
     
     ## More
     NotificationCenter.default.removeObserver
     
     */
    public static func removeObserver(observer: AnyObject, notification: Notification) {
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: notification.rawValue), object: nil)
    }
}


protocol PrivateNotifier {
    associatedtype Notification: RawRepresentable
}

extension PrivateNotifier where Notification.RawValue == String {
    
    static func post(_ notification: String, object: AnyObject? = nil) {
        Self.postNotification(notification: notification, object: object)
    }
    
    static func post(_ notification: String, object: AnyObject? = nil, userInfo: [String : AnyObject]? = nil) {
        Self.postNotification(notification: notification, object: object, userInfo: userInfo)
    }
    
    static func postNotification(notification: String, object: AnyObject? = nil, userInfo: [String : AnyObject]? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notification), object: object, userInfo: userInfo)
    }
}
