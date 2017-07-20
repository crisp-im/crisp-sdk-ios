//
//  LinkButton.swift
//  Crisp
//
//  Created by Quentin de Quelen on 27/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit

class LinkButton: UIButton {
    var url: String = ""
    var openURLInBrowser: Bool =  false

    override init(frame: CGRect) {
        super.init(frame: frame)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openURL))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func openURL() {
        guard openURLInBrowser == true else { return }
        url.openAsURL()
    }
}
