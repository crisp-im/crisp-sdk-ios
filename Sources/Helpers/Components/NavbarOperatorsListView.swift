//
//  NavbarOperatorView.swift
//  Crisp
//
//  Created by Quentin de Quelen on 24/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit
import SnapKit

class NavbarOperatorsListView: UIView {
    
    var operators: [Operator] = [] {
        didSet {
            setupView()
        }
    }
    
    var operatorsImage: [AvatarImage] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        guard operators.count > 0 else {return}
        let opCount = operators.count - 1 > 4 ? 4 : operators.count - 1
        for op in operators {
            let opImage = AvatarImage()
            opImage.setImage(withOperator: op)
            opImage.size = CGSize(width: 30, height: 30)
            operatorsImage.append(opImage)
        }
        
        for index in 0...opCount {
            addSubview(operatorsImage[index])
            operatorsImage[index].snp.makeConstraints({ (make) in
                make.width.height.equalTo(30)
                make.centerY.top.bottom.equalToSuperview()
                if index == 0 {
                    make.leading.equalToSuperview()
                } else {
                    make.leading.equalTo(operatorsImage[index - 1].snp.trailing).offset(10)
                }
                if index == opCount {
                    make.trailing.equalToSuperview()
                }
            })
        }
        updateConstraints()
        layoutIfNeeded()
    }
    
    func set(operators: [Operator]) -> NavbarOperatorsListView {
        self.operators = operators
        return self
    }
}

