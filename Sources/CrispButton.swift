//
//  CrispButton.swift
//  Crisp
//
//  Created by Quentin de Quelen on 20/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import SnapKit
import EasyTipView
import SwiftEventBus

/**
 Use this UI component to show the crisp bubble on you app
 
 # Exemple
 
 ``swift
 import Crisp
 import SnapKit
 
 class ViewController: UIViewController {
 
     override func viewDidLoad() {
         super.viewDidLoad()
         // Do any additional setup after loading the view, typically from a nib.
         let crispButton = CrispButton()
         view.addSubview(crispButton)
         crispButton.snp.makeConstraints { (make) in
             make.trailing.equalToSuperview().offset(-20)
             make.bottom.equalToSuperview().offset(-20)
         }
     }
     
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
     }
 }

 ```
 */
public class CrispButton: UIView, EasyTipViewDelegate {
    
    private var bubbleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.setImage(.crispLogo, for: .normal)
        button.backgroundColor = sharedPreferences.color
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.imageEdgeInsets = UIEdgeInsets(top: 20, left: 15, bottom: 15, right: 15)
        button.addTarget(self, action: #selector(openChatbox), for: .touchUpInside)
        button.shadow(radius: 4, opacity: 0.5)
        return button
    }()
    
    private var presenceIcon: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.layer.insertSublayer(CAGradientLayer.green(onView: view), at: 0)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.shadow(radius: 2, opacity: 0.3)
        return view
    }()
    
    private var unreadIcon: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.layer.insertSublayer(CAGradientLayer.red(onView: view), at: 0)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.shadow(radius: 2, opacity: 0.3)
        return view
    }()
    
    var unreadTextView: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    private var tooltip: EasyTipView?
    private var tooltipTimer: Timer? = nil
    
    private var unreadCount: Int  = 0 {
        didSet {
            sharedStore.unread = unreadCount
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))

        addSubview(bubbleButton)
        addSubview(presenceIcon)
        addSubview(unreadIcon)
        unreadIcon.addSubview(unreadTextView)
        
        self.snp.makeConstraints { (make) in
            make.height.width.equalTo(60)
        }
        
        bubbleButton.snp.makeConstraints { (make) in
            make.bottom.top.leading.trailing.equalToSuperview()
        }
        
        presenceIcon.snp.makeConstraints { (make) in
            make.height.width.equalTo(20)
            make.trailing.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(2)
        }
        
        unreadIcon.snp.makeConstraints { (make) in
            make.height.width.equalTo(20)
            make.trailing.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(2)
        }
        
        unreadTextView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        unreadIcon.isHidden = true
        
        bubbleButton.addTarget(self, action: #selector(openChatboxButton), for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showTooltip(withText: sharedPreferences.themeText)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.updatePresenceIcon()
        }
        
        SwiftEventBus.onMainThread(self, name: .eventMessageNew) { (notif) in
            System.log("New message received", type: .verbose)
            self.unreadCount += 1
            self.presenceIcon.isHidden = true
            self.unreadIcon.isHidden = false
            self.unreadTextView.text = String(self.unreadCount)
            self.messageReceived()
        }
        
        SwiftEventBus.onMainThread(self, name: .eventWebsiteAvailabilityChanged) { (notification) in
            self.updatePresenceIcon()
        }
        self.updatePresenceIcon()
        
        
    }
    
    private func updatePresenceIcon() {
        if let usersAvailable = sharedStore.session?.usersAvailable, usersAvailable {
            self.presenceIcon.isHidden = false
        } else {
            self.presenceIcon.isHidden = true
        }
    }
    
    func showTooltip(withText text:String) {
        if let mainView = self.superview {
            var preferences = EasyTipView.globalPreferences
            preferences.drawing.arrowPosition = .bottom
            preferences.drawing.backgroundColor = .white
            preferences.drawing.foregroundColor = .crispDarkNight
            preferences.positioning.bubbleHInset = 10.0
            preferences.positioning.bubbleVInset = 5.0
            self.tooltip = EasyTipView(text: text, preferences: preferences, delegate: self)
            self.tooltip?.shadow(radius: 2, opacity: 0.2)
            self.tooltip?.show(forView: bubbleButton, withinSuperview: mainView)
        }
    }
    
    func messageReceived() {
        if unreadCount > 1 {
            showTooltip(withText: .minimized_tooltip_unread_plural)
        } else {
            showTooltip(withText: .minimized_tooltip_unread_singular)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openChatboxButton() {
        self.tooltip?.dismiss()
    }
    
    func openChatbox() {
        sharedChatbox.open()
        self.updatePresenceIcon()
        self.unreadIcon.isHidden = true
        unreadCount = 0
    }
    
    public func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        self.openChatbox()
    }
}
