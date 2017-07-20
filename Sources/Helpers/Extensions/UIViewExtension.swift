//
//  UIViewExtension.swift
//  Crisp
//
//  Created by Quentin de Quelen on 18/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation

extension UIView {
    func shadow(color: UIColor? = .darkGray, width: CGFloat? = 0, height: CGFloat? = 0, radius: CGFloat, opacity: Float) {
        self.layer.shadowColor = color!.cgColor
        self.layer.shadowOffset = CGSize(width: width!, height: height!)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
    }
}
