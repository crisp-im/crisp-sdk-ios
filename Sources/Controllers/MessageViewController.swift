//
//  MessageViewController.swift
//  Crisp
//
//  Created by Quentin de Quelen on 20/04/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import SwiftEventBus
import Lightbox

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    var messages: [Variable<Message>] = []
    private var __messages: Observable<[Int:Message]>?
    var compose: Bool = false
    private var __compose: Observable<Bool>?

    private var messageReuseIdentifier = "MessageBubbleReuseIdentifier"
    private var composeReuseIdentifier = "ComposeBubbleReuseIdentifier"
    private var initialFrame: CGRect?
    private let disposeBag: DisposeBag = DisposeBag()
    fileprivate var canCloseTooltip = true

    let tableView: UITableView = UITableView()
    let input: Input = Input()
    let inputPicker: InputPicker = InputPicker()

    override func loadView() {
        super.loadView()
        setupView()
        __messages = sharedStore.messages.asObservable()
        __compose = sharedStore.compose.asObservable()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        System.log("open Message View", type: .verbose)
        setupNavbar()
        __messages?.subscribe(onNext: { messages  in
            System.log("list of message have changed", type: .debug)
            
            let previousCount = self.messages.count
            if previousCount == 0 || previousCount == 1{
                self.setupOperatorNavBar()
            }
            let newCount = messages.count
            let diff = newCount - previousCount
            
            let indexes: [IndexPath] = (0..<diff).map({ (num) -> IndexPath in
                return IndexPath(row: self.messages.count + num , section: 0)
            })
            let lastIndex = IndexPath(row: self.messages.count - 1 , section: 0)
            
            self.messages = sharedStore.messages.value
                .sorted(by: {
                    return $0.value.timestamp < $1.value.timestamp
                }).map({
                    return Variable<Message>($0.value)
                })
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexes, with: .fade)
            self.tableView.reloadRows(at: [lastIndex], with: .none)
            self.tableView.endUpdates()
            self.scrollToBottom(animated: false)
            
        }).addDisposableTo(disposeBag)
        
        __compose?.subscribe(onNext: { (_compose) in
            if _compose != self.compose {
                self.compose = _compose
                self.tableView.beginUpdates()
                if _compose {
                    self.tableView.insertSections([1], with: .left)
                } else {
                    self.tableView.deleteSections([1], with: .left)
                }
                self.tableView.endUpdates()
                self.scrollToBottom(animated: false)
            }
        }).addDisposableTo(disposeBag)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: .UIKeyboardWillHide, object: nil)
        
        if UIApplication.shared.keyWindow?.traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        } else {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(recognizer:)))
            tableView.addGestureRecognizer(longPress)
        }
        
        SwiftEventBus.onMainThread(self, name: .eventWebsiteAvailabilityChanged) { (notification) in
            if let userAvailable = sharedStore.session?.usersAvailable, userAvailable {
                self.setupOperatorNavBar()
            } else {
                self.setupDefautNavBar()
            }
        }
        
        self.scrollToBottom(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        initialFrame = view.frame
        
        input.input.alignContentHorizontaly()
        self.scrollToBottom(animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        scrollToBottom(animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    deinit {

    }

    private func setupView() {
        view.addSubview(tableView)
        view.addSubview(input)
        view.insertSubview(inputPicker, belowSubview: input)

        tableView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-60)
        }

        inputPicker.snp.makeConstraints { (make) in
            make.bottom.equalTo(input.snp.top)
            make.leading.trailing.equalToSuperview()
        }

        input.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(60)
        }

        tableView.backgroundColor = UIColor(hex: "f5f8fb")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.register(MessageBubble.self, forCellReuseIdentifier: messageReuseIdentifier)
        tableView.register(ComposeBubble.self, forCellReuseIdentifier: composeReuseIdentifier)

        input.parent = self
        input.picker = inputPicker
        input.picker?.gifsPicker.delegate = input
        input.picker?.emojiPicker.delegate = input
    }

    private func setupNavbar() {

        if messages.count == 0 {
            setupDefautNavBar()
        } else {
            setupOperatorNavBar()
        }
        
    }
    
    @objc func setupDefautNavBar() {
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = sharedPreferences.color
            print(sharedPreferences.color)
            navigationBar.isTranslucent = false
            navigationBar.tintColor = .white
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }
        
        if let session = sharedStore.session,
            let mean = session.responseMetrics?.mean,
            let last = session.responseMetrics?.last {
            if session.usersAvailable {
                if mean == 0 {
                    navigationItem.titleView = NavbarTitleView()
                        .set(color: .white)
                        .set(title: sharedPreferences.themeText)
                        .set(prompt: .chat_header_ongoing_status_online)
                } else {
                    let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(mean / 1000)).shortTimeAgoSinceNow
                    navigationItem.titleView = NavbarTitleView()
                        .set(color: .white)
                        .set(title: sharedPreferences.themeText)
                        .set(prompt: String(format: .chat_header_ongoing_status_metrics, date))
                }
            } else {
                if last == 0 {
                    navigationItem.titleView = NavbarTitleView()
                        .set(color: .white)
                        .set(title: sharedPreferences.themeText)
                        .set(prompt: String(format: .chat_header_ongoing_status_away))
                } else {
                    let date = Date(timeIntervalSince1970: TimeInterval(last/1000)).shortTimeAgoSinceNow
                    navigationItem.titleView = NavbarTitleView()
                        .set(color: .white)
                        .set(title: sharedPreferences.themeText)
                        .set(prompt: String(format: .chat_header_ongoing_status_last, date))
                }
            }
        }
        let closeImage = UIImage(named: "CloseButton", in: Bundle(identifier: "im.crisp.crisp-sdk"), compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(dissmissView))
        
        let operatorImage = UIImage(named: "operators", in: Bundle(identifier: "im.crisp.crisp-sdk"), compatibleWith: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: operatorImage, style: .plain, target: self, action: #selector(setupTeamNavBar))
        if sharedStore.session!.activeOperators.count == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func setupTeamNavBar() {
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = .white
            navigationBar.tintColor = sharedPreferences.color
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: sharedPreferences.color]
        }
        navigationItem.titleView = NavbarOperatorsListView().set(operators: sharedStore.session!.activeOperators)
        let closeImage = UIImage(named: "CloseButton", in: Bundle(identifier: "im.crisp.crisp-sdk"), compatibleWith: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(setupDefautNavBar))
        navigationItem.leftBarButtonItem = nil
    }
    
    func setupOperatorNavBar() {
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = sharedPreferences.color
            navigationBar.tintColor = .white
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }
        
        if let company = sharedStore.session?.website, let op = sharedStore.session?.activeOperators.first {
            let title: String = (op.nickname.components(separatedBy: " ").first ?? op.nickname) + " " + .chat_header_ongoing_from + " " + company
            navigationItem.titleView = NavbarTitleView().set(color: .white)
                .set(title: title)
                .set(prompt: .chat_header_ongoing_status_online)
        } else if let company = sharedStore.session?.website {
            navigationItem.titleView = NavbarTitleView().set(color: .white)
                .set(title: company)
                .set(prompt: .chat_header_ongoing_status_away)
        }
        let closeImage = UIImage(named: "CloseButton", in: Bundle(identifier: "im.crisp.crisp-sdk"), compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(dissmissView))

        navigationItem.rightBarButtonItem = nil
    }


    @objc private func dissmissView() {
        self.dismiss(animated: true, completion: {
            sharedChatbox.state = .close
            System.log("message View closed", type: .verbose)
        })
    }

    @objc private func handleKeyboardNotification(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            guard notification.name == .UIKeyboardWillShow || notification.name == .UIKeyboardWillHide else {return}
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

            var newFrame:CGRect = view.frame
            if notification.name == .UIKeyboardWillShow {
                newFrame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: initialFrame!.height - keyboardFrame.height)
            } else if notification.name == .UIKeyboardWillHide {
                newFrame = initialFrame!
            }
            view.frame = newFrame

            UIView.animate(withDuration: 0.0, delay: 0, options: .curveLinear, animations: {
                self.view.layoutIfNeeded()
            })
            self.scrollToBottom()
        }
    }
    
    func scrollToBottom(animated: Bool = true) {
        if compose {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: animated)
        } else if messages.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: animated)
            }
        }
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return messages.count
        } else {
            return compose ? 1 : 0
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: composeReuseIdentifier, for: indexPath) as! ComposeBubble
            cell.layoutIfNeeded()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: messageReuseIdentifier, for: indexPath) as! MessageBubble
        if indexPath.row == messages.count - 1 {
            cell.isLast =  true
        }
        if indexPath.row + 1 <= messages.count - 1 && messages[indexPath.row].value.user?.nickname != messages[indexPath.row + 1].value.user?.nickname {
            cell.hideAvatar = false
            cell.lastOfGroup = true
        } else if indexPath.row == messages.count - 1 {
            cell.hideAvatar = false
            cell.lastOfGroup = true
        } else {
            cell.hideAvatar = true
        }
        
        if messages[indexPath.row].value.isMe {
            cell.hideAvatar = true
        }
        cell.message = self.messages[indexPath.row]
        cell.layoutIfNeeded()
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return compose ? 2 : 1
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard indexPath.section == 0 else {
//            return 50
//        }
//        return messages[indexPath.row].value.getHeight()
//    }

}

// MARK: - UIScrollViewDelegate

extension MessageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if canCloseTooltip {
            canCloseTooltip = false
            tableView.visibleCells.forEach { (cell) in
                if let cell = cell as? MessageBubble {
                    cell.closeTooltips()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.canCloseTooltip = true
            })
        }
    }
}


// MARK: - 3D Touch

extension MessageViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let location = CGPoint(x: location.x, y: location.y + tableView.contentOffset.y)
        print(location)
        
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard input.smileyButton.active == false else { return nil }
        
        let message = self.messages[indexPath.row].value
        
        guard message.type == .file else { return nil }
        guard message.contentObject?.type?.range(of: "image") != nil else { return nil }
        guard location.x >= 60 && location.x < view.frame.maxX - 30 else { return nil }

        let previewSize = min(view.frame.width, view.frame.height) * 0.8
        
        let previewer = MessagePreview(frame: CGRect(x: 0, y: 0, width: previewSize, height: previewSize))
        previewer.message = message
        return previewer
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let message = (viewControllerToCommit as! MessagePreview).message {
            showPhotoViewer(withCurrent: message)
        }
    }
    
    @objc func longPressHandler(recognizer: UILongPressGestureRecognizer)
    {
        let location = recognizer.location(in: self.tableView)
        guard location.x >= 60 && location.x < view.frame.maxX - 30 else { return }
        guard let indexPath = tableView.indexPathForRow(at: location) else { return }
        
        let message = self.messages[indexPath.row].value
        
        guard recognizer.state == .began else { return }
        guard message.type == .file else { return }
        guard message.contentObject?.type?.range(of: "image") != nil else { return }
        
        showPhotoViewer(withCurrent: message)
    }
    
    func showPhotoViewer(withCurrent message: Message) {
        guard let url = message.contentObject?.url else { return }
        var index: Int = 0
        var count: Int = 0
        let images: [LightboxImage] = messages.flatMap({ _message -> LightboxImage? in
            
            guard _message.value.type == .file else { return nil }
            guard message.contentObject?.type?.range(of: "image") != nil else { return nil }
            guard let _url = _message.value.contentObject?.url else { return nil }
            guard let _name = _message.value.contentObject?.name else { return nil }
            
            if _url == url {
                index = count
            }
            count += 1
            
            return LightboxImage(imageURL: URL(string: _url)!, text: _name, videoURL: nil)
        })
        let controller = LightboxController(images: images, startIndex: index)
        present(controller, animated: true, completion: nil)
    }
}
