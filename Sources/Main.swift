//
//  Main.swift
//  Crisp
//
//  Created by Baptiste Jamin on 29/12/2017.
//  Copyright © 2017 crisp.im. All rights reserved.
//

import Foundation

public let Crisp: CrispMain = CrispMain()

open class CrispMain: NSObject {
    
    var websiteId: String!
    
    // MARK: Public functions
    /**
     
     - parameter websiteId: Your website_ID (should be valid)
     
     Initiate the crisp SDK. Should be the first call of crisp in the app. Place it on the AppDelegate
     
     Warning: If the websiteID is not valid the app will crash
     
     # Exemple
     
     ```
     Crisp.initialize(websiteId: "c46126bf-9865-4cd1-82ee-dbe93bd42485")
     ```
     */
    public func initialize(websiteId: String) {
        self.websiteId = websiteId
    }    
}
