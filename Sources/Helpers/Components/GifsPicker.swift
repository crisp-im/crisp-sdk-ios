//
//  GifsPicker.swift
//  Crisp
//
//  Created by Quentin de Quelen on 03/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import SDWebImage

fileprivate class GifsCell: UICollectionViewCell {

    var gifURL: String = "" {
        didSet {
            let completeURL = .crispImage + "/process/original/?url=" + gifURL
            image.sd_setShowActivityIndicatorView(true)
            image.sd_setIndicatorStyle(.gray)
            image.sd_setImage(with: URL(string:completeURL), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload)
        }
    }

    let image: FLAnimatedImageView = {
        let image = FLAnimatedImageView()
        image.contentMode = .scaleAspectFill
        image.layer.shadowColor = UIColor.darkGray.cgColor
        image.layer.shadowOffset = CGSize(width: 0, height: -2)
        image.layer.shadowRadius = 3
        return image
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(image)

        image.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        layer.cornerRadius = 6
        backgroundColor = .crispLightNight
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        gifURL = ""
        image.image = nil
        image.animationImages = []
    }
}

protocol GifsPickerDelegate: class {

    func sendGif(_: String)

}

class GifsPicker: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIGestureRecognizerDelegate {

    let reuseIdentifier = "cell"

    var gifs: [String] = []
    
    var currentGifPage: Int = 1
    var query: String = "" {
        didSet {
            currentGifPage = 1
            sharedStore.gifs.value = []
            downloadNewGifs()
        }
    }

    weak var delegate: GifsPickerDelegate?

    var collectionView: UICollectionView!
    let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()

        gifs = sharedStore.gifs.value
        collectionView.reloadData()

        sharedStore.getGifs().subscribe(onNext: { (gifs) in
            self.gifs = gifs
            self.collectionView.reloadData()
        }).addDisposableTo(disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.register(GifsCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = true
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        self.addSubview(collectionView)
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gifs.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! GifsCell
        
        if indexPath.row == gifs.count - 1 {
            currentGifPage += 1
            downloadNewGifs()
        }
        let url = gifs[indexPath.row]
        cell.gifURL = url
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = (collectionView.cellForItem(at: indexPath) as! GifsCell)
        let image = cell.image
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
            image.layer.shadowOpacity = 0.2
            cell.layoutIfNeeded()
        }, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = (collectionView.cellForItem(at: indexPath) as! GifsCell)
        let image = cell.image
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
            image.layer.shadowOpacity = 0
            cell.layoutIfNeeded()
        }, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let description = gifs[indexPath.row]
        delegate?.sendGif(description)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 70)
    }
    
    func downloadNewGifs() {
        if !query.isEmpty {
            sharedNetwork.mediaAnimationList(page: currentGifPage, query: query)
        } else {
            sharedNetwork.mediaAnimationList(page: currentGifPage)
        }
    }
}
