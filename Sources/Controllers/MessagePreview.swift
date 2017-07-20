//
//  MessagePreview.swift
//  Crisp
//
//  Created by Quentin de Quelen on 20/05/2017.
//  Copyright © 2017 crisp.chat. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class MessagePreview: UIViewController {
    
    let imageView = UIImageView()
    
    var message: Message? {
        didSet {
            guard let message = message else {return}
            
            if let imageURl = message.contentObject?.url {
                imageView.sd_setShowActivityIndicatorView(true)
                imageView.sd_setImage(with: URL(string: imageURl), completed: { (image, _, _, _) in
                    self.imageView.sd_setShowActivityIndicatorView(false)
                })
            }
        }
    }
    
    required init(frame: CGRect) {
        
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        imageView.contentMode = .scaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
