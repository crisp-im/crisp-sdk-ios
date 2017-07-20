//
//  Network+Out.swift
//  Crisp
//
//  Created by Quentin de Quelen on 17/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import Alamofire
import SwiftEventBus

enum StorageSyncType: String {
    case message = "message"
    case file = "file"
}

extension Network {
    
    /**
     
     Socket ➡️ (Out)
     
     Emits a session create payload (create from void)
     
     Exemple:
     
     ```
     {
     "locales": [
     "en-US",
     "en"
     ],
     "timezone": -120,
     "useragent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3033.0 Safari/537.36",
     "website_domain": "client.crisp.chat.dev",
     "website_id": "04ed9a29-ccda-4f46-b2f3-b151d2d90fa7"
     }
     ```
     
     - Parameter locales: The supported Languages of the device (optional)
     - Parameter timezone: The current timezone in minutes (optional)
     - Parameter useragent: The devices informations concat on one string (optional)
     - Parameter websiteId: The actual websiteId
     
     */
    func createSession(
        locales: [String]? = Locales().current,
        timezone: Int? = Timezone().current,
        useragent: String? = UserAgent().current,
        websiteId: String)
        -> Void
    {
        
        let data: [String: Any] = [
            "locales": locales!,
            "timezone": timezone!,
            "useragent": useragent!,
            "website_id": websiteId
        ]
        System.log("createSession with data", type: .socketOut, data)
        socket?.emit("session:create", with: [data])
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Emits a session join payload (resume from local store)
     
     Exemple:
     
     ```
     {
     "expire": 180000,
     "locales": [
     "en-US",
     "en"
     ],
     "session_id": "session_f0fe20fb-dd63-4a40-8a9c-297771401494",
     "storage": true,
     "sync": false,
     "timezone": -120,
     "useragent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3033.0 Safari/537.36"
     }
     ```
     
     - Parameter locales: The supported Languages of the device (optional)
     - Parameter timezone: The current timezone in minutes (optional)
     - Parameter useragent: The devices informations concat on one string (optional)
     - Parameter sessionId: The actual sessionId
     - Parameter storage: ❌ (optional)
     - Parameter sync: ❌ (optional)
     
     */
    func joinSession(
        locales: [String]? = Locales().current,
        timezone: Int? = Timezone().current,
        useragent: String? = UserAgent().current,
        sessionId: String,
        storage: Bool? = true,
        sync: Bool? = true)
        -> Void
    {
        let data: [String: Any] = [
            "expire": 180000,
            "locales": locales!,
            "timezone": timezone!,
            "useragent": useragent!,
            "session_id": sessionId,
            "storage": storage!,
            "sync": sync!
        ]
        System.log("joinSession with data", type: .socketOut, data)
        socket?.emit("session:join", with: [data])
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Emits a session heartbeat payload (advertise as still online)
     
     Exemple:
     
     ```
     {
     "availability": {
     "time": {
     "for": 180000
     },
     "type": "online"
     },
     "last_active": 1492082174112
     }
     ```
     
     */
    func sessionHearhbeat() -> Void {
        let timestamp = NSDate().timeIntervalSince1970
        
        let data: [String: Any] = [
            "availability": [
                "time": [
                    "for": 180000
                ],
                "type": "online"
            ],
            "last_active": timestamp
        ]
        System.log("send heartbeat with data", type: .socketOut, data)
        socket?.emit("session:heartbeat", with: [data])
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Emits a session device payload
     
     Exemple:
     
     ```
     {
     "page_referrer": "http://client.crisp.chat.dev/test/",
     "page_title": "Crisp Client",
     "page_url": "http://client.crisp.chat.dev/test/"
     }
     
     ```
     
     - Parameter referer: The referer to the current view
     - Parameter title: The title to attribute to this view
     - Parameter url: The relative URL of the current view
     
     */
    func sessionDevice(referer: String, title: String, url: String) -> Void {
        let data: [String: Any] = [
            "page_referrer": referer,
            "page_title": title,
            "page_url": url
        ]
        System.log("session device with data", type: .socketOut, data)
        socket?.emit("session:device", with: [data])
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Sets session email
     
     Exemple:
     
     ```
     {
     "email": "quentin@crisp.chat"
     }
     ```
     
     - Parameter email: The visitor email
     
     */
    func sessionSetEmail(email: String) -> Void {
        let data: [String: Any] = [
            "email": email,
            ]
        
        System.log("email was set", type: .socketOut, data)
        emit("session:set_email", with: data)
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Sets session phone number
     
     Exemple:
     
     ```
     {
     "phone": "+33642926822"
     }
     ```
     
     - Parameter phone: The visitor phone number
     
     */
    func sessionSetPhone(phone: String) -> Void {
        let data: [String: Any] = [
            "phone": phone,
            ]
        
        System.log("Phone was set", type: .socketOut, data)
        emit("session:set_phone", with: data)
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Sets session nickname
     
     Exemple:
     
     ```
     {
     "nickname": "Quentin"
     }
     ```
     
     - Parameter nickname: The visitor nickname
     
     */
    func sessionSetNickname(nickname: String) -> Void {
        let data: [String: Any] = [
            "nickname": nickname,
            ]
        
        System.log("Nickname was set", type: .socketOut, data)
        emit("session:set_nickname", with: data)
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Sets session avatar
     
     Exemple:
     
     ```
     {
     "avatar": "http://plop.com/face.jpg"
     }
     ```
     
     - Parameter avatar: The visitor avatar
     
     */
    func sessionSetAvatar(avatar: String) -> Void {
        let data: [String: Any] = [
            "avatar": avatar,
            ]
        
        System.log("Avatar was set", type: .socketOut, data)
        emit("session:set_avatar", with: data)
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Sets session segments
     
     Exemple:
     
     ```
     {
     "segments": [
     "yo",
     "hey"
     ]
     }
     ```
     
     - Parameter segments: The segments to add on session
     
     */
    func sessionSetSegments(segments: [String]) -> Void {
        let data: [String: Any] = [
            "segments": segments,
            ]
        
        System.log("Segement was set", type: .socketOut, data)
        emit("session:set_segments", with: data)
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Sets session data
     
     Exemple:
     
     ```
     {
     "data": {
     "cool": "top"
     }
     }
     
     ```
     
     - Parameter data: The data to add on session
     
     */
    func sessionSetData(data: [String: Any]) -> Void {
        let data: [String: Any] = [
            "data": data,
            ]
        
        System.log("Data was set", type: .socketOut, data)
        emit("session:set_data", with: data)
    }
    
    // TODO: [session:state] Sets session state
    
    
    /**
     
     Socket ➡️ (Out)
     
     Sends a message
     
     Exemple:
     
     ```
     {
     "content": "ef",
     "fingerprint": 149208259913916,
     "origin": "chat",
     "timestamp": 1492082599139,
     "type": "text"
     }
     
     
     ```
     
     - Parameter message: The message to send
     
     */
    func messageSend(message: Message) -> Void {
        
        var data: [String: Any] = [
            "fingerprint": message.fingerprint,
            "origin": "chat",
            "timestamp": Int(message.timestamp.timeIntervalSince1970) * 1000,
            "type": message.type.rawValue
        ]
        
        if let content = message.contentObject {
            data["content"] = [
                "type": content.type ?? "",
                "name": content.name ?? "",
                "url": content.url ?? ""
                
            ]
        } else {
            data["content"] = message.contentString ?? ""
        }
        
        System.log("Message was sent", type: .socketOut, data)
        CrispNotifier.post(.eventMessageSent)
        socket?.emit("message:send", with: [data])
        sharedStore.backup()
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Propagates a locally received message (serves as a way to sync. messages across tabs/devices for current session)
     
     Exemple:
     
     ```
     {
     "content": "**Don't leave!** Try the chatbox and say hello \ud83d\ude18",
     "fingerprint": 149208287069440,
     "from": "operator",
     "origin": "local",
     "timestamp": 1492082870694,
     "type": "text",
     "user": {
     "nickname": "Quentin de Quelen",
     "source": "local",
     "user_id": "a4c32c68-be91-4e29-8a05-976e93abbe3f"
     }
     }
     ```
     
     - Parameter content: The content could be an image or a text
     - Parameter type: The type of the message
     - Parameter nickname: The user nickname
     - Parameter userId: The user identifier
     
     */
    func messageReceiveLocal(content: Any, type: MessageType, nickname: String, userId: String) -> Void {
        let timestamp = NSDate().timeIntervalSince1970
        let fingerprint = Int(1000000000 - arc4random_uniform(100000000 - 1))
        
        let data: [String: Any] = [
            "content": content,
            "fingerprint": fingerprint,
            "from": "operator",
            "origin": "local",
            "timestamp": timestamp * 1000,
            "type": type.rawValue,
            "user": [
                "nickname": nickname,
                "source": "local",
                "user_id": userId
            ]
        ]
        
        System.log("Local message was sent", type: .socketOut, data)
        socket?.emit("message:received:local", with: [data])
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Acknowledges a message as pending
     
     Exemple:
     
     ```
     {
     "fingerprints": [
     149208287069440
     ],
     "origin": "chat"
     }
     ```
     
     - Parameter fingerprints: All messages to ack as pending
     
     */
    func messageAcknowledgePending(fingerprints: [Int]) -> Void {
        
        let data: [String: Any] = [
            "fingerprints": fingerprints,
            "origin": "local"
        ]
        
        System.log("Ack an array of pending messages", type: .socketOut, data)
        socket?.emit("message:acknowledge:pending", with: [data])
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Acknowledges a message as delivered
     
     Exemple:
     
     ```
     {
     "fingerprints": [
     149208287069440
     ],
     "origin": "chat"
     }
     ```
     
     - Parameter fingerprints: All messages to ack as delivered
     
     */
    func messageAcknowledgeDelivered(fingerprints: [Int]) -> Void {
        
        let data: [String: Any] = [
            "fingerprints": fingerprints,
            "origin": "local"
        ]
        
        System.log("Ack an array of delivered messages", type: .socketOut, data)
        socket?.emit("message:acknowledge:delivered", with: [data])
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Acknowledges a message as received
     
     Exemple:
     
     ```
     {
     "fingerprints": [
     149208287069440
     ],
     "origin": "chat"
     }
     ```
     
     - Parameter fingerprints: All messages to ack as received
     
     */
    func messageAcknowledgeReceived(fingerprints: [Int]) -> Void {
        
        let data: [String: Any] = [
            "fingerprints": fingerprints,
            "origin": "local"
        ]
        
        System.log("Ack an array of received messages", type: .socketOut, data)
        socket?.emit("message:acknowledge:received", with: [data])
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Sends a message compose payload (MagicType, visitor -> operator)
     
     Exemple:
     
     ```
     {
     "excerpt": "de fef ef",
     "type": "start"
     }
     ```
     
     - Parameter excerpt: The begining of the message write
     - Parameter excerpt: The writing status
     
     */
    func messageComposeSend(excerpt: String? = nil, type: ComposeType) -> Void {
        
        var data: [String: Any] = [
            "type": type.rawValue
        ]
        
        if let e = excerpt {
            data["excerpt"] = e
        }
        
        System.log("Compose was sent", type: .socketOut, data)
        CrispNotifier.post(.eventComposeSent)
        socket?.emit("message:compose:send", with: [data])
    }
    
    
    // TODO: storage:sync:update
    
    /**
     
     Socket ➡️ (Out)
     
     Update the sync storage on server
     
     Exemple:
     
     ```
     
     ```
     
     - Parameter data: Previous incoming data to add to storage
     - Parameter type: The type of data to add on the storage
     
     */
    
    func storageSyncUpdate(withData _data: [[String: Any]], type: StorageSyncType) {
        
        let data: [String: Any] = [
            "data": _data,
            "ray": sharedStore.genRay(type: type.rawValue),
            "type": type.rawValue
        ]
        
        System.log("Storage was sync", type: .socketOut, data)
        socket?.emit("storage:sync:update", with: [data])
    }
    
    /**
     
     Socket ➡️ (Out)
     
     Requests for a signed, one use upload URL
     
     Exemple:
     
     ```
     {
     "file": {
     "name": "pom.xml",
     "type": "text/xml"
     },
     "from": "visitor",
     "id": 1492083179083
     }
     ```
     
     - Parameter fileName: The name of the file to upload
     
     */
    func bucketUrlUploadGenerate(file: FileUpload) -> Void {
        
        let data: [String: Any] = [
            "file": [
                "name": file.name,
                "type": file.type
            ],
            "from": "visitor",
            "id": file.id
        ]
        
        System.log("Request an bucket url for an upload", type: .socketOut, data)
        socket?.emit("bucket:url:upload:generate", with: [data])
    }
    
    
    /**
     
     Socket ➡️ (Out)
     
     Lists media animations
     
     Exemple:
     
     ```
     "from": "visitor",
     "id": 1492082542685,
     "list": {
     "page": 1,
     "query": "d"
     }
     ```
     
     - Parameter page: The numero of page to request
     - Parameter query: The query entered by the user (Optional)
     
     */
    func mediaAnimationList(page: Int, query: String? = nil) -> Void {
        
        let fingerprint = Int(1000000000 - arc4random_uniform(100000000 - 1))
        
        var data: [String: Any] = [
            "from": "visitor",
            "id": fingerprint
        ]
        
        var list: [String: Any] = [:]
        list["page"] = page
        if query != nil {
            list["query"] = query
        }
        
        data["list"] = list
        
        System.log("animation was requested", type: .socketOut, data)
        socket?.emit("media:animation:list", with: [data])
    }
    
    // MARK: - HTTP Request
    
    func uploadFile(
        _ fileUpload: FileUpload,
        onSuccess successHandler: (()->())? = nil,
        onError errorHandler: (()->())? = nil)
    {
        guard let fileUrl = URL(string: fileUpload.localUrl) else { errorHandler?(); return }
        
        let signedUrl = fileUpload.signedUrl
        
        var data: Data? = nil
        do {
            data = try Data(contentsOf: fileUrl)
        } catch _ { errorHandler?(); return }
        
        guard data != nil else { errorHandler?(); return }
        
        let XAmzDate = getQueryStringParameter(url: signedUrl, param: "X-Amz-Date")
        
        let headers: HTTPHeaders = [
            "Content-Type": fileUpload.type,
            "Accept": "*/*",
            "Content-Disposition": "attachment",
            "X-Amz-Date": XAmzDate ?? "undefined"
        ]
        
        SwiftEventBus.post(.eventUploadStart, sender: nil)
        
        Alamofire
            .upload(data!,
                    to: signedUrl,
                    method: .put,
                    headers: headers)
            .uploadProgress { progress in
                let progression:Float = Float(progress.fractionCompleted * 100.0)
                SwiftEventBus.post(.eventUploadUpdate, sender: progression as AnyObject)
            }
            .response
            { (response) in
                SwiftEventBus.post(.eventUploadEnd, sender: nil)
                if response.error != nil {
                    System.log("reponse upload file", type: .error, response.error!)
                    errorHandler?()
                } else {
                    System.log("reponse upload file", type: .debug, response.response ?? "")
                    successHandler?()
                }
        }
    }
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        let url = NSURLComponents(string: url)!
        return url.queryItems?.filter({ (item) in item.name == param }).first?.value
    }
    
}
