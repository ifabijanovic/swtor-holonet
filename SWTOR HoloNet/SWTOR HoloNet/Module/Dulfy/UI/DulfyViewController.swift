//
//  DulfyViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 26/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import WebKit

// Workaround solution implemented because of a bug with protocol extension in Swift 1.2 and iOS SDK 8.3
// See WebViewEx.swift file for more info

class DulfyViewController: BaseViewController, ActionPerformer, UIWebViewDelegate, WKNavigationDelegate {
    
    // MARK: - Properties
    
    let useWebKit = objc_getClass("WKWebView") != nil
    
    var wkWebView: WKWebView?
    var uiWebView: UIWebView?
    
    var homeUrl: URL {
        get {
            return URL(string: self.settings.dulfyNetUrl)!
        }
    }
    var url: URL?
    
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
            self.backButton.isEnabled = self.wkWebView!.canGoBack
            self.forwardButton.isEnabled = self.wkWebView!.canGoForward
        } else {
            self.uiWebView!.stopLoading()
            self.navigationItem.title = self.uiWebView!.stringByEvaluatingJavaScript(from: "document.title")
            self.backButton.isEnabled = self.uiWebView!.canGoBack
            self.forwardButton.isEnabled = self.uiWebView!.canGoForward
        }
        
        self.activityIndicator.stopAnimating()
    }
    
    @IBAction func homeTapped(sender: AnyObject) {
        self.navigateTo(self.homeUrl)
    }
    
    @IBAction func safariTapped(sender: AnyObject) {
        if self.useWebKit {
            if let url = self.wkWebView!.url {
                UIApplication.shared.openURL(url)
            }
        } else {
            if let url = self.uiWebView!.request?.url {
                UIApplication.shared.openURL(url)
            }
        }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.applyTheme(self.theme)
        
        // Initially user cannot navigate back or forward so disable the buttons
        self.backButton.isEnabled = false
        self.forwardButton.isEnabled = false
        
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
            self.analytics.track(event: Constants.Analytics.Event.dulfy)
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.useWebKit {
            self.wkWebView!.navigationDelegate = nil
        } else {
            self.uiWebView!.delegate = nil
        }
        self.isVisible = false
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        
        self.navigationItem.title = webView.stringByEvaluatingJavaScript(from: "document.title")
        self.backButton.isEnabled = webView.canGoBack
        self.forwardButton.isEnabled = webView.canGoForward
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
        
        self.navigationItem.title = webView.title
        self.backButton.isEnabled = webView.canGoBack
        self.forwardButton.isEnabled = webView.canGoForward
    }
    
    // MARK: - Themeable
    
    override func applyTheme(_ theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
    }
    
    override func themeChanged(_ theme: Theme) {
        super.themeChanged(theme)
        
        // Only animate the toolbar transition if current view is visible
        let animate = self.isViewLoaded && self.view.window != nil
        theme.apply(toolbar: self.navigationController!.toolbar, animate: animate)
    }
    
    // MARK: - ActionPerformer
    
    func perform(_ userInfo: [AnyHashable : Any]) {
        if let url = userInfo["url"] as? URL {
            if self.isVisible {
                self.navigateTo(url)
            } else {
                self.url = url
            }
        }
    }
    
    // MARK: - Public methods
    
    func navigateTo(_ url: URL) {
        let request = URLRequest(url: url)
        if self.useWebKit {
            self.wkWebView!.load(request)
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
        self.view.insertSubview(webView, at: 0)
        // Disable autoresizing mask translation so auto layout constraints can be added
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Define constraints that make the webView display in full screen
        let trailing = NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: webView, attribute: .trailing, multiplier: 1.0, constant: 0)
        let leading = NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: webView, attribute: .leading, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: webView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: webView, attribute: .top, multiplier: 1.0, constant: 0)
        
        // Apply the auto layout constraints
        self.view.addConstraints([trailing, leading, bottom, top])
        
        // Make the webView transparent
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
    }

}
