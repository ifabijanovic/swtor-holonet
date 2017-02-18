//
//  WebViewProtocol.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 27/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

// Not used because of a bug with protocol extension in Swift 1.2 and iOS SDK 8.3
// See WebViewEx.swift file for more info

//import Foundation
//
//protocol WebViewProtocol: class {
//    
//    var URL: NSURL? { get }
//    
//    func doSetDelegate(delegate: AnyObject?)
//    func load(request: NSURLRequest)
//    
//    func doReload()
//    func doStopLoading()
//    func doGoBack()
//    func doGoForward()
//    
//    var canGoBack: Bool { get }
//    var canGoForward: Bool { get }
//    var loading: Bool { get }
//    
//    var title: String? { get }
//    
//    var view: UIView { get }
//    
//}
