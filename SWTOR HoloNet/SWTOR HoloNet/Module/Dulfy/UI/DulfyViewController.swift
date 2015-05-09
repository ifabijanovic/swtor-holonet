//
//  DulfyViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 26/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import WebKit
import Parse

// Workaround solution implemented because of a bug with protocol extension in Swift 1.2 and iOS SDK 8.3
// See WebViewEx.swift file for more info

class DulfyViewController: UIViewController, Injectable, Themeable, ActionPerformer, UIWebViewDelegate, WKNavigationDelegate {
    
    
    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    var alertFactory: AlertFactory!
    
    let useWebKit = objc_getClass("WKWebView") != nil
    
    var wkWebView: WKWebView?
    var uiWebView: UIWebView?
    
    var homeUrl: NSURL {
        get {
            return NSURL(string: self.settings.dulfyNetUrl)!
        }
    }
    var url: NSURL?
    
    var isVisible = false
    
    // MARK: - Outlets
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    
    @IBAction func backTapped(sender: AnyObject) {
        if self.useWebKit {
            self.wkWebView!.goBack()
        } else {
            self.uiWebView!.goBack()
        }
    }
    
    @IBAction func forwardTapped(sender: AnyObject) {
        if self.useWebKit {
            self.wkWebView!.goForward()
        } else {
            self.uiWebView!.goForward()
        }
    }
    
    @IBAction func reloadTapped(sender: AnyObject) {
        if self.useWebKit {
            self.wkWebView!.reload()
        } else {
            self.uiWebView!.reload()
        }
    }
    
    @IBAction func stopTapped(sender: AnyObject) {
        if self.useWebKit {
            self.wkWebView!.stopLoading()
            self.navigationItem.title = self.wkWebView!.title
            self.backButton.enabled = self.wkWebView!.canGoBack
            self.forwardButton.enabled = self.wkWebView!.canGoForward
        } else {
            self.uiWebView!.stopLoading()
            self.navigationItem.title = self.uiWebView!.stringByEvaluatingJavaScriptFromString("document.title")
            self.backButton.enabled = self.uiWebView!.canGoBack
            self.forwardButton.enabled = self.uiWebView!.canGoForward
        }
        
        self.activityIndicator.stopAnimating()
    }
    
    @IBAction func homeTapped(sender: AnyObject) {
        self.navigateTo(self.homeUrl)
    }
    
    @IBAction func safariTapped(sender: AnyObject) {
        if self.useWebKit {
            if let url = self.wkWebView!.URL {
                UIApplication.sharedApplication().openURL(url)
            }
        } else {
            if let url = self.uiWebView!.request?.URL {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()
        
        self.applyTheme(self.theme)
        
        // Initially user cannot navigate back or forward so disable the buttons
        self.backButton.enabled = false
        self.forwardButton.enabled = false
        
        self.setupWebView()
        
        // Initial navigation, custom url if set, fallback to home page
        let url = self.url != nil ? self.url! : self.homeUrl
        self.navigateTo(url)
        self.url = nil
        
        // Enable hide actions on navigation controller if they are available
        if self.useWebKit {
            if let navController = self.navigationController {
                navController.hidesBarsOnSwipe = true
                navController.hidesBarsWhenVerticallyCompact = true
                navController.hidesBarsWhenKeyboardAppears = true
            }
        }
        
        #if !DEBUG && !TEST
            // Analytics
            PFAnalytics.trackEvent("dulfy")
        #endif
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.useWebKit {
            self.wkWebView!.navigationDelegate = self
        } else {
            self.uiWebView!.delegate = self
        }
        self.isVisible = true
        
        // Navigate to custom url if set
        if self.url != nil {
            self.navigateTo(self.url!)
            self.url = nil
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if self.useWebKit {
            self.wkWebView!.navigationDelegate = nil
        } else {
            self.uiWebView!.delegate = nil
        }
        self.isVisible = false
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        if self.useWebKit { return }
        
        // Hide the navbar and toolbar if using UIWebView since the new gestures are not available
        if let navController = self.navigationController {
            var hide: Bool
            switch toInterfaceOrientation {
            case .LandscapeLeft, .LandscapeRight:
                hide = true
            default:
                hide = false
            }
            
            navController.setNavigationBarHidden(hide, animated: true)
            navController.setToolbarHidden(hide, animated: true)
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        
        self.navigationItem.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        self.backButton.enabled = webView.canGoBack
        self.forwardButton.enabled = webView.canGoForward
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.startAnimating()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
        
        self.navigationItem.title = webView.title
        self.backButton.enabled = webView.canGoBack
        self.forwardButton.enabled = webView.canGoForward
    }
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
    }
    
    // MARK: - ActionPerformer
    
    func perform(userInfo: [NSObject : AnyObject]) {
        if let url = userInfo["url"] as? NSURL {
            if self.isVisible {
                self.navigateTo(url)
            } else {
                self.url = url
            }
        }
    }
    
    // MARK: - Public methods
    
    func navigateTo(url: NSURL) {
        let request = NSURLRequest(URL: url)
        if self.useWebKit {
            self.wkWebView!.loadRequest(request)
        } else {
            self.uiWebView!.loadRequest(request)
        }
    }
    
    // MARK: - Private methods
    
    internal func setupWebView() {
        // Use WKWebView if available, fallback to UIWebView
        let webView: UIView
        if self.useWebKit {
            self.wkWebView = WKWebView()
            webView = self.wkWebView!
        } else {
            self.uiWebView = UIWebView()
            webView = self.uiWebView!
        }
        // Insert the webView at index 0 so its scroll view insets get adjusted automatically
        self.view.insertSubview(webView, atIndex: 0)
        // Disable autoresizing mask translation so auto layout constraints can be added
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // Define constraints that make the webView display in full screen
        let trailing = NSLayoutConstraint(item: self.view, attribute: .Trailing, relatedBy: .Equal, toItem: webView, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let leading = NSLayoutConstraint(item: self.view, attribute: .Leading, relatedBy: .Equal, toItem: webView, attribute: .Leading, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: self.view, attribute: .Bottom, relatedBy: .Equal, toItem: webView, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: self.view, attribute: .Top, relatedBy: .Equal, toItem: webView, attribute: .Top, multiplier: 1.0, constant: 0)
        
        // Apply the auto layout constraints
        self.view.addConstraints([trailing, leading, bottom, top])
        
        // Make the webView transparent
        webView.opaque = false
        webView.backgroundColor = UIColor.clearColor()
    }

}

//class DulfyViewController: UIViewController, Injectable, Themeable, ActionPerformer, UIWebViewDelegate, WKNavigationDelegate {
//    
//    // MARK: - Properties
//    
//    var settings: Settings!
//    var theme: Theme!
//    var alertFactory: AlertFactory!
//    
//    let useWebKit = objc_getClass("WKWebView") != nil
//    var webView: WebViewProtocol!
//    
//    var homeUrl: NSURL {
//        get {
//            return NSURL(string: self.settings.dulfyNetUrl)!
//        }
//    }
//    var url: NSURL?
//    
//    var isVisible = false
//
//    // MARK: - Outlets
//    
//    @IBOutlet var activityIndicator: UIActivityIndicatorView!
//    @IBOutlet var backButton: UIBarButtonItem!
//    @IBOutlet var forwardButton: UIBarButtonItem!
//    
//    @IBAction func backTapped(sender: AnyObject) {
//        self.webView.doGoBack()
//    }
//    
//    @IBAction func forwardTapped(sender: AnyObject) {
//        self.webView.doGoForward()
//    }
//    
//    @IBAction func reloadTapped(sender: AnyObject) {
//        self.webView.doReload()
//    }
//    
//    @IBAction func stopTapped(sender: AnyObject) {
//        self.webView.doStopLoading()
//        
//        self.activityIndicator.stopAnimating()
//        self.navigationItem.title = self.webView.title
//        self.backButton.enabled = self.webView.canGoBack
//        self.forwardButton.enabled = self.webView.canGoForward
//    }
//    
//    @IBAction func homeTapped(sender: AnyObject) {
//        self.navigateTo(self.homeUrl)
//    }
//    
//    @IBAction func safariTapped(sender: AnyObject) {
//        if let url = self.webView.URL {
//            UIApplication.sharedApplication().openURL(url)
//        }
//    }
//
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        // Poor man's dependency injection, remove ASAP
//        InstanceHolder.sharedInstance().inject(self)
//        
//        super.viewDidLoad()
//        
//        self.applyTheme(self.theme)
//        
//        // Initially user cannot navigate back or forward so disable the buttons
//        self.backButton.enabled = false
//        self.forwardButton.enabled = false
//        
//        self.setupWebView()
//        
//        // Initial navigation, custom url if set, fallback to home page
//        let url = self.url != nil ? self.url! : self.homeUrl
//        self.navigateTo(url)
//        self.url = nil
//        
//        // Enable hide actions on navigation controller if they are available
//        if self.useWebKit {
//            if let navController = self.navigationController {
//                navController.hidesBarsOnSwipe = true
//                navController.hidesBarsWhenVerticallyCompact = true
//                navController.hidesBarsWhenKeyboardAppears = true
//            }
//        }
//        
//#if !DEBUG && !TEST
//        // Analytics
//        PFAnalytics.trackEvent("dulfy")
//#endif
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        self.webView.doSetDelegate(self)
//        self.isVisible = true
//        
//        // Navigate to custom url if set
//        if self.url != nil {
//            self.navigateTo(self.url!)
//            self.url = nil
//        }
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.webView.doSetDelegate(nil)
//        self.isVisible = false
//    }
//    
//    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
//        if self.useWebKit { return }
//        
//        // Hide the navbar and toolbar if using UIWebView since the new gestures are not available
//        if let navController = self.navigationController {
//            var hide: Bool
//            switch toInterfaceOrientation {
//            case .LandscapeLeft, .LandscapeRight:
//                hide = true
//            default:
//                hide = false
//            }
//            
//            navController.setNavigationBarHidden(hide, animated: true)
//            navController.setToolbarHidden(hide, animated: true)
//        }
//    }
//
//    // MARK: - UIWebViewDelegate
//    
//    func webViewDidStartLoad(webView: UIWebView) {
//        self.activityIndicator.startAnimating()
//    }
//    
//    func webViewDidFinishLoad(webView: UIWebView) {
//        self.activityIndicator.stopAnimating()
//        
//        self.navigationItem.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
//        self.backButton.enabled = webView.canGoBack
//        self.forwardButton.enabled = webView.canGoForward
//    }
//    
//    // MARK: - WKNavigationDelegate
//    
//    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        self.activityIndicator.startAnimating()
//    }
//    
//    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
//        self.activityIndicator.stopAnimating()
//        
//        self.navigationItem.title = webView.title
//        self.backButton.enabled = webView.canGoBack
//        self.forwardButton.enabled = webView.canGoForward
//    }
//    
//    // MARK: - Themeable
//    
//    func applyTheme(theme: Theme) {
//        self.view.backgroundColor = theme.contentBackground
//    }
//    
//    // MARK: - ActionPerformer
//    
//    func perform(userInfo: [NSObject : AnyObject]) {
//        if let url = userInfo["url"] as? NSURL {
//            if self.isVisible {
//                self.navigateTo(url)
//            } else {
//                self.url = url
//            }
//        }
//    }
//    
//    // MARK: - Public methods
//    
//    func navigateTo(url: NSURL) {
//        let request = NSURLRequest(URL: url)
//        self.webView.load(request)
//    }
//    
//    // MARK: - Private methods
//    
//    internal func setupWebView() {
//        // Use WKWebView if available, fallback to UIWebView
//        self.webView = self.useWebKit ? WKWebView() : UIWebView()
//        // Insert the webView at index 0 so its scroll view insets get adjusted automatically
//        self.view.insertSubview(self.webView.view, atIndex: 0)
//        // Disable autoresizing mask translation so auto layout constraints can be added
//        self.webView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
//        
//        // Define constraints that make the webView display in full screen
//        let trailing = NSLayoutConstraint(item: self.view, attribute: .Trailing, relatedBy: .Equal, toItem: self.webView.view, attribute: .Trailing, multiplier: 1.0, constant: 0)
//        let leading = NSLayoutConstraint(item: self.view, attribute: .Leading, relatedBy: .Equal, toItem: self.webView.view, attribute: .Leading, multiplier: 1.0, constant: 0)
//        let bottom = NSLayoutConstraint(item: self.view, attribute: .Bottom, relatedBy: .Equal, toItem: self.webView.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
//        let top = NSLayoutConstraint(item: self.view, attribute: .Top, relatedBy: .Equal, toItem: self.webView.view, attribute: .Top, multiplier: 1.0, constant: 0)
//        
//        // Apply the auto layout constraints
//        self.view.addConstraints([trailing, leading, bottom, top])
//        
//        // Make the webView transparent
//        self.webView.view.opaque = false
//        self.webView.view.backgroundColor = UIColor.clearColor()
//    }
//
//}
