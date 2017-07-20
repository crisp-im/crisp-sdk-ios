//
//  Network+In.swift
//  Crisp
//
//  Created by Quentin de Quelen on 17/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftEventBus

extension Network {
    /**
     
     Socket ⬅️ (In)
     
     Handles session created event
     
     Should add on LocalStore the sessionId
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func sessionCreated(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("Session is created", type: .socketIn, String(describing: dataArray!))
        if let _s = (dataArray?[0] as! [String:Any])["session_id"] {
            LocalStore().sessionId.set(_s as! String)
            joinSession(sessionId: _s as! String)
        }
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles session joined event
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func sessionJoined(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("session is joined", type: .socketIn, String(describing: dataArray!))
        let session: Session = Session(JSON: dataArray![0] as! [String: Any])!
        sharedStore.create(session: session)
        startHeartbeat()
        sessionDevice(referer: "", title: "", url: "")
        mediaAnimationList(page: 1)
        connected = true
        CrispNotifier.post(.eventSessionLoaded, object: session.sessionId as AnyObject)
        
        guard sharedStore.messages.value.count == 0  else { return }
        if let op = session.activeOperators.first {
            let user = User()
            user.avatar = op.avatar
            user.nickname = op.nickname
            user.userId = op.userId
            let message = Message()
            message.isMe = false
            message.user = user
            message.contentString = sharedPreferences.themeText
            sharedStore.add(message: message)
        }
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles session state
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func sessionState(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("session state have been changed", type: .socketIn, String(describing: dataArray!))
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles session error
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func sessionError(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("an error occured on session", type: .socketIn, String(describing: dataArray!))
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles session initiation request
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func sessionRequestInitiate(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("initiate is request", type: .socketIn, String(describing: dataArray!))
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles local storage synchronization with remote storage
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func storageSyncUpdated(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("sync remote storage", type: .socketIn, String(describing: dataArray!))
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles bucket upload URL generated
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func bucketUrlUploadGenerated(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("the url fot upload have been generated", type: .socketIn, String(describing: dataArray!))
        if let urls = (dataArray?[0] as! [String:Any])["url"] {
            if sharedStore.upload.value != nil {
                sharedStore.upload.value?.ressourceUrl = (urls as! [String:Any])["resource"] as! String
                sharedStore.upload.value?.signedUrl = (urls as! [String:Any])["signed"] as! String
            }
        }
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles media animations listed
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func mediaAnimationListed(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("list media aimation", type: .socketIn, String(describing: dataArray!))
        if let data = dataArray![0] as? [String: Any], let results = data["results"] as? [[String: Any]] {
            let urls = results.flatMap({ $0["url"] as? String })
            sharedStore.update(gifs: urls)
        }
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles message sent (visitor -> operator) feedback
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func messageSent(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("new message sent", type: .socketIn, String(describing: dataArray!))
        if let data = dataArray![0] as? [String: Any], let remoteMessage = Message(JSON: data) {
            storageSyncUpdate(withData: [data], type: remoteMessage.type == .file ? .file : .message)
            sharedStore.messages.value[remoteMessage.fingerprint]?.stamped = true
            SwiftEventBus.post(.eventMessageReceive, sender: remoteMessage.fingerprint)
        }
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles message received (operator -> visitor)
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func messageReceived(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("receive a new message", type: .socketIn, String(describing: dataArray!))
        if let remoteMessage = dataArray![0] as? [String: Any] {
            let message: Message = Message(JSON: remoteMessage)!
            message.isMe = false
            sharedStore.add(message: message)
            storageSyncUpdate(withData: [remoteMessage], type: .message)
            messageAcknowledgePending(fingerprints: [message.fingerprint])
            messageAcknowledgeDelivered(fingerprints: [message.fingerprint])
            SwiftEventBus.post(.eventMessageNew)
            CrispNotifier.post(.eventMessageReceive)
        }
        
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles message pending (visitor -> operator) acknowledgement
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func messageAcknowledgePending(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("(visitor -> operator) receive a pending ack", type: .socketIn, String(describing: dataArray!))
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles sent (visitor -> operator) message read acknowledgement
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func messageAcknowledgeReadSend(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("(visitor -> operator) receive an read send", type: .socketIn, String(describing: dataArray!))
        if let data = dataArray![0] as? [String: Any], let fingerprints: [Int] = data["fingerprints"] as? [Int] {
            for _f in fingerprints {
                sharedStore.messages.value[_f]?.read = true
                if let message = sharedStore.messages.value[_f]?.toJSON() {
                    storageSyncUpdate(withData: [message], type: .message)
                }
                SwiftEventBus.post(.eventMessageRead, sender: _f)
            }
        }
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles received (operator -> visitor) message read acknowledgement
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func messageAcknowledgeReadReceived(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("(operator -> visitor) receive an read ack", type: .socketIn, String(describing: dataArray!))
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles received (operator -> visitor) compose message
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func messageComposeReceived(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("receive a new compose", type: .socketIn, String(describing: dataArray!))
        if let data = dataArray![0] as? [String: Any], let type: String = data["type"] as? String {
            sharedStore.update(compose: type == "start" ? true : false)
            CrispNotifier.post(.eventComposeReceive)
        }
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles a locally received message (serves as a way to sync. messages across tabs for current session)
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func messageReceivedLocal(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("receive a new local message", type: .socketIn, String(describing: dataArray!))
    }
    
    /**
     
     Socket ⬅️ (In)
     
     
     Handles website online/away availability change
     
     - Parameter dataArray: The content of the message
     - Parameter socketAck: The ack object
     
     */
    func websiteUsersAvailable(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("user availability have changed", type: .socketIn, String(describing: dataArray!))
        if let data = dataArray![0] as? Bool {
            sharedStore.session?.usersAvailable = data
            SwiftEventBus.post(.eventWebsiteAvailabilityChanged)
            CrispNotifier.post(.eventWebsiteAvailabilityChanged, object: data as AnyObject)
        }
    }
}
