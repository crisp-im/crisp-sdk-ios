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

open class CrispView: UIView, UIWebViewDelegate {
    static var webView: UIWebView?
    static var commandQueue: [String] = []
    static var isLoaded = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        CrispView.webView = UIWebView()
        addSubview(CrispView.webView!)
        
        loadWebView()
       
        CrispView.webView?.scrollView.isScrollEnabled = false;
        CrispView.webView?.scalesPageToFit = true;
        CrispView.webView?.contentMode = .scaleAspectFit;
        CrispView.webView?.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        CrispView.webView?.frame = bounds
        CrispView.webView?.center = center
    }
    
    override open func removeFromSuperview() {
        CrispView.isLoaded = false
        super.removeFromSuperview()
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        CrispView.isLoaded = true
        CrispView.flushQueue()
    }
    
    
    func loadWebView() {
        var frameworkBundle = Bundle(for: CrispView.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("Crisp.bundle")
        let bundle = Bundle.init(url: bundleURL!)

        var filePath: String? = bundle?.path(forResource: "index", ofType: "html")
        
        if (filePath == nil) {
            print("filePath nil")
            frameworkBundle = Bundle(for: type(of: self))
            print(frameworkBundle)
            filePath = frameworkBundle.path(forResource: "assets/index", ofType: "html")
        }

        let urlPath =  URL(string: filePath!)

        CrispView.webView?.loadRequest(URLRequest(url: urlPath!))
        
        if (Crisp.tokenId != "") {
            CrispView.execute(script: "window.CRISP_TOKEN_ID = \"" + Crisp.tokenId + "\";");
        }
        
        CrispView.execute(script: "window.CRISP_WEBSITE_ID = \"" + Crisp.websiteId + "\";");
        CrispView.execute(script: "initialize()");
    }
    
    static func execute(script: String) {
        commandQueue.append(script)
        
        if (isLoaded) {
            flushQueue()
        }
    }
    
    static func flushQueue() {
        for script in commandQueue {
            callJavascript(script: script)
        }
        commandQueue = []
    }
    
    static func callJavascript(script: String) {
        guard let webView =  CrispView.webView else { return }
        webView.stringByEvaluatingJavaScript(from: script)
    }
}
