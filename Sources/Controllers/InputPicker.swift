//
//  InputPicker.swift
//  Crisp
//
//  Created by Quentin de Quelen on 02/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class InputPicker: UIView {

    let segementControl: SegmentedControl = {
        let sc = SegmentedControl()
        sc.items = [.chat_pickers_selector_smileys, .chat_pickers_selector_gifs]
        return sc
    }()
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = .chat_pickers_gif_search
        sb.searchBarStyle = .minimal
        sb.barTintColor = .clear
        sb.backgroundColor = .clear
        sb.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        return sb
    }()

    let emojiPicker = EmojiPicker()
    let gifsPicker = GifsPicker()

    let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
        prepareConstraints()
        prepareObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareView() {
        backgroundColor = .white
        isHidden = true
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.1

        addSubview(segementControl)
        addSubview(searchBar)
        addSubview(emojiPicker)
        addSubview(gifsPicker)

        searchBar.rx.text
            .asObservable()
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { query in
                self.gifsPicker.query = query ?? ""
            })
            .addDisposableTo(disposeBag)
    }

    private func prepareConstraints() {
        segementControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(segementControl.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        emojiPicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(segementControl.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-10)
        }
        gifsPicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }

        self.snp.makeConstraints { (make) in
            make.height.equalTo(170)
        }
    }

    private func prepareObservers() {
        segementControl.selectedIndex.asObservable().subscribe(onNext: { index in
            if index == 0 {
                self.prepareEmoji()
            } else {
                self.prepareGifs()
            }
        }).addDisposableTo(disposeBag)
    }

    private func prepareEmoji() {
        self.snp.updateConstraints({ (update) in
            update.height.equalTo(170)
        })
        self.searchBar.isHidden = true
        emojiPicker.isHidden = false
        gifsPicker.isHidden = true
    }

    private func prepareGifs() {
        self.snp.updateConstraints({ (update) in
            update.height.equalTo(190)
        })
        self.searchBar.isHidden = false
        emojiPicker.isHidden = true
        gifsPicker.isHidden = false
    }
}
