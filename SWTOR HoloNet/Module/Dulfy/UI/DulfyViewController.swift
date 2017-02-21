//
//  DulfyViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 26/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import WebKit

class DulfyViewController: BaseViewController {
    fileprivate var wkWebView: WKWebView!
    
    fileprivate var homeUrl: URL { return URL(string: self.settings.dulfyNetUrl)! }
    fileprivate var url: URL?
    
    fileprivate var isVisible = false
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    
    @IBAction func backTapped(_ sender: AnyObject) {
        self.wkWebView.goBack()
    }
    
    @IBAction func forwardTapped(_ sender: AnyObject) {
        self.wkWebView.goForward()
    }
    
    @IBAction func reloadTapped(_ sender: AnyObject) {
        self.wkWebView.reload()
    }
    
    @IBAction func stopTapped(_ sender: AnyObject) {
        self.wkWebView.stopLoading()
        self.navigationItem.title = self.wkWebView.title
        self.backButton.isEnabled = self.wkWebView.canGoBack
        self.forwardButton.isEnabled = self.wkWebView.canGoForward
        
        self.activityIndicator.stopAnimating()
    }
    
    @IBAction func homeTapped(_ sender: AnyObject) {
        self.navigateTo(self.homeUrl)
    }
    
    @IBAction func safariTapped(_ sender: AnyObject) {
        if let url = self.wkWebView.url {
            UIApplication.shared.openURL(url)
        }
    }

    // MARK: - Overrides
    
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
        if let navController = self.navigationController {
            navController.hidesBarsOnSwipe = true
            navController.hidesBarsWhenVerticallyCompact = true
            navController.hidesBarsWhenKeyboardAppears = true
        }
        
        #if !DEBUG && !TEST
            self.analytics.track(event: Constants.Analytics.Event.dulfy)
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.wkWebView.navigationDelegate = self
        self.isVisible = true
        
        // Navigate to custom url if set
        if self.url != nil {
            self.navigateTo(self.url!)
            self.url = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.wkWebView.navigationDelegate = nil
        self.isVisible = false
    }
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        self.view.backgroundColor = theme.contentBackground
    }
    
    override func themeChanged(_ theme: Theme) {
        super.themeChanged(theme)
        
        // Only animate the toolbar transition if current view is visible
        let animate = self.isViewLoaded && self.view.window != nil
        theme.apply(toolbar: self.navigationController!.toolbar, animate: animate)
    }
}

extension DulfyViewController {
    func navigateTo(_ url: URL) {
        let request = URLRequest(url: url)
        self.wkWebView.load(request)
    }
    
    fileprivate func setupWebView() {
        self.wkWebView = WKWebView()
        // Insert the webView at index 0 so its scroll view insets get adjusted automatically
        self.view.insertSubview(self.wkWebView, at: 0)
        // Disable autoresizing mask translation so auto layout constraints can be added
        self.wkWebView.translatesAutoresizingMaskIntoConstraints = false
        
        // Define constraints that make the webView display in full screen
        let views: [String: Any] = ["webView": self.wkWebView]
        var constraints = [NSLayoutConstraint]()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints)
        
        // Make the webView transparent
        self.wkWebView.isOpaque = false
        self.wkWebView.backgroundColor = UIColor.clear
    }
}

extension DulfyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
        
        self.navigationItem.title = webView.title
        self.backButton.isEnabled = webView.canGoBack
        self.forwardButton.isEnabled = webView.canGoForward
    }
}

extension DulfyViewController: ActionPerformer {
    func perform(userInfo: [AnyHashable : Any]) {
        if let url = userInfo["url"] as? URL {
            if self.isVisible {
                self.navigateTo(url)
            } else {
                self.url = url
            }
        }
    }
}
