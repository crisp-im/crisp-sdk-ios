//
//  MessageStatusView.swift
//  Crisp
//
//  Created by Quentin de Quelen on 18/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit
import SnapKit
import EasyTipView
import QuartzCore

enum MessageStatusViewType {
    case sending, received, read, error
}

class MessageStatusView: UIView {
    
    var status: MessageStatusViewType = .sending {
        didSet {
            layout()
        }
    }
    
    var fingerprint: Int = 0
    
    private var imageView = UIImageView()
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    private var tooltip: EasyTipView?
    private var tooltipTimer: Timer? = nil
    private var tooltipIsShow: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        
        actInd.hidesWhenStopped = true
        actInd.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        actInd.color = sharedPreferences.color
        actInd.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        addSubview(imageView)
        addSubview(actInd)
        
        imageView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        actInd.snp.makeConstraints { (make) in
            make.width.height.equalTo(15)
            make.center.equalToSuperview()
        }

        actInd.startAnimating()
        imageView.contentMode = .scaleAspectFill

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        switch status {
        case .sending:
            imageView.isHidden = true
            actInd.startAnimating()
        case .received:
            actInd.stopAnimating()
            imageView.isHidden = false
            imageView.image = .feedbackReceived
        case .read:
            actInd.stopAnimating()
            imageView.isHidden = false
            imageView.image = .feedbackRead
        case .error:
            actInd.stopAnimating()
            imageView.isHidden = false
            imageView.image = .feedbackError
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        showTooltip()
    }
    
    // MARK: - Tooltip functions
    
    private func showTooltip() {
        if !tooltipIsShow, let mainView = UINavigationController().getCurrentViewController()?.view {
            self.tooltip?.dismiss()
            var preferences = EasyTipView.globalPreferences
            preferences.drawing.arrowPosition = .right
            switch status {
            case .sending:
                self.tooltip = EasyTipView(text: "Sending", preferences: preferences)// TODO: Translate
            case .received:
                self.tooltip = EasyTipView(text: "Delivered", preferences: preferences)// TODO: Translate
            case .read:
                self.tooltip = EasyTipView(text: .chat_message_info_read, preferences: preferences)
            case .error:
                self.tooltip = EasyTipView(text: .chat_message_error_retry, preferences: preferences)
            }
            self.tooltip?.show(forView: self, withinSuperview: mainView)
            startThrottleDismissTooltip()
            tooltipIsShow = true
            if status == .error {
                sharedStore.sendMessage(withFingerprint: fingerprint)
            }
        } else {
            closeTooltip()
        }
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
