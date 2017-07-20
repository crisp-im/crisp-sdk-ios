//
//  LocalStore.swift
//  Crisp
//
//  Created by Quentin de Quelen on 24/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation

struct LocalStoreString {

    private var key: String = ""

    init(key: String) {
        self.key = key
    }

    func set(_ record: String) {
        UserDefaults.standard.set(record, forKey: self.key)
        UserDefaults.standard.synchronize()
    }

    func get() -> String? {
        return UserDefaults.standard.value(forKey: self.key) as! String?
    }

    func delete() {
        UserDefaults.standard.removeObject(forKey: self.key)
        UserDefaults.standard.synchronize()
    }
}

struct LocalStoreBool {

    private var key: String = ""

    init(key: String) {
        self.key = key
    }

    func set(_ record: Bool) {
        UserDefaults.standard.set(record, forKey: self.key)
        UserDefaults.standard.synchronize()
    }

    func get() -> Bool {
        return UserDefaults.standard.value(forKey: self.key) as? Bool ?? false
    }

    func delete() {
        UserDefaults.standard.removeObject(forKey: self.key)
        UserDefaults.standard.synchronize()
    }
}

struct LocalStore {
    var websiteId			= LocalStoreString(key: "CrispSDKWebsiteId")
    var sessionId			= LocalStoreString(key: "CrispSDKSessionId")

    func flush() {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
}
