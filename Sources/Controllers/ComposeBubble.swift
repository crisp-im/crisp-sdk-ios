//
//  ComposeBubble.swift
//  Crisp
//
//  Created by Quentin de Quelen on 22/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import SnapKit
import NVActivityIndicatorView


class ComposeBubble: UITableViewCell {
    
    let bubbleView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    let typingAnnimation = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20),
                                                   type: .ballPulseSync,
                                                   color: .white,
                                                   padding: 0)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(bubbleView)
        addSubview(typingAnnimation)
        
        bubbleView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(50)
            make.width.equalTo(50)
            make.height.equalTo(35)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        typingAnnimation.snp.makeConstraints { (make) in
            make.center.equalTo(bubbleView)
            make.width.height.equalTo(20)
        }
        
        bubbleView.backgroundColor = sharedPreferences.color
        backgroundColor = UIColor(hex: "f5f8fb")
        selectionStyle = .none
        isOpaque = true
        typingAnnimation.startAnimating()
        updateConstraints()
        layoutIfNeeded()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
