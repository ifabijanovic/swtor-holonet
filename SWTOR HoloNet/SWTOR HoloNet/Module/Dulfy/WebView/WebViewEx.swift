//
//  WebViewEx.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 27/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView: WebViewProtocol {
    
    func doSetDelegate(delegate: AnyObject?) {
        self.navigationDelegate = delegate as? WKNavigationDelegate
        self.UIDelegate = delegate as? WKUIDelegate
    }
    
    func load(request: NSURLRequest) {
        self.loadRequest(request)
    }
    
    func doReload() {
        self.reload()
    }
    
    func doStopLoading() {
        self.stopLoading()
    }
    
    func doGoBack() {
        self.goBack()
    }
    
    func doGoForward() {
        self.goForward()
    }
    
    var view: UIView {
        return self
    }
    
}

extension UIWebView: WebViewProtocol {
    
    func doSetDelegate(delegate: AnyObject?) {
        self.delegate = delegate as? UIWebViewDelegate
    }
    
    func load(request: NSURLRequest) {
        self.loadRequest(request)
    }
    
    func doReload() {
        self.reload()
    }
    
    func doStopLoading() {
        self.stopLoading()
    }
    
    func doGoBack() {
        self.goBack()
    }
    
    func doGoForward() {
        self.goForward()
    }
    
    var title: String? {
        return self.stringByEvaluatingJavaScriptFromString("document.title")
    }
    
    var view: UIView {
        return self
    }
    
}
