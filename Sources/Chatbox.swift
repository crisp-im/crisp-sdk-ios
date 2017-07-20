//
//  Chatbox.swift
//  Crisp
//
//  Created by Quentin de Quelen on 17/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import UIKit

enum ChatboxState {
    case open
    case close
}

let sharedChatbox = ChatBox()

public class ChatBox: NSObject {

    let messageView: UINavigationController = {
        let message = MessageViewController()
        let view = UINavigationController(rootViewController: message)
        return view
    }()


    var state: ChatboxState = .close

    var openedBlock: (() -> ())? = nil
    var closedBlock: (() -> ())? = nil

    override public init() {
        super.init()
        System.log("chatbox init", type: .verbose)
        self.addObserver(self, forKeyPath: "state", options: [.old, .new, .prior], context: nil)
    }

    deinit {
        System.log("chatbox deinit", type: .verbose)
        self.removeObserver(self, forKeyPath: "state")
    }

    public func open() {
        guard state == .close else {return}
        System.log("open the chatbox", type: .verbose)
        CrispNotifier.post(.eventChatboxOpened)
        state = .open
        messageView.modalPresentationStyle = .formSheet
        UIApplication.shared.keyWindow?.rootViewController?.present(messageView, animated: true, completion: openedBlock)
    }

    public func close() {
        guard state == .open else {return}
        System.log("close the chatbox", type: .verbose)
        CrispNotifier.post(.eventChatboxClosed)
        state = .close
        messageView.dismiss(animated: true, completion: closedBlock)
    }

    public func toggle() {
        if state == .open {
            close()
        } else {
            open()
        }
    }

    public func opened() -> Bool {
        return state == .open ? true : false
    }

    public func closed() -> Bool {
        return state == .close ? true : false
    }

}
