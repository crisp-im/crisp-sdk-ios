//
//  MessageView.swift
//  Crisp
//
//  Created by Quentin de Quelen on 27/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit
import SDWebImage
import FLAnimatedImage
import EasyTipView
import SwiftEventBus
import RxSwift
import DateToolsSwift

/**
 The horizontal padding between bubble border and bubble content
 */
fileprivate let BUBBLE_PADDING_H = 15

/**
 The vertical padding between bubble border and bubble content
 */
fileprivate let BUBBLE_PADDING_V = 7

/**
 The inter padding between content objects
 */
fileprivate let BUBBLE_PADDING_I = 4

class MessageBubble: UITableViewCell {

    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.1
        return view
    }()

    private let textMessageLabel: Label = {
        let label = Label()
        label.numberOfLines = 0

        label.underlineStyle = { _ in return .styleSingle }
        label.didTouch = { touch in
            if touch.state == .began {
                switch touch.linkResult.detectionType {
                case .email			: "mailto:\(touch.linkResult.text)".openAsURL()
                case .phoneNumber    : if UIDevice.current.userInterfaceIdiom == .phone { "tel:\(touch.linkResult.text)".openAsURL() }
                case .url           : "\(touch.linkResult.text)".openAsURL()
                case .userHandle     : "https://twitter.com/\(touch.linkResult.text)".openAsURL()
                case .hashtag       : "https://twitter.com/\(touch.linkResult.text)".openAsURL()
                default: break
                }
            }
        }
        label.contentMode = .top
        label.lineBreakMode = .byClipping
        return label
    }()

    private let linkButton: LinkButton = {
        let button = LinkButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.openURLInBrowser = true
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        return button
    }()

    private let pictureView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()

    let avatar: AvatarImage = AvatarImage(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    private let statusView: MessageStatusView = MessageStatusView()
    
    private var tooltip: EasyTipView?
    
    var message: Variable<Message>? {
        didSet {
            if let message = message?.value {
                if message.type == .text {
                    if (message.preview.startIndex != message.preview.endIndex) {
                        prepareForLink()
                    } else {
                        prepareForText()
                    }
                } else if message.type == .animation {
                    prepareForAnimation()
                } else if message.type == .file {
                    if message.contentObject?.type?.range(of: "image") != nil {
                        prepareForImage()
                    } else {
                        prepareForFile()
                    }
                }
            }

            SwiftEventBus.onMainThread(self, name: .eventMessageReceive) { result in
                if result.object as? Int == self.message?.value.fingerprint {
                    self.statusView.status = .received
                }
            }
            
            SwiftEventBus.onMainThread(self, name: .eventMessageRead) { result in
                if result.object as? Int == self.message?.value.fingerprint {
                    self.statusView.status = .read
                }
            }
            
            layoutIfNeeded()
        }
    }
    
    var isLast: Bool = false
    var lastOfGroup: Bool = false
    var hideAvatar: Bool = true {
        didSet {
            avatar.isHidden = hideAvatar
        }
    }
    
    private let disposeBag = DisposeBag()
    private var messageDispose: Disposable?
    private var tooltipTimer: Timer? = nil
    private var tooltipIsShow: Bool = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor(hex: "f5f8fb")
        selectionStyle = .none
        isOpaque = true
        avatar.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        message = nil
        isLast = false
        lastOfGroup = false
        hideAvatar = false
        tooltip?.dismiss()
        
        // hide objects
        pictureView.isHidden = true
        linkButton.isHidden = true
        textMessageLabel.isHidden = true
        avatar.isHidden = true
        
        // set content to null
        pictureView.image = nil
        pictureView.animationImages = []
        linkButton.url = ""
        textMessageLabel.text = ""
        
        // remove constaint
        bubbleView.snp.removeConstraints()
        textMessageLabel.snp.removeConstraints()
        pictureView.snp.removeConstraints()
        linkButton.snp.removeConstraints()
        
        // remove all subviews
        for view in subviews {
            view.removeFromSuperview()
        }
        
        //remove disposabe
        
        messageDispose?.dispose()
    
    }

    // MARK: - Prepares common bubble

    private func prepareBubble() {
        guard let message = message?.value else {return}
        addSubview(bubbleView)

        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(lastOfGroup ? -11 : -3)
            make.width.lessThanOrEqualToSuperview().offset(-80)
            if message.isMe {
                make.trailing.equalToSuperview().offset(-20)
            } else {
                make.leading.equalToSuperview().offset(50)
            }
        }

        if message.isMe {
            bubbleView.backgroundColor = .white
            bubbleView.tintColor = .crispDarkNight
            textMessageLabel.textColor = .crispDarkNight
            
        } else {
            bubbleView.backgroundColor = sharedPreferences.color
            print(sharedPreferences.color)
            bubbleView.tintColor = .white
            textMessageLabel.textColor = .white

            if !hideAvatar {
                addSubview(avatar)
                
                avatar.snp.makeConstraints { make in
                    make.height.width.equalTo(30)
                    make.bottom.equalToSuperview().offset(-5)
                    make.leading.equalToSuperview().offset(10)
                }
                if let user = message.user {
                    avatar.setImage(withUser: user, isOperator: true)
                }
            }
        }
        prepareStatus()
    }
    
    private func prepareStatus() {
        if isLast, let isMe = message?.value.isMe, isMe {
            addSubview(statusView)

            statusView.snp.makeConstraints({ (make) in
                make.bottom.equalTo(bubbleView)
                make.leading.equalTo(bubbleView.snp.trailing).offset(2)
                make.width.height.equalTo(15)
            })
            guard let message = message?.value else {return}
            statusView.fingerprint = message.fingerprint
            updateStatus(message)
        }
    }
    
    private func updateStatus(_ message: Message) {
        if message.isMe, message.read {
            statusView.status = .read
        } else if message.isMe, message.stamped {
            statusView.status = .received
        } else if message.isMe, message.error {
            statusView.status = .error
        } else {
            statusView.status = .sending
        }
    }

    private func prepareTextBubble() {
        bubbleView.addSubview(textMessageLabel)
        textMessageLabel.isHidden = false

        textMessageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(BUBBLE_PADDING_V)
            make.bottom.equalToSuperview().offset(-BUBBLE_PADDING_V)
            make.leading.equalToSuperview().offset(BUBBLE_PADDING_H)
            make.trailing.equalToSuperview().offset(-BUBBLE_PADDING_H)
        }
    }

    private func prepareImageView() {
        bubbleView.addSubview(pictureView)
        pictureView.isHidden = false

        pictureView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.height.lessThanOrEqualTo(150)
        }
    }
    private func prepareButtonBubble() {
        bubbleView.addSubview(textMessageLabel)
        bubbleView.addSubview(linkButton)
        textMessageLabel.isHidden = false
        linkButton.isHidden = false
        linkButton.setTitleColor(bubbleView.tintColor, for: .normal)
        linkButton.layer.borderColor = bubbleView.tintColor.cgColor

        textMessageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(BUBBLE_PADDING_V)
            make.leading.equalToSuperview().offset(BUBBLE_PADDING_H)
            make.trailing.equalToSuperview().offset(-BUBBLE_PADDING_H)
        }

        linkButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-BUBBLE_PADDING_V)
            make.leading.equalToSuperview().offset(BUBBLE_PADDING_H)
            make.trailing.equalToSuperview().offset(-BUBBLE_PADDING_H)
            make.top.equalTo(textMessageLabel.snp.bottom).offset(BUBBLE_PADDING_I)
            make.height.equalTo(30)
        }
    }

    // MARK: - Prepares specific content

    private func prepareForText() {
        guard let message = message?.value else {return}
        prepareBubble()
        prepareTextBubble()

        textMessageLabel.text = message.contentString
        textMessageLabel.attributedText = message.contentAttributedString
        textMessageLabel.setLabelDataWithAttributedText(textMessageLabel.attributedText)

        if message.isMe {
            textMessageLabel.textColor = .crispDarkNight
        } else {
            textMessageLabel.textColor = .white
        }
    }

    private func prepareForImage() {
        guard let message = message?.value else {return}
        prepareBubble()
        prepareImageView()
        
        self.bubbleView.snp.makeConstraints({ (update) in
            update.height.equalTo(150)
            update.width.equalTo(250)
        })

        if let url = message.contentObject?.url {
            let completeURL = .crispImage + "/process/original/?url=" + url
            pictureView.sd_setShowActivityIndicatorView(true)
            pictureView.sd_setImage(with:  URL(string: completeURL), completed: { (image, _, _, _) in
                self.pictureView.sd_setShowActivityIndicatorView(false)
            })
        }
    }

    private func prepareForAnimation() {
        guard let message = message?.value else {return}
        prepareBubble()
        prepareImageView()

        DispatchQueue.main.async {
            if let url = message.contentObject?.url {
                let completeURL = .crispImage + "/process/original/?url=" + url
                self.pictureView.sd_setShowActivityIndicatorView(true)
                self.pictureView.sd_setIndicatorStyle(.gray)
                self.pictureView.sd_setImage(with: URL(string:completeURL), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload)
            }
        }
        
    }

    private func prepareForFile() {
        guard let message = message?.value else {return}
        prepareBubble()
        prepareButtonBubble()

        textMessageLabel.text = message.contentObject?.name
        linkButton.setTitle(.chat_message_file_button, for: .normal)
        linkButton.url = (message.contentObject?.url)!

        if message.isMe {
            linkButton.layer.borderColor = UIColor.crispDarkNight.cgColor
        } else {
            linkButton.layer.borderColor = UIColor.white.cgColor
        }
    }

    private func prepareForLink() {
        guard let message = message?.value else {return}
        prepareBubble()
        prepareButtonBubble()

        textMessageLabel.text = message.contentString
        linkButton.setTitle(message.preview.first?.title, for: .normal)
        linkButton.url = (message.preview.first?.url)!
        
        if message.isMe {
            linkButton.layer.borderColor = UIColor.crispDarkNight.cgColor
        } else {
            linkButton.layer.borderColor = UIColor.white.cgColor
        }
    }

    // MARK: - Gesture Delegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let localLocation = touches.first?.location(in: self) {
            if bubbleView.frame.contains(localLocation) {
                showTooltip()
            }
        }
    }
    
    // MARK: - Tooltip functions
    
    private func showTooltip() {
        if !tooltipIsShow, let message = self.message?.value, let mainView = UINavigationController().getCurrentViewController()?.view {
            self.tooltip?.dismiss()
            self.tooltip = EasyTipView(text: message.timestamp.shortTimeAgoSinceNow)
            self.tooltip?.show(forView: self.bubbleView, withinSuperview: mainView)
            startThrottleDismissTooltip()
            tooltipIsShow = true
        } else {
            closeTooltip()
        }
    }
    
    func closeTooltip() {
        self.tooltip?.dismiss()
        tooltipTimer?.invalidate()
        tooltipIsShow = false
    }
    
    func closeTooltips() {
        avatar.closeTooltip()
        statusView.closeTooltip()
        self.tooltip?.dismiss()
        tooltipTimer?.invalidate()
        tooltipIsShow = false
    }
    
    func startThrottleDismissTooltip() {
        tooltipTimer?.invalidate()
        tooltipTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(throttleDismissTooltip), userInfo: nil, repeats: false)
    }
    
    @objc func throttleDismissTooltip() {
        closeTooltip()
    }
}
