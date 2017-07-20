//
//  AvatarImage.swift
//  Crisp
//
//  Created by Quentin de Quelen on 26/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit
import SDWebImage
import EasyTipView
import SnapKit

class AvatarImage: UIView {

    var size: CGSize {
        didSet {
            frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            layer.cornerRadius = size.width / 2
            imageView.layer.cornerRadius = size.width / 2
        }
    }
    
    private var tooltip: EasyTipView?
    private var tooltipTimer: Timer? = nil
    private var tooltipIsShow: Bool = false
    
    private let defaultImage = UIImage(named: "Avatar", in: Bundle(identifier: "im.crisp.crisp-sdk"), compatibleWith: nil)
    private var user: User?
    private var op: Operator?
    
    private let imageView = UIImageView()

    override init(frame: CGRect) {

        size = CGSize(width: frame.width, height: frame.height)

        super.init(frame: frame)

        layer.cornerRadius = size.width / 2
        imageView.layer.cornerRadius = size.width / 2
        imageView.contentMode = .scaleAspectFill
        backgroundColor = UIColor.crispLightNight.darker(by: 0.8)
        imageView.image = defaultImage
        imageView.clipsToBounds = true
        
        shadow(width: 0, height: 1, radius: 2, opacity: 0.3)
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(withUser user: User, isOperator: Bool? = false) {
        let sesisonId = LocalStore().sessionId.get()
        self.user = user
        var url: String
        if isOperator! {
            if user.avatar != nil , !user.avatar!.isEmpty {
                url = Avatar.format("operator", id: sesisonId, avatarUrl: user.avatar)
            } else {
                url = "https://image.crisp.chat/avatar/operator/\(user.userId)/90"
            }
            
        } else {
            if let avatar = user.avatar, !avatar.isEmpty {
                url = Avatar.format("visitor", id: sesisonId, avatarUrl: avatar)
            } else if let email = user.email, !email.isEmpty {
                url = Avatar.format("visitor", id: sesisonId, avatarUrl: email)
            } else {
                url = Avatar.format("visitor", id: sesisonId, avatarUrl: nil)
            }
        }

        loadImage(withUrl: url)
    }

    func setImage(withOperator operator: Operator) {
        self.op = `operator`
        let sesisonId = LocalStore().sessionId.get()
        var url: String
        if let avatar = `operator`.avatar, !avatar.isEmpty {
            url = Avatar.format("operator", id: sesisonId, avatarUrl: avatar)
        } else {
            url = "https://image.crisp.chat/avatar/operator/\(`operator`.userId)/90"
        }
        loadImage(withUrl: url)
    }

    private func loadImage(withUrl url: String) {
        imageView.sd_setImage(with: URL(string: url), placeholderImage: defaultImage)
        if imageView.image!.size.width <= CGFloat(1.0) {
            imageView.image = defaultImage
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        showTooltip()
    }
    
    // MARK: - Tooltip functions
    
    private func showTooltip() {
        guard !tooltipIsShow else { closeTooltip(); return}
        guard let name = self.user?.nickname ?? self.op?.nickname else {return}
        guard let mainView = UINavigationController().getCurrentViewController()?.view  else {return}
        self.tooltip?.dismiss()
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.arrowPosition = .bottom
        self.tooltip = EasyTipView(text: name, preferences: preferences)
        self.tooltip?.show(forView: self, withinSuperview: mainView)
        startThrottleDismissTooltip()
        tooltipIsShow = true
    }
    
    func closeTooltip() {
        self.tooltip?.dismiss()
        tooltipTimer?.invalidate()
        tooltipIsShow = false
    }
    
    func startThrottleDismissTooltip() {
        tooltipTimer?.invalidate()
        tooltipTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(throttleDismissTooltip), userInfo: nil, repeats: false)
    }
    
    @objc func throttleDismissTooltip() {
        closeTooltip()
    }


}

