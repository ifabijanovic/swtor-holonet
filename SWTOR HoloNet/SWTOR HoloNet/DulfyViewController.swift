//
//  DulfyViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 26/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation
import WebKit

class DulfyViewController: UIViewController, Injectable, Themeable, UIWebViewDelegate, WKNavigationDelegate {
    
    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    var post: ForumPost!
    
    let useWebKit = objc_getClass("WKWebView") != nil
    var webView: UIView!
    
    // MARK: - Outlets
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    
    @IBAction func backTapped(sender: AnyObject) {
        if self.useWebKit {
            let webView = self.webView as WKWebView
            webView.goBack()
        } else {
            let webView = self.webView as UIWebView
            webView.goBack()
        }
    }
    
    @IBAction func forwardTapped(sender: AnyObject) {
        if self.useWebKit {
            let webView = self.webView as WKWebView
            webView.goForward()
        } else {
            let webView = self.webView as UIWebView
            webView.goForward()
        }
    }
    
    @IBAction func reloadTapped(sender: AnyObject) {
        if self.useWebKit {
            let webView = self.webView as WKWebView
            webView.reload()
        } else {
            let webView = self.webView as UIWebView
            webView.reload()
        }
    }
    
    @IBAction func homeTapped(sender: AnyObject) {
        self.navigateHome()
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
        self.navigateHome()
        
        // Enable hide actions on navigation controller if they are available
        if self.useWebKit {
            if let navController = self.navigationController {
                navController.hidesBarsOnSwipe = true
                navController.hidesBarsWhenVerticallyCompact = true
                navController.hidesBarsWhenKeyboardAppears = true
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setWebViewDelegate(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.setWebViewDelegate(nil)
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
    
    // MARK: - Private methods
    
    private func setupWebView() {
        // Use WKWebView if available, fallback to UIWebView
        self.webView = self.useWebKit ? WKWebView() : UIWebView()
        // Insert the webView at index 0 so its scroll view insets get adjusted automatically
        self.view.insertSubview(self.webView, atIndex: 0)
        // Disable autoresizing mask translation so auto layout constraints can be added
        self.webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // Define constraints that make the webView display in full screen
        let trailing = NSLayoutConstraint(item: self.view, attribute: .Trailing, relatedBy: .Equal, toItem: self.webView, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let leading = NSLayoutConstraint(item: self.view, attribute: .Leading, relatedBy: .Equal, toItem: self.webView, attribute: .Leading, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: self.view, attribute: .Bottom, relatedBy: .Equal, toItem: self.webView, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: self.view, attribute: .Top, relatedBy: .Equal, toItem: self.webView, attribute: .Top, multiplier: 1.0, constant: 0)
        
        // Apply the auto layout constraints
        self.view.addConstraints([trailing, leading, bottom, top])
        
        // Make the webView transparent
        self.webView.opaque = false
        self.webView.backgroundColor = UIColor.clearColor()
    }
    
    private func navigateHome() {
        let url = NSURL(string: self.settings.dulfyNetUrl)
        let request = NSURLRequest(URL: url!)
        
        if self.useWebKit {
            let webView = self.webView as WKWebView
            webView.loadRequest(request)
        } else {
            let webView = self.webView as UIWebView
            webView.loadRequest(request)
        }
    }
    
    private func setWebViewDelegate(delegate: AnyObject?) {
        if self.useWebKit {
            let webView = self.webView as WKWebView
            webView.navigationDelegate = delegate as? WKNavigationDelegate
        } else {
            let webView = self.webView as UIWebView
            webView.delegate = delegate as? UIWebViewDelegate
        }
    }
    
}
