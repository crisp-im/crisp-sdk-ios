//
//  StringExtension.swift
//  Crisp
//
//  Created by Quentin de Quelen on 13/12/2016.
//  Copyright © 2016 qdequele. All rights reserved.
//

import Foundation
import RxSwift

enum Regex: String {
    case email			= "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    case phoneNumber	= "/\\(?([0-9]{3})\\)?([ .-]?)([0-9]{3})\\2([0-9]{4})/"
    case url			= "/((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\\+\\$,\\w]+@)[A-Za-z0-9.-]+)((?:\\/[\\+~%\\/.\\w-_]*)?\\??(?:[-\\+=&;%@.\\w_]*)#?(?:[\\w]*))?)/"
	case shortcut		= "^!"
	case note			= "^/note\\s"
}

extension String {

    func isValidEmail() -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", Regex.email.rawValue as CVarArg)
        return emailTest.evaluate(with: self)
    }

    func isValidRegex(regex: Regex) -> Bool {
        let test = NSPredicate(format:"SELF MATCHES %@", regex.rawValue)
        return test.evaluate(with: self)
    }

    func match(for regex: Regex, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex.rawValue)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch _ {
            return []
        }
    }

    func isMatch(for regex: Regex, in text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex.rawValue)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            if results.count == 0 {
                return false
            } else {
                return true
            }
        } catch _ {
            return false
        }
    }

    func isMatch(for regexps: [Regex], in text: String) -> Bool {
        for regex in regexps {
            if isMatch(for: regex, in: text) {
                return true
            }
        }
        return false
    }

    func isMatch(for regex: Regex) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex.rawValue)
            let results = regex.matches(in: self, range: NSRange(location: 0, length: (self as NSString).length))
            if results.count == 0 {
                return false
            } else {
                return true
            }
        } catch _ {
            return false
        }
    }

    func isMatch(for regexps: [Regex]) -> Bool {
        for regex in regexps {
            if isMatch(for: regex) {
                return true
            }
        }
        return false
    }

    func numberOfMatch(for regex: Regex, in text: String) -> Int {
        do {
            let regex = try NSRegularExpression(pattern: regex.rawValue)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return  results.count
        } catch _ {
            return 0
        }
    }
	
	func openAsURL() {
		guard self.characters.count > 0 else { return }
		if let url = URL(string: self) {
			if #available(iOS 10.0, *) {
				UIApplication.shared.open(url, options: [:]) { _ in }
			} else {
				_ = UIApplication.shared.openURL(url)
			}
		}
	}

}

// MARK: String extension to cut string with following pattern : "dsakjd"[0...3]

extension String {

    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript (r: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound)
        let end = self.index(self.startIndex, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }
}

// MARK: String extension to get the height of the cell

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.height
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
}

extension  String {
    internal var localized: String {
        return NSLocalizedString(self,
                                 tableName: nil,
                                 bundle: Bundle(identifier: "im.crisp.crisp-sdk")!,
                                 value: "",
                                 comment: "")
    }
}
