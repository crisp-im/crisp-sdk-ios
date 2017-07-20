//
//  ActiveButton.swift
//  Crisp
//
//  Created by Quentin de Quelen on 26/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit

extension UIControlState {
    static let active = UIControlState(rawValue: 1 << 16)
}

class ActiveButton: UIButton {

    var active: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }

    override var state: UIControlState {
        get {
            return active ? UIControlState(rawValue: super.state.rawValue | UIControlState.active.rawValue) : super.state
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
