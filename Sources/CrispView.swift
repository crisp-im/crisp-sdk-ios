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
        CrispView.webView?.dataDetectorTypes = .all;
        CrispView.webView?.scalesPageToFit = true;
        CrispView.webView?.contentMode = .scaleAspectFit;
        CrispView.webView?.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        guard let webView = CrispView.webView else { return }
        
        webView.frame = bounds
        webView.center = center
    }
    
    override open func removeFromSuperview() {
        guard let webView = CrispView.webView else { return }
        
        CrispView.isLoaded = false
        
        webView.removeFromSuperview()
        
        CrispView.webView = nil
        
        super.removeFromSuperview()
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        CrispView.isLoaded = true
        CrispView.flushQueue()
    }
    
    @available(iOS 10.0, *)
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (request.url?.scheme == "tel") {
            UIApplication.shared.open(request.url!)
            return false
        }
        
        return true
    }
    
    func loadWebView() {
        guard let webView = CrispView.webView else { return }
        
        var frameworkBundle = Bundle(for: CrispView.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("Crisp.bundle")
        let bundle = Bundle.init(url: bundleURL!)

        var filePath: String? = bundle?.path(forResource: "index", ofType: "html")
        
        if (filePath == nil) {
            frameworkBundle = Bundle(for: type(of: self))
            filePath = frameworkBundle.path(forResource: "assets/index", ofType: "html")
        }

        let urlPath =  URL(fileURLWithPath: filePath!)

        webView.loadRequest(URLRequest(url: urlPath))
        
        if (Crisp.tokenId != nil && Crisp.tokenId != "") {
            CrispView.execute(script: "window.CRISP_TOKEN_ID = \"" + Crisp.tokenId + "\";");
        }
        
        CrispView._load()
    }
    
    static func _load() {
        if Crisp.websiteId == nil {
            print("=====================================")
            print("Warning. Please initiate the Crisp SDK from your AppDelegate")
            print("=====================================")
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
