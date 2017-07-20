//
//  AvatarHelper.swift
//  Crisp-ios
//
//  Created by Quentin DEQUELEN on 12/3/16.
//  Copyright © 2016 qdequele. All rights reserved.
//

import Foundation

class Avatar {

    class func format(_ type: String, id: String?, avatarUrl: String?) -> String {
        var avatarCachePath: String
		if let avatarUrl = avatarUrl {
			avatarCachePath = avatarUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
		} else {
			avatarCachePath = "default"
		}
		if let id = id, id.characters.count > 0 {
			return (.crispImage + "/avatar/\(type)/\(id)/200/?avatar=\(avatarCachePath)")
		} else {
			return (.crispImage + "/process/thumbnail/?url=\(avatarCachePath)&width=200&height=200")
		}
    }
	
	class func color(forSession sessionId: String) -> UIColor {
		let segment: [String] = [
			"CCCCCC",
			"FF84BE",
			"FF9595",
			"FFC96E",
			"FFE984",
			"C9FF84",
			"95FF84",
			"84FFB1",
			"84FFDE",
			"84FEFF",
			"84D9FF",
			"84BDFF",
			"84A2FF",
			"8584FF",
			"AF84FF"
		]
		
		var increment = 0
		
		for char in sessionId.unicodeScalars {
			increment += Int(char.value)
		}
		
		let hexValue = "#" + segment[ increment % segment.count ]
		
		return UIColor(hex: hexValue)
	}
}
