//
//  EventStringExtension.swift
//  Crisp
//
//  Created by Quentin de Quelen on 16/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation

extension String {
    
    // MARK: Public
    
    static let eventSessionLoaded   = "crisp:session:loaded"
    
    static let eventChatInitiated   = "crisp:chat:initiated"
    
    static let eventMessageSent     = "crisp:message:sent"
    static let eventMessageReceive  = "crisp:message:received"
    static let eventComposeSent     = "crisp:compose:sent"
    static let eventComposeReceive  = "crisp:compose:received"
    
    static let eventChatboxOpened    = "crisp:chatbox:opened"
    static let eventChatboxClosed    = "crisp:chatbox:closed"
    
    static let eventUserEmailChanged    = "crisp:user:email:changed"
    static let eventUserPhoneChanged    = "crisp:user:phone:changed"
    static let eventUserNicknameChanged = "crisp:user:nickname:changed"
    static let eventUserAvatarChanged   = "crisp:user:avatar:changed"
    
    static let eventWebsiteAvailabilityChanged = "crisp:website:availability:changed"
    
    // MARK: Privates
    
    static let eventMessageRead     = "crisp:message:read"
    static let eventMessageNew      = "crisp:message:new"
    
    static let eventCloseKeyboard   = "crisp:keyboard:close"
    
    static let eventUploadStart     = "crisp:upload:start"
    static let eventUploadUpdate    = "crisp:upload:update"
    static let eventUploadEnd       = "crisp:upload:end"
    
    static let eventChangeInputText = "crisp:change:input:text"
}
