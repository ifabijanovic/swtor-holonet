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
    fileprivate var homeUrl: URL { return URL(string: self.settings.dulfyNetUrl)! }
    fileprivate var url: URL?
    fileprivate var isVisible = false
    
    fileprivate var wkWebView: WKWebView!
    fileprivate var activityIndicator: UIActivityIndicatorView!
    fileprivate var backButton: UIBarButtonItem!
    fileprivate var forwardButton: UIBarButtonItem!
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupWebView()
        self.setupActivityIndicator()
        self.setupButtons()
        self.apply(theme: self.theme)
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
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
        
        self.analytics.track(event: Constants.Analytics.Event.dulfy)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.wkWebView.navigationDelegate = nil
        self.isVisible = false
    }
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
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
    func backTapped() {
        self.wkWebView.goBack()
    }
    
    func forwardTapped() {
        self.wkWebView.goForward()
    }
    
    func reloadTapped() {
        self.wkWebView.reload()
    }
    
    func stopTapped() {
        self.wkWebView.stopLoading()
        self.navigationItem.title = self.wkWebView.title
        self.backButton.isEnabled = self.wkWebView.canGoBack
        self.forwardButton.isEnabled = self.wkWebView.canGoForward
        
        self.activityIndicator.stopAnimating()
    }
    
    func homeTapped() {
        self.navigateTo(self.homeUrl)
    }
    
    func safariTapped() {
        if let url = self.wkWebView.url {
            UIApplication.shared.openURL(url)
        }
    }
    
    func navigateTo(_ url: URL) {
        let request = URLRequest(url: url)
        self.wkWebView.load(request)
    }
}

extension DulfyViewController {
    fileprivate func setupWebView() {
        let webView = WKWebView()
        // Disable autoresizing mask translation so auto layout constraints can be added
        webView.translatesAutoresizingMaskIntoConstraints = false
        // Insert the webView at index 0 so its scroll view insets get adjusted automatically
        self.view.insertSubview(webView, at: 0)
        // Make the webView transparent
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        
        self.wkWebView = webView
        
        let views: [String: Any] = ["webView": webView]
        var constraints = [NSLayoutConstraint]()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints)
    }
    
    fileprivate func setupActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        self.activityIndicator = activityIndicator
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0)
            ]
        )
    }
    
    fileprivate func setupButtons() {
        let safariButton = UIBarButtonItem(image: UIImage(named: Constants.Images.Icons.safari), style: .plain, target: self, action: #selector(DulfyViewController.safariTapped))
        self.navigationItem.rightBarButtonItem = safariButton
        
        let backButton = UIBarButtonItem(image: UIImage(named: Constants.Images.Icons.back), style: .plain, target: self, action: #selector(DulfyViewController.backTapped))
        backButton.isEnabled = false
        self.backButton = backButton
        
        let forwardButton = UIBarButtonItem(image: UIImage(named: Constants.Images.Icons.forward), style: .plain, target: self, action: #selector(DulfyViewController.forwardTapped))
        forwardButton.isEnabled = false
        self.forwardButton = forwardButton
        
        let reloadButton = UIBarButtonItem(image: UIImage(named: Constants.Images.Icons.reload), style: .plain, target: self, action: #selector(DulfyViewController.reloadTapped))
        let stopButton = UIBarButtonItem(image: UIImage(named: Constants.Images.Icons.stop), style: .plain, target: self, action: #selector(DulfyViewController.stopTapped))
        let homeButton = UIBarButtonItem(image: UIImage(named: Constants.Images.Icons.home), style: .plain, target: self, action: #selector(DulfyViewController.homeTapped))
        
        let toolbarItems: [UIBarButtonItem] = [
            backButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            forwardButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            reloadButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            stopButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            homeButton
        ]
        self.setToolbarItems(toolbarItems, animated: true)
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
