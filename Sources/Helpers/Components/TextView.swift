//
//  UITextView.swift
//  Crisp
//
//  Created by Quentin de Quelen on 26/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit
import RxSwift

class TextView: UITextView {

    var placeholderColour: UIColor = UIColor(red: 0, green: 0, blue: 0.098, alpha: 0.22)

    var placeholder:String?{
        didSet{
            if let placeholder = placeholder{
                text = placeholder
            }
        }
    }

    var isPlaceholder: Bool = true

    var becomePlaceholder: (()->())? = nil
    var becomeText: (()->())? = nil
    
    var numberOfSpaces = Variable<Int>(-1)
    var rx_text = Variable<String>("")

    override internal var text: String? {
        didSet{
            textColor = tintColor
            if text == placeholder{
                textColor = placeholderColour
                isPlaceholder = true
                rx_text.value = ""
            } else {
                isPlaceholder = false
                rx_text.value = text ?? ""
            }
        }
    }

    override internal var textColor: UIColor?{
        didSet{
            if let textColor = textColor, textColor != placeholderColour{
                tintColor = textColor
                if text == placeholder{
                    self.textColor = placeholderColour
                }
            }
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        // Remove the padding top and left of the text view
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = UIEdgeInsets.zero

        // Listen for text view did begin editing
        NotificationCenter.default.addObserver(self, selector: #selector(removePlaceholder), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        // Listen for text view did end editing
        NotificationCenter.default.addObserver(self, selector: #selector(addPlaceholder), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChange), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        self.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        alignContentHorizontaly()
    }

    @objc private func removePlaceholder(){
        if text == placeholder {
            text = ""
            becomeText?()
        }
    }

    @objc private func addPlaceholder(){
        if text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            text = placeholder
            becomePlaceholder?()
        }
    }
    
    @objc private func textChange() {
        let nb = text?.components(separatedBy: " ").count
        if text?.characters.count == 0 {
            numberOfSpaces.value = -1
            alignContentHorizontaly()
        } else if let _nb = nb, _nb != numberOfSpaces.value {
            numberOfSpaces.value = _nb
        }
        if text?.characters.count == 1 {
            alignContentHorizontaly()
        }
        rx_text.value = text ?? ""
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        alignContentHorizontaly()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        self.removeObserver(self, forKeyPath: "contentSize")
    }
    
    func numberOfWord() -> Observable<Int> {
        return numberOfSpaces.asObservable()
    }
    
    func alignContentHorizontaly() {
        var top = (bounds.size.height - contentSize.height * zoomScale) / 2.0
        top = top < 0.0 ? 0.0 : top
        self.setContentOffset(CGPoint(x: contentOffset.x, y: -top), animated: true)
    }
}
