//
//  CAGradientLayerExtension.swift
//  Crisp-ios
//
//  Created by Quentin DEQUELEN on 11/30/16.
//  Copyright © 2016 qdequele. All rights reserved.
//

import UIKit
import QuartzCore

extension CAGradientLayer {

    class func blue(onView view: UIView) -> CAGradientLayer {
        let top = UIColor(hex:"#1991EB").cgColor
        let bottom = UIColor(hex:"#2DA1F8").cgColor
        return self.setupLayer(top, bottom, view: view)
    }

    class func green(onView view: UIView) -> CAGradientLayer {
        let top = UIColor(hex:"#5EDB49").cgColor
        let bottom = UIColor(hex:"#2AB314").cgColor
        return self.setupLayer(top, bottom, view: view)
    }

    class func red(onView view: UIView) -> CAGradientLayer {
        let top = UIColor(hex:"#F45438").cgColor
        let bottom = UIColor(hex:"#C8270C").cgColor
        return self.setupLayer(top, bottom, view: view)
    }
	
	class func orange(onView view: UIView) -> CAGradientLayer {
		let top = UIColor(hex:"#FF7800").cgColor
		let bottom = UIColor(hex:"#DA863C").cgColor
		return self.setupLayer(top, bottom, view: view)
	}

    private class func setupLayer(_ colorTop: CGColor, _ colorBottom: CGColor, view: UIView) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [colorTop, colorBottom]
        gradient.locations = [0.0, 1.0]
        gradient.frame = view.bounds
        return gradient
    }

}
