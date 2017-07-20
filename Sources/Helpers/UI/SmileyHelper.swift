//
//  SmileyHelper.swift
//  Crisp-ios
//
//  Created by Quentin DEQUELEN on 12/3/16.
//  Copyright © 2016 qdequele. All rights reserved.
//

import Foundation
import UIKit

class Smiley {

	static let after = "($|\\s|[.?!,])"
	static let before = "(^|\\s|[.?!,])"
	
    static let smileys = [
		"angry":         before + "(:(?:-)?@)" + after,
		"big-smile":     before + "(:(?:-)?D)" + after,
		"blushing":		before + "(:(?:-)?\\$)" + after,
		"confused":		before + "(x(?:-)?\\))" + after,
		"cool":			before + "(8(?:-)?\\))" + after,
		"crying":		before + "(:'(?:-)?\\()" + after,
		"embarrased":	before + "(:(?:-)?\\/)" + after,
		"heart":         before + "(\\<3)" + after,
		"laughing":		before + "(:(?:-)?'D)" + after,
		"sad":			before + "(:(?:-)?(?:\\(|\\|))" + after,
		"sick":			before + "(:(?:-)?S)" + after,
		"small-smile":   before + "(:(?:-)?\\))" + after,
		"surprised":     before + "(:(?:-)?o)" + after,
		"thumbs-up":     before + "(\\+1)" + after,
		"tongue":		before + "(:(?:-)?P)" + after,
		"winking":		before + "(;(?:-)?\\))" + after
    ]

	class func findAndReplace(_ attributedString: NSMutableAttributedString,
	                          regex: String,
	                          image: String,
	                          largeImageSize: Int? = 50,
	                          smallImageSize: Int? = 14) {

        var attributedStringLength = attributedString.string.characters.count

        do {
            let regex    = try NSRegularExpression.cached(pattern: regex)
            let results  = regex.matches(in: attributedString.mutableString as String,
                                         options: [],
                                         range: NSMakeRange(0, attributedString.mutableString.length))
            for result in results {

                let bigSmile = result.range.location == 0 && result.range.length == attributedString.mutableString.length

                let textAttachment: NSTextAttachment = NSTextAttachment()
				let attrStringWithImage: NSAttributedString
				textAttachment.image = UIImage(named: image, in: Bundle(identifier: "im.crisp.crisp-sdk"), compatibleWith: nil)
				if bigSmile {
                    textAttachment.bounds = CGRect(x: 0, y: -2, width: largeImageSize!, height: largeImageSize!)
					attrStringWithImage = NSAttributedString(attachment: textAttachment)
                } else {
                    textAttachment.bounds = CGRect(x: 0, y: -2, width: smallImageSize!, height: smallImageSize!)
					attrStringWithImage = NSAttributedString(string: " ") + NSAttributedString(attachment: textAttachment) + NSAttributedString(string: " ")
                }
				let newRange = NSMakeRange(result.range.location, result.range.length)
				attributedStringLength -= result.range.length
				
				if newRange.location <= attributedStringLength {
					attributedString.replaceCharacters(in: newRange, with: attrStringWithImage)
				}
            }

        } catch let e {
			print(e.localizedDescription)
        }
    }

	class func replace(_ text: NSAttributedString,
	                   largeImageSize: Int? = 50,
	                   smallImageSize: Int? = 14) -> NSAttributedString {

        let attributedString = NSMutableAttributedString(attributedString: text)
		
        for smiley in smileys {
            findAndReplace(
                attributedString,
                regex: smiley.1,
                image: smiley.0,
                largeImageSize: largeImageSize,
                smallImageSize: smallImageSize
            )
        }

        return attributedString
    }

}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
{
	let result = NSMutableAttributedString()
	result.append(left)
	result.append(right)
	return result
}
