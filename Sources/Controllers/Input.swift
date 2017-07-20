//
//  Input.swift
//  Crisp
//
//  Created by Quentin de Quelen on 26/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SwiftEventBus

class Input: UIView {

    let input: TextView = {
        let textView = TextView()
        textView.autocorrectionType = .yes
        textView.isEditable = true
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.crispTextDark
        textView.layer.cornerRadius = 10
        textView.textContainerInset.left = 10
        textView.autocapitalizationType = .sentences
        textView.placeholderColour = sharedPreferences.color.lighter(by: 0.5)!
        textView.placeholder = .tooltip_entice_form_compose
        return textView
    }()

    let addButton: ActiveButton = {
        let button = ActiveButton()
        button.setImage(.add, for: UIControlState.normal)
        button.setImage(.send, for: UIControlState.active)
        button.addTarget(self, action: #selector(addTouched), for: .touchUpInside)
        return button
    }()

    let smileyButton: ActiveButton = {
        let button = ActiveButton()
        button.setImage(.smiley, for: UIControlState.normal)
        button.setImage(.smileyActive, for: UIControlState.active)
        button.addTarget(self, action: #selector(smileyTouched), for: .touchUpInside)
        return button
    }()

    var parent: UIViewController? = nil
    var picker: InputPicker?
    let progressView: UIProgressView = UIProgressView()
    
    let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(input)
        addSubview(addButton)
        addSubview(smileyButton)
        addSubview(progressView)

        input.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-100)
            make.centerY.equalToSuperview()
        }

        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(40)
        }

        smileyButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(addButton.snp.leading)
            make.width.height.equalTo(40)
        }
        
        progressView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }

        input.becomePlaceholder = {
            self.addButton.active = false
        }

        input.becomeText = {
            self.addButton.active = true
        }
        
        progressView.alpha = 0
        progressView.progressTintColor = sharedPreferences.color
        
        input.rx.text
            .asObservable()
            .throttle(0.7, scheduler: MainScheduler())
            .distinctUntilChanged({ return $0 == $1 })
            .subscribe(onNext: { text in
                if text?.characters.count == 0 {
                    sharedNetwork.messageComposeSend(type: .stop)
                } else {
                    sharedNetwork.messageComposeSend(excerpt: text, type: .start)
                }
            }).addDisposableTo(disposeBag)

        SwiftEventBus.onMainThread(self, name: .eventUploadStart) { _ in
            self.startProgress()
        }
        
        SwiftEventBus.onMainThread(self, name: .eventUploadEnd) { _ in
            self.stopProgress()
        }
        SwiftEventBus.onMainThread(self, name: .eventUploadUpdate) { notif in
            if let progress = notif.object as? Float {
                self.updateProgress(withValue: progress)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: .UIKeyboardWillHide, object: nil)

//        Notification.addObserver(observer: self, selector: #selector(handleTextChange(_:)), notification: .eventChangeInputText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleKeyboardNotification(_ notification: NSNotification) {
        guard notification.name == .UIKeyboardWillHide else {return}
        self.smileyButton.active = false
        self.picker?.isHidden = true
    }
    
    @objc private func handleTextChange(_ notification: NSNotification) {
        input.text = notification.object as? String
    }
    
    // MARK: - Button actions

    @objc func smileyTouched() {
        if smileyButton.active == true {
            smileyButton.active = false
            picker?.isHidden = true
        } else {
            smileyButton.active = true
            picker?.isHidden = false
        }
        input.resignFirstResponder()
    }

    @objc func addTouched() {
        if addButton.active == true {
            sendMessage()
        } else {
            sendFile()
        }
        input.resignFirstResponder()
    }

    func sendFile() {
        System.log("send File", type: .debug)
        showDocumentPicker()
    }

    func sendMessage() {
        System.log("send Message", type: .debug, "text is : \(input.text!)")
        let message = Message()
        message.contentString = input.text!
        message.isMe = true
        sharedNetwork.messageSend(message: message)
        sharedNetwork.messageComposeSend(type: .stop)
        if sharedStore.messages.value.count == 0 || (sharedStore.messages.value.count == 1 && sharedStore.messages.value[0]?.isMe == false) {
            CrispNotifier.post(.eventChatInitiated)
        }
        sharedStore.add(message: message)
        input.text = ""
        input.resignFirstResponder()
    }
    
    // MARK: - Upload progress
    
    func startProgress() {
        progressView.setProgress(0.0, animated: true)
        UIView.animate(withDuration: 0.3) {
            self.progressView.alpha = 1
        }
    }
    
    func updateProgress(withValue progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
    
    func stopProgress() {
        UIView.animate(withDuration: 0.3) {
            self.progressView.alpha = 0
        }
    }

}


extension Input: UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func showDocumentPicker() {
        
        self.endEditing(true)
        var alert: UIAlertController? = nil
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        }

        alert?.addAction(UIAlertAction(title: .actionSheetCamera, style: .default) { _ in
            self.openCameraPicker()
        })
        alert?.addAction(UIAlertAction(title: .actionSheetLibrary, style: .default) { _ in
            self.openImagePicker()
        })

        // TODO: I don't know hot to get the capabilities to the current application to tell if i should show Document picker or not
        alert?.addAction(UIAlertAction(title: .actionSheetCloud, style: .default) { _ in
            self.openDocumentPicker()
        })

        alert?.addAction(UIAlertAction(title: .actionSheetCancel, style: .cancel))
        parent?.present(alert!, animated: true, completion: nil)
    }

    func openDocumentPicker() {
        
        let documentsTypes = [
            "public.text",
            "public.data",
            "public.pdf",
            "public.doc"
        ]
        
        let importMenu = UIDocumentMenuViewController(documentTypes: documentsTypes, in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .popover
        importMenu.popoverPresentationController?.sourceView = self.addButton
        parent?.present(importMenu, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        sharedStore.sendFile(url.absoluteString)
    }

    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        parent?.present(documentPicker, animated: true, completion: nil)
    }

    func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
        documentMenu.dismiss(animated: true, completion: nil)
    }

    func openCameraPicker() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .overFullScreen
        parent?.present(imagePicker, animated: true, completion: nil)
    }


    func openImagePicker() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .overFullScreen
        parent?.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let compressedImage = UIImageJPEGRepresentation(image, 0.8)
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        let longUUID = UUID().uuidString
        let uuid = longUUID.substring(to: longUUID.index(longUUID.startIndex, offsetBy: 4))
        let filename = "ios-camera-\(uuid).jpg"
        
        
        let filePath = "file://" + path + "/" + filename
        if let urlFilePath = URL(string: filePath) {
            do {
                try compressedImage?.write(to: urlFilePath)
            } catch let e {
                System.log(e.localizedDescription, type: .error)
            }
        }

        sharedStore.sendFile(filePath)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }

}

extension Input: EmojiPickerDelegate, GifsPickerDelegate {
    func injectEmoji(_ emoji: String) {
        if input.isPlaceholder {
            input.text = emoji
        } else {
            input.text?.append(emoji)
        }
        smileyButton.active = true
        addButton.active = true
        smileyTouched()
        input.becomeFirstResponder()
    }

    func sendGif(_ gifURL: String) {
        let message = Message()
        message.type = .animation
        message.contentObject = MessageContent()
        message.contentObject?.type = "image/gif"
        message.contentObject?.name = "GIF"
        message.contentObject?.url = gifURL
        message.isMe = true

        sharedNetwork.messageSend(message: message)
        sharedStore.add(message: message)
        smileyButton.active = true
        addButton.active = true
        smileyTouched()
    }
}
