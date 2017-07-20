//
//  NavbarOperatorView.swift
//  Crisp
//
//  Created by Quentin de Quelen on 24/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit
import SnapKit

class NavbarOperatorView: UIView {
    
    var title: String? {
        didSet {
            titleLabel.text = title!
        }
    }
    
    var prompt: String? {
        didSet {
            descriptionLabel.text = prompt!
        }
    }
    
    var avatar: AvatarImage = AvatarImage()
    
    var color: UIColor = .white{
        didSet {
            titleLabel.textColor = color
            descriptionLabel.textColor = color.withAlphaComponent(0.8)
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(avatar)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        
        avatar.snp.makeConstraints { (make) in
            make.height.width.equalTo(30)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(avatar.snp.trailing).offset(10)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.bottom.trailing.equalToSuperview()
            make.leading.equalTo(avatar.snp.trailing).offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
        }
        self.snp.makeConstraints { (make) in
            make.width.equalTo(200)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(color: UIColor) -> NavbarOperatorView {
        self.color = color
        return self
    }
    
    func set(title: String) -> NavbarOperatorView {
        self.title = title
        updateConstraints()
        layoutIfNeeded()
        return self
    }
    
    func set(prompt: String) -> NavbarOperatorView {
        self.prompt = prompt
        updateConstraints()
        layoutIfNeeded()
        return self
    }
    
    func set(operator op: Operator) -> NavbarOperatorView {
        self.avatar.setImage(withOperator: op)
        self.avatar.size = CGSize(width: 30, height: 30)
        updateConstraints()
        layoutIfNeeded()
        return self
    }
}

