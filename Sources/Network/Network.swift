//
//  Network.swift
//  Crisp
//
//  Created by Quentin de Quelen on 17/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import SocketIO

class NetworkMessage {
    let event: String
    let data: [String:Any]
    
    init(event: String, data: [String:Any]) {
        self.event = event
        self.data = data
    }
}

let sharedNetwork = Network()

class Network {
    
    var networkQueue: [NetworkMessage] = []
    var connected: Bool = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { 
                self.sendAllStackedMessages()
            }
        }
    }
    var connecting: Bool = false

    var socket: SocketIOClient?

    private var heartbeatTimer = Timer()
    private var reconnectTimer = Timer()
    

    init() {
        socket = SocketIOClient(socketURL: URL(string: .crispSocket)!,
                                config: [.forceWebsockets(true), .forceNew(true), .reconnects(false)])
        
        System.log("Network Was initialised", type: .debug)
        
    }

    deinit {
        stopHeartbeat()
    }
    
    // MARK: Socket Lifecycle

    func connect() {
        guard connecting == false else { return }
        connecting = true
        System.log("start connecting socketIO", type: .debug)

        socket?.on("session:created", callback: self.sessionCreated)
        socket?.on("session:joined", callback: self.sessionJoined)
        socket?.on("session:state", callback: self.sessionState)
        socket?.on("session:error", callback: self.sessionError)
        socket?.on("session:request:initiate", callback: self.sessionRequestInitiate)
        
        socket?.on("storage:sync:updated", callback: self.storageSyncUpdated)
        socket?.on("bucket:url:upload:generated", callback: self.bucketUrlUploadGenerated)
        socket?.on("media:animation:listed", callback: self.mediaAnimationListed)
        
        socket?.on("message:sent", callback: self.messageSent)
        socket?.on("message:received", callback: self.messageReceived)
        socket?.on("message:acknowledge:pending", callback: self.messageAcknowledgePending)
        socket?.on("message:acknowledge:read:send", callback: self.messageAcknowledgeReadSend)
        socket?.on("message:acknowledge:read:received", callback: self.messageAcknowledgeReadReceived)
        socket?.on("message:received:local", callback: self.messageReceivedLocal)
        socket?.on("message:compose:received", callback: self.messageComposeReceived)
        
        socket?.on("website:users:available", callback: self.websiteUsersAvailable)
        
        socket?.on("reconnect", callback: self.reconnect)
        socket?.on("connect", callback: self.connect)
        socket?.on("disconnect", callback: self.disconnect)
        socket?.on("error", callback: self.error)

        socket?.connect()
    }

    private func reconnect(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("Socket try to reconnect", type: .socketInfo, String(describing: dataArray!))
    }

    private func connect(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("Socket has been connected", type: .socketInfo, String(describing: dataArray!))
        if let _s = LocalStore().sessionId.get(), !_s.isEmpty {
            joinSession(sessionId: _s)
        } else {
            createSession(websiteId: Crisp.websiteId)
        }
    }

    private func disconnect(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("Socket has been disconnected", type: .socketInfo, String(describing: dataArray!))
        stopHeartbeat()
        startReconnect()
        connected = false
        connecting = false
    }

    private func error(_ dataArray: [Any]?, _ socketAck: Any?) -> Void {
        System.log("Socket error occured", type: .socketError, String(describing: dataArray!))
    }
    
    // MARK: Timers
    
    func startHeartbeat() {
        heartbeatTimer.invalidate()
        heartbeatTimer = Timer.scheduledTimer(timeInterval: 170, target: self, selector: #selector(doHeartbeat), userInfo: nil, repeats: true)
    }
    
    func startReconnect() {
        reconnectTimer.invalidate()
        reconnectTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(doReconnect), userInfo: nil, repeats: false)
    }
    
    func stopHeartbeat() {
        heartbeatTimer.invalidate()
    }
    
    @objc func doHeartbeat() {
        sessionHearhbeat()
    }
    
    @objc func doReconnect() {
        socket?.connect()
        reconnectTimer.invalidate()
    }
    
    // MARK: - Stack Async calls
    
    func sendAllStackedMessages() {
        System.log("un-stack NetworkQueue | count : \(networkQueue.count)", type: .debug)
        networkQueue.forEach { (message) in
            System.log("send un-stacked message \"\(message.event)\"", type: .socketOut, message.data)
            socket?.emit(message.event, with: [message.data])
        }
        networkQueue = []
    }
    
    func emit(_ event: String, with data: [String:Any]) {
        if connected == false {
            System.log("add event to NetworkQueue", type: .debug, event)
            networkQueue.append(NetworkMessage(event: event, data: data))
        } else {
            socket?.emit(event, with: [data])
        }
    }
    
}
