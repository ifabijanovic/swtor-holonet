//
//  WebViewProtocol.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 27/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

protocol WebViewProtocol: class {
    
    func doSetDelegate(delegate: AnyObject?)
    func load(request: NSURLRequest)
    
    func doReload()
    func doStopLoading()
    func doGoBack()
    func doGoForward()
    
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }
    var loading: Bool { get }
    
    var title: String? { get }
    
    var view: UIView { get }
    
}
