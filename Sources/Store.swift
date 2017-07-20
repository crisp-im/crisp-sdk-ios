//
//  Storage.swift
//  Crisp
//
//  Created by Quentin de Quelen on 25/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import RxSwift

let sharedStore: Store = Store()
let sharedSetting: Setting = Setting()

struct FileUpload {
    var id: String
    var localUrl: String = ""
    var signedUrl: String = ""
    var ressourceUrl: String = ""
    var name: String = ""
    var type: String = ""
    var messageType: MessageType = .file
    
    
    init(fileName: String) {
        id = String(1_000_000_000 - arc4random_uniform(100_000_000 - 1))
        type = fileName.mimeType()
        name = fileName.removingPercentEncoding?.characters.split{$0 == "/"}.map(String.init).last ?? ""
        localUrl = fileName
    }
}

class Store: NSObject {

    var session: Session? = nil
    
    var unread: Int = 0

    var messages = Variable<[Int:Message]>([:])
    var gifs = Variable<[String]>([])
    var upload = Variable<FileUpload?>(nil)
    
    var compose = Variable<Bool>(false)
    var composeTimer: Timer?

    let disposeBag = DisposeBag()

    let rayEntropyFactor = 10000
    var rayEntropySpeed = 1
    var rayEntropyIncrement = 0

    override init() {
        super.init()

        self.restore()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillTerminate),
                                               name: .UIApplicationWillTerminate,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        upload.asObservable().subscribe(onNext: { file in
            guard let file = file else {return}
            if !file.ressourceUrl.isEmpty, !file.signedUrl.isEmpty {
                sharedNetwork.uploadFile(file, onSuccess: {
                    guard let file = self.upload.value else {return}
                    let message: Message = Message()
                    message.type = .file
                    message.contentObject = MessageContent()
                    message.contentObject?.url = file.ressourceUrl
                    message.contentObject?.name = file.name
                    message.contentObject?.type = file.type
                    message.isMe = true
                    sharedNetwork.messageSend(message: message)
                    self.add(message: message)
                    self.upload.value = nil
                })
            } else if !file.name.isEmpty {
                sharedNetwork.bucketUrlUploadGenerate(file: file)
            }
        }).addDisposableTo(disposeBag)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func applicationWillTerminate(_ notif: Notification) {
        self.backup()
        sharedNetwork.socket?.disconnect()
    }
    @objc func applicationDidEnterBackground(_ notif: Notification) {
        sharedNetwork.socket?.disconnect()
    }
    @objc func applicationDidBecomeActive(_ notif: Notification) {
        sharedNetwork.connect()
    }

    func create(session: Session) {
        System.log("DB is created")
        if self.session == nil {
            self.session = session
        }
        System.log("they are \(messages.value.count) message on this conversation before populate with session", type: .debug)
        if let messages = session.storage?.message {
            add(messages: messages)
        }
        if let messages = session.sync?.messages {
            add(messages: messages)
            let fingerprints = messages.map { return $0.fingerprint }
            sharedNetwork.messageAcknowledgePending(fingerprints: fingerprints)
            sharedNetwork.messageAcknowledgeDelivered(fingerprints: fingerprints)
        }
        System.log("they are \(messages.value.count) message on this conversation after populate with session", type: .debug)
    }

    // MARK: Messages

    func add(message: Message) {
        self.messages.value[message.fingerprint] = message
    }
    
    func add(messages: [Message]) {
        for message in messages {
            self.messages.value[message.fingerprint] = message
        }
    }

    // MARK: Gifs

    func update(gifs: [String]) {
        self.gifs.value.append(contentsOf: gifs)
    }

    func getGifs() -> Observable<[String]> {
        return gifs.asObservable()
    }

    // MARK: Persistence

    func backup() {
        print("Make a backup")
        if session != nil {
            let encodedSession = NSKeyedArchiver.archivedData(withRootObject: session!)
            UserDefaults.standard.set(encodedSession, forKey: "CrispSession")
            let encodedMessages = NSKeyedArchiver.archivedData(withRootObject: messages.value)
            UserDefaults.standard.set(encodedMessages, forKey: "CrispMessages")
        }
    }
    func restore() {
        print("Restore backup")
        if let data = UserDefaults.standard.data(forKey: "CrispSession"),
            let decodedSession = NSKeyedUnarchiver.unarchiveObject(with: data) as? Session {
            session = decodedSession
        }
        if let data = UserDefaults.standard.data(forKey: "CrispMessages"),
            let decodedMessages = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Int:Message] {
            System.log("Number of message storred on Local", type: .debug, decodedMessages.count)
            for (key, value) in decodedMessages {
                self.messages.value[key] = value
            }
            System.log("they are \(messages.value.count) message on this conversation after recover local messages", type: .debug)
        }
    }

    // MARK: Ray

    func genRay(type: String) -> String {
        var x: Double = 0.0

        rayEntropySpeed = rayEntropySpeed + 1
        x = sin(Double(rayEntropySpeed)) * Double(rayEntropyFactor)
        x = x - floor(x)

        rayEntropyIncrement = rayEntropyIncrement + 1
        let increment = rayEntropyIncrement

        return type + "/\(floor(NSDate().timeIntervalSince1970 * 1000))/\(x)/\(increment)"
    }
    
    // MARK: - Upload File
    
    func sendFile(_ fileName: String) {
        self.upload.value = FileUpload(fileName: fileName)
    }
    
    // MARK: - Compose
    
    func update(compose: Bool) {
        self.compose.value = compose
        composeTimer?.invalidate()
        composeTimer = Timer.scheduledTimer(timeInterval: 200,
                                            target: self,
                                            selector: #selector(doThrottleCompose),
                                            userInfo: nil,
                                            repeats: false)
    }
    
    @objc func doThrottleCompose() {
        compose.value = false
    }
    
    
    // MARK: - ReSend Message
    
    func sendMessage(withFingerprint fingerprint: Int) {
        if let message = messages.value[fingerprint] {
            message.error = false
            message.timestamp = Date()
            message.checkRecepetion()
            messages.value[fingerprint] = message
            sharedNetwork.messageSend(message: message)
        }
    }
    
    func sendAllErrorMessages() {
        messages.value.forEach { (message: (key: Int, value: Message)) in
            if message.value.error == true {
                sendMessage(withFingerprint: message.key)
            }
        }
    }
}
