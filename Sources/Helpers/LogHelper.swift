//
//  LogHelper.swift
//  Crisp
//
//  Created by Quentin de Quelen on 17/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation

var logEnable: Bool = true
private var debugEnable: Bool = true

enum LogType: String {
    case socketOut = "Socket ➡️ (Out) |"
    case socketIn = "Socket ⬅️ (In) |"
    case socketError = "Socket 🅾️ (Error) |"
    case socketInfo = "Socket ✴️ (Info) |"
    
    case verbose = "Verbose ⚪️"
    case debug = "Debug 🔵"
    case error = "Error 🔴"
    
    case none = ""
    
    static let loggable = [socketOut, socketIn, error, verbose]
}

struct System {
    static func log(_ description: String, type: LogType = .none, _ items: Any...) {
        if debugEnable {
            let output = items.map { "\($0)" }.joined(separator: " ")
            print("\(type.rawValue) \(description)")
            if output.characters.count != 0 {
                print("\t \(output)")
            }
        } else if logEnable, LogType.loggable.contains(type) {
            print("Crisp | \(description)")
        }
    }
}
