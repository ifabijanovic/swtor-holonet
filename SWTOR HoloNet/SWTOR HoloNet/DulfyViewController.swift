//
//  DulfyViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 26/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

class DulfyViewController: UIViewController, Injectable, Themeable, UIWebViewDelegate {
    
    // MARK: - Properties
    
    var settings: Settings!
    var theme: Theme!
    var post: ForumPost!
    
    // MARK: - Outlets
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()
        
        if let navController = self.navigationController {
            let swipe = navController.hidesBarsOnSwipe as Bool?
        }
        
        self.applyTheme(self.theme)
        
        self.backButton.enabled = false
        self.forwardButton.enabled = false
        
        self.navigateHome()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.webView.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.webView.delegate = nil
    }
    
    // MARK: - Actions
    
    @IBAction func homeTapped(sender: AnyObject) {
        self.navigateHome()
    }
    
    private func navigateHome() {
        let url = NSURL(string: "http://dulfy.net/")
        let request = NSURLRequest(URL: url!)
        self.webView.loadRequest(request)
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
    
    // MARK: - Themeable
    
    func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
    }
    
}
