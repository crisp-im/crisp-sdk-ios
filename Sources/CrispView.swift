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

open class CrispView: UIView, WKUIDelegate, WKNavigationDelegate {
    static var webView: WKWebView?
    static var commandQueue: [String] = []
    static var isLoaded = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        CrispView.webView = WKWebView()
        CrispView.webView?.navigationDelegate = self
        
        CrispView.webView?.uiDelegate = self
        addSubview(CrispView.webView!)
        
        loadWebView()
       
        CrispView.webView?.scrollView.isScrollEnabled = false;
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
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        CrispView.isLoaded = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            CrispView.flushQueue()
        })
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            if url.description.lowercased().range(of: "http://") != nil ||
                url.description.lowercased().range(of: "https://") != nil ||
                url.description.lowercased().range(of: "mailto:") != nil {
                
                UIApplication.shared.open(url)
            }
        }
        return nil
    }

    
    func loadWebView() {
        CrispView._load()
    }
    
    static func _load() {
        if Crisp.websiteId == nil {
            print("=====================================")
            print("Warning. Please initiate the Crisp SDK from your AppDelegate")
            print("=====================================")
            return
        }
        var crispURL = "https://go.crisp.chat/chat/embed/?website_id="
        
        crispURL += Crisp.websiteId
        
        if (Crisp.tokenId != nil && Crisp.tokenId != "") {
            crispURL += "&token_id=" + Crisp.tokenId
        }
        
        if (Crisp.locale != nil && Crisp.locale != "") {
            crispURL += "&locale=" + Crisp.locale
        }
        
        webView?.load(URLRequest(url: URL(string: crispURL)!))
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

        print(script)
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
}
