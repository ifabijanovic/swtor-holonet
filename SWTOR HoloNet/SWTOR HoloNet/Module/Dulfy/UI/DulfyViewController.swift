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
    var webView: WebViewProtocol!
    
    // MARK: - Outlets
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    
    @IBAction func backTapped(sender: AnyObject) {
        self.webView.doGoBack()
    }
    
    @IBAction func forwardTapped(sender: AnyObject) {
        self.webView.doGoForward()
    }
    
    @IBAction func reloadTapped(sender: AnyObject) {
        self.webView.doReload()
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
        self.webView.doSetDelegate(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.webView.doSetDelegate(nil)
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
    
    // MARK: - Private methods
    
    private func setupWebView() {
        // Use WKWebView if available, fallback to UIWebView
        self.webView = self.useWebKit ? WKWebView() : UIWebView()
        // Insert the webView at index 0 so its scroll view insets get adjusted automatically
        self.view.insertSubview(self.webView.view, atIndex: 0)
        // Disable autoresizing mask translation so auto layout constraints can be added
        self.webView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // Define constraints that make the webView display in full screen
        let trailing = NSLayoutConstraint(item: self.view, attribute: .Trailing, relatedBy: .Equal, toItem: self.webView.view, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let leading = NSLayoutConstraint(item: self.view, attribute: .Leading, relatedBy: .Equal, toItem: self.webView.view, attribute: .Leading, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: self.view, attribute: .Bottom, relatedBy: .Equal, toItem: self.webView.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: self.view, attribute: .Top, relatedBy: .Equal, toItem: self.webView.view, attribute: .Top, multiplier: 1.0, constant: 0)
        
        // Apply the auto layout constraints
        self.view.addConstraints([trailing, leading, bottom, top])
        
        // Make the webView transparent
        self.webView.view.opaque = false
        self.webView.view.backgroundColor = UIColor.clearColor()
    }
    
    private func navigateHome() {
        let url = NSURL(string: self.settings.dulfyNetUrl)
        let request = NSURLRequest(URL: url!)
        self.webView.load(request)
    }
    
}
