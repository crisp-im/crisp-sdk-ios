//
//  CrispView.swift
//  Crisp
//
//  Created by Baptiste Jamin on 29/12/2017.
//  Copyright © 2017 crisp.im. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SnapKit

open class CrispView: UIView {
    var webView: WKWebView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
   
        addSubview(webView)
        
        loadWebView()
       
        webView.scrollView.isScrollEnabled = false;
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        webView.frame = bounds
        webView.center = center
    }
    
    
    func loadWebView() {
        let url = URL(string: "https://go.crisp.chat/chat/embed/?website_id="+Crisp.websiteId)
        webView.load(URLRequest(url: url!))
        /*let bundle = Bundle(for: CrispView.self)
        //print(bundle)
        
        let filePath: String? = bundle.path(forResource: "assets/index", ofType: "html")
  
        let url = URL(string: filePath!);
        let myRequest = NSURLRequest(url: url!);
        print(myRequest)
        
        do {
            //let content = try String(contentsOf: url!, encoding: .utf8)
            let content = try String(contentsOfFile: filePath!)
            print(content)
            webView.loadHTMLString(content, baseURL: nil)
        }
        catch {/* error handling here */}
        
        //webView.load(myRequest as URLRequest);
        //webView.load(URLRequest(url: url!))*/
    }
    
}
