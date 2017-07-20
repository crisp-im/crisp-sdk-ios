//
//  EmojiPicker.swift
//  Crisp
//
//  Created by Quentin de Quelen on 03/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

fileprivate class EmojiCell: UICollectionViewCell {

    let image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.shadowColor = UIColor.darkGray.cgColor
        image.layer.shadowOffset = CGSize(width: 0, height: -2)
        image.layer.shadowRadius = 4
        return image
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(image)

        image.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol EmojiPickerDelegate: class {

    func injectEmoji(_: String)
    
}

class EmojiPicker: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIGestureRecognizerDelegate {

    let reuseIdentifier = "cell"

    let smileys: [[String]] = [
        ["angry", ":( "],
        ["big-smile", ":D "],
        ["blushing", ":$ "],
        ["confused", "x) "],
        ["cool", "8) "],
        ["crying", ":'( "],
        ["embarrased", ":/ "],
        ["heart", "<3 "],
        ["laughing", ":'D "],
        ["sad", ":( "],
        ["sick", ":S "],
        ["small-smile", ":) "],
        ["surprised", ":o "],
        ["thumbs-up", "+1 "],
        ["tongue", ":P "],
        ["winking", ";) "]
    ]

    weak var delegate: EmojiPickerDelegate?

    var collectionView: UICollectionView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = true
        collectionView.isPagingEnabled = true
        self.addSubview(collectionView)
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.smileys.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! EmojiCell
        let name = smileys[indexPath.row][0]
        let image = UIImage(named: name, in: Bundle(for: CrispMain.self), compatibleWith: nil)
        cell.image.image = image
        cell.backgroundColor = .white

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = (collectionView.cellForItem(at: indexPath) as! EmojiCell)
        let image = cell.image
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
            image.layer.shadowOpacity = 0.2
            cell.layoutIfNeeded()
        }, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = (collectionView.cellForItem(at: indexPath) as! EmojiCell)
        let image = cell.image
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
            image.layer.shadowOpacity = 0
            cell.layoutIfNeeded()
        }, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let description = smileys[indexPath.row][1]
        delegate?.injectEmoji(description)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 35, height: 35)
    }
}
