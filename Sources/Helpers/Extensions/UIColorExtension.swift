//
//  UIColorExtension.swift
//  Crisp-ios
//
//  Created by Quentin DEQUELEN on 11/30/16.
//  Copyright © 2016 qdequele. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var rgbInt: UInt64 = 0
        let newHex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: newHex)
        scanner.scanHexInt64(&rgbInt)
        let r: CGFloat = CGFloat((rgbInt & 0xFF0000) >> 16)/255.0
        let g: CGFloat = CGFloat((rgbInt & 0x00FF00) >> 8)/255.0
        let b: CGFloat = CGFloat(rgbInt & 0x0000FF)/255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
	
	func lighter(by percentage:CGFloat=30.0) -> UIColor? {
		return self.adjust(by: abs(percentage) )
	}
	
	func darker(by percentage:CGFloat=30.0) -> UIColor? {
		return self.adjust(by: -1 * abs(percentage) )
	}
	
	func adjust(by percentage:CGFloat=30.0) -> UIColor? {
		var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
		if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
			return UIColor(red: min(r + percentage/100, 1.0),
			               green: min(g + percentage/100, 1.0),
			               blue: min(b + percentage/100, 1.0),
			               alpha: a)
		}else{
			return nil
		}
	}

    func isDark() -> Bool {
        let count = self.cgColor.numberOfComponents
        if let componentColors = self.cgColor.components {
            var darknessScore = 0.0

            if count == 2 {
                let c0 = componentColors[0] * 76245
                let c1 = componentColors[0] * 149685
                let c2 = componentColors[0] * 29070

                darknessScore = Double(c0 + c1 + c2) / 1000.0
            } else if count == 4 {
                let c0 = componentColors[0] * 76245
                let c1 = componentColors[0] * 149685
                let c2 = componentColors[0] * 29070
                darknessScore = Double(c0 + c1 + c2) / 1000.0
            }
            if darknessScore >= 125.0 {
                return true
            }
        }
        return false
    }

    func isLight() -> Bool {
        let count = self.cgColor.numberOfComponents
        if let componentColors = self.cgColor.components {
            var darknessScore = 0.0

            if count == 2 {
                let c0 = componentColors[0] * 76245
                let c1 = componentColors[0] * 149685
                let c2 = componentColors[0] * 29070

                darknessScore = Double(c0 + c1 + c2) / 1000.0
            } else if count == 4 {
                let c0 = componentColors[0] * 76245
                let c1 = componentColors[0] * 149685
                let c2 = componentColors[0] * 29070
                darknessScore = Double(c0 + c1 + c2) / 1000.0
            }
            if darknessScore < 125.0 {
                return true
            }
        }
        return false
    }

    convenience init(rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)) {
        self.init(red: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    }
	
	convenience init(forText text: String) {
		let segment: [String] = [
			"C8270C",
			"1991EB",
			"8261E6",
			"354052",
			"7F8FA4",
			"DA932C"
		]
		
		var increment = 0

		for char in text.unicodeScalars {
			increment += Int(char.value)
		}
		
		let hexValue = "#" + segment[ increment % segment.count ]
		
		self.init(hex: hexValue)
		
	}

    class var crispBlue:       UIColor { return UIColor(hex: "#1991EB") }
    class var crispGreen:      UIColor { return UIColor(hex: "#0BC639") }
    class var crispRed:        UIColor { return UIColor(hex: "#ED495D") }
    class var crispOrange:     UIColor { return UIColor(hex: "#F5A623") }
	class var crispGrey:		UIColor { return UIColor(hex: "#9B9B9B") }
	class var crispLightGrey:	UIColor { return UIColor(hex: "#D8D8D8") }
    class var crispLightNight: UIColor { return UIColor(hex: "#F5F8FB") }
    class var crispDarkNight:  UIColor { return UIColor(hex: "#4A4A66") }

    class var crispTextDark:   UIColor { return UIColor(hex: "#354052") }

    class var crispBubbleYellow:   UIColor { return UIColor(hex: "#FFF9C7") }
    class var crispBubbleBlue:     UIColor { return UIColor(hex: "#377FEA") }
    class var crispBubbleBlueDark: UIColor { return UIColor(hex: "#415970") }
    class var crispBubbleWhite:    UIColor { return UIColor(hex: "#FFFFFF") }

	class var crispBackgroundLight:    UIColor { return UIColor(hex: "#EFF3F6") }

}
