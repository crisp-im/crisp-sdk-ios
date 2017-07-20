//
//  Preferences.swift
//  Crisp
//
//  Created by Quentin de Quelen on 22/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation

let sharedPreferences = Preferences()

/**
 
 Predifined color for all the the chatbox
 
 - blue
 - amber
 - black
 - blueGrey
 - blueLight
 - brown
 - cyan
 - green
 - greenLight
 - grey
 - indigo
 - orange
 - orangeDeep
 - pink
 - purple
 - purpleDeep
 - red
 - teal
 
 default will be blue
 
 */
public enum ThemeColors: String {
    // hexa code: #377fea
    case blue       = "377fea"
    // hexa code: #e8b10d
    case amber      = "e8b10d"
    // hexa code: #282828
    case black      = "282828"
    // hexa code: #607d8b
    case blueGrey   = "607d8b"
    // hexa code: #08a6ed
    case blueLight  = "08a6ed"
    // hexa code: #795548
    case brown      = "795548"
    // hexa code: #00adc3
    case cyan       = "00adc3"
    // hexa code: #4caf50
    case green      = "4caf50"
    // hexa code: #84bc44
    case greenLight = "84bc44"
    // hexa code: #7d7d7d
    case grey       = "7d7d7d"
    // hexa code: #3f51b5
    case indigo     = "3f51b5"
    // hexa code: #ff9801
    case orange     = "ff9801"
    // hexa code: #ff5723
    case orangeDeep = "ff5723"
    // hexa code: #e91e63
    case pink       = "e91e63"
    // hexa code: #9c27b0
    case purple     = "9c27b0"
    // hexa code: #673ab7
    case purpleDeep = "673ab7"
    // hexa code: #f44336
    case red        = "f44336"
    // hexa code: #009688
    case teal       = "009688"
}

/**
 
 Translated text
 
 - defaultChat
 - oneChat
 - twoChat
 - threeChat
 - fourChat
 
 %@ will be the name of your company
 
 */
public enum ThemeText: String {
    // Questions? Chat with us!
    case defaultChat    = "theme_text_default_chat"
    // Questions? Chat with me!
    case oneChat        = "theme_text_1_chat"
    // Ask us your questions
    case twoChat        = "theme_text_2_chat"
    // Ask me your questions
    case threeChat      = "theme_text_3_chat"
    // Chat with support
    case fourChat       = "theme_text_4_chat"
}

/**
 
 Translated welcome messages
 
 - defaultChat
 - oneChat
 - twoChat
 - threeChat
 - fourChat
 - fiveChat
 
 %@ will be the name of your company
 
*/
public enum ThemeWelcome: String {
    // How can we help with %@?
    case defaultChat    = "theme_welcome_default_chat"
    // Hey, want to chat with us?
    case oneChat        = "theme_welcome_1_chat"
    // Anything you want to ask?
    case twoChat        = "theme_welcome_2_chat"
    // Hello, ask us any question about %@.
    case threeChat      = "theme_welcome_3_chat"
    // Hello! How can I help you? :)
    case fourChat       = "theme_welcome_4_chat"
    // Any question about %@?
    case fiveChat       = "theme_welcome_5_chat"
}

public class Preferences {
    private var _color: UIColor = UIColor(hex: "3495e8")
    private var _themeText: String = .theme_text_default_chat
    private var _themeWelcome: String = .theme_welcome_default_chat
    
    public var color: UIColor {
        return _color
    }
    
    public var themeText: String {
        return _themeText
    }
    
    public var themeWelcome: String {
        return _themeWelcome
    }
    
    public func setColor(_ color: UIColor) {
        self._color = color
    }
    
    public func setColor(def color: ThemeColors) {
        self._color = UIColor(hex: color.rawValue)
    }
    
    public func setColor(hex color: String) {
        self._color = UIColor(hex: color)
    }
    
    public func setThemeText(_ themeName: ThemeText) {
        _themeText = NSLocalizedString(themeName.rawValue, tableName: nil, bundle: Bundle(identifier: "im.crisp.crisp-sdk")!, value: "", comment: "")
    }
    
    public func setThemeText(string: String) {
        _themeText = string
    }
    
    public func setThemeWelcome(_ themeName: ThemeWelcome) {
        _themeWelcome = NSLocalizedString(themeName.rawValue, tableName: nil, bundle: Bundle(identifier: "im.crisp.crisp-sdk")!, value: "", comment: "")
    }
    
    public func setThemeWelcome(string: String) {
        _themeWelcome = string
    }
    
}
