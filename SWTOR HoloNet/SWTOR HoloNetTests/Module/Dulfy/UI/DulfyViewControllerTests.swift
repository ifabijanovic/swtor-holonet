//
//  DulfyViewControllerTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 02/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class DulfyViewControllerTests: XCTestCase {

    class WebViewMock: WebViewProtocol {
        
        var delegate: AnyObject?
        var request: NSURLRequest?
        var didReload = false
        var didStopLoading = false
        var didGoBack = false
        var didGoForward = false
        
        var canGoBackValue = false
        var canGoForwardValue = false
        var loadingValue = false
        
        var titleValue = ""
        var viewValue = UIView()
        
        var URL: NSURL? {
            get {
                return self.request?.URL
            }
        }
        
        func doSetDelegate(delegate: AnyObject?) {
            self.delegate = delegate
        }
        
        func load(request: NSURLRequest) {
            self.request = request
        }
        
        func doReload() {
            self.didReload = true
        }
        
        func doStopLoading() {
            self.didStopLoading = true
        }
        
        func doGoBack() {
            self.didGoBack = true
        }
        
        func doGoForward() {
            self.didGoForward = true
        }
        
        var canGoBack: Bool {
            get { return self.canGoBackValue }
        }
        
        var canGoForward: Bool {
            get { return self.canGoForwardValue }
        }
        
        var loading: Bool {
            get { return self.loadingValue }
        }
        
        var title: String? {
            get { return self.titleValue }
        }
        
        var view: UIView {
            get { return self.viewValue }
        }
        
    }
    
    class DulfyViewControllerMock: DulfyViewController {
        
        var didSetupWebView = false
        var didApplyTheme = false
        
        override func setupWebView() {
            self.didSetupWebView = true
        }
        
        override func applyTheme(theme: Theme) {
            self.didApplyTheme = true
        }
        
    }
    
    var webView: WebViewMock!
    var viewController: DulfyViewControllerMock!
    
    override func setUp() {
        super.setUp()
        
        let bundle = NSBundle(forClass: DulfyViewControllerTests.self)
        InstanceHolder.initWithBundle(bundle)
        
        self.webView = WebViewMock()
        self.viewController = DulfyViewControllerMock()
        self.viewController.webView = self.webView
        self.viewController.backButton = UIBarButtonItem()
        self.viewController.forwardButton = UIBarButtonItem()
        self.viewController.activityIndicator = UIActivityIndicatorView()
    }
    
    // MARK: - Lifecycle
    
    func testViewDidLoad_SetsUpWebView() {
        self.viewController.viewDidLoad()
        XCTAssertTrue(self.viewController.didSetupWebView, "")
        XCTAssertEqual(ObjectIdentifier(self.viewController.webView), ObjectIdentifier(self.webView), "")
    }
    
    func testViewDidLoad_DisablesBackForwardButtons() {
        self.viewController.viewDidLoad()
        XCTAssertFalse(self.viewController.backButton.enabled, "")
        XCTAssertFalse(self.viewController.forwardButton.enabled, "")
    }
    
    func testViewDidLoad_AppliesTheme() {
        self.viewController.viewDidLoad()
        XCTAssertTrue(self.viewController.didApplyTheme, "")
    }
    
    func testViewDidLoad_NavigatesToHomePage() {
        self.viewController.viewDidLoad()
        XCTAssertNotNil(self.webView.request, "")
        XCTAssertEqual(self.webView.URL!.absoluteString!, self.viewController.settings.dulfyNetUrl, "")
    }
    
    func testViewDidLoad_NavigatesToCustomUrlIfSet() {
        let url = NSURL(string: "http://www.test.com")
        self.viewController.url = url
        self.viewController.viewDidLoad()
        XCTAssertEqual(self.webView.URL!.absoluteString!, url!.absoluteString!, "")
    }
    
    func testViewDidAppear_SetsWebViewDelegate() {
        self.viewController.viewDidAppear(false)
        XCTAssertNotNil(self.webView.delegate, "")
    }
    
    func testViewDidAppear_MarksViewVisible() {
        self.viewController.viewDidAppear(false)
        XCTAssertTrue(self.viewController.isVisible, "")
    }
    
    func testViewDidAppear_NavigatesToCustomUrlIfSet() {
        let url = NSURL(string: "http://www.test.com")
        self.viewController.url = url
        self.viewController.viewDidAppear(false)
        XCTAssertEqual(self.webView.URL!.absoluteString!, url!.absoluteString!, "")
    }
    
    func testViewDidDisappear_ClearsWebViewDelegate() {
        self.webView.delegate = self.viewController
        self.viewController.viewDidDisappear(false)
        XCTAssertNil(self.webView.delegate, "")
    }
    
    func testViewDidDisappear_MarksViewInvisible() {
        self.viewController.isVisible = true
        self.viewController.viewDidDisappear(false)
        XCTAssertFalse(self.viewController.isVisible, "")
    }
    
    // MARK: - Outlets
    
    func testBackTapped_GoesBack() {
        self.viewController.backTapped(UIBarButtonItem())
        XCTAssertTrue(self.webView.didGoBack, "")
    }
    
    func testForwardTapped_GoesForward() {
        self.viewController.forwardTapped(UIBarButtonItem())
        XCTAssertTrue(self.webView.didGoForward, "")
    }
    
    func testReloadTapped_Reloads() {
        self.viewController.reloadTapped(UIBarButtonItem())
        XCTAssertTrue(self.webView.didReload, "")
    }
    
    func testStopTapped_StopsLoading() {
        self.viewController.stopTapped(UIBarButtonItem())
        XCTAssertTrue(self.webView.didStopLoading, "")
    }
    
    func testHomeTapped_NavigatesToHomePage() {
        self.viewController.viewDidLoad()
        self.viewController.homeTapped(UIBarButtonItem())
        XCTAssertNotNil(self.webView.request, "")
        XCTAssertEqual(self.webView.request!.URL!.absoluteString!, self.viewController.settings.dulfyNetUrl, "")
    }
    
    // MARK: - ActionPerformer
    
    func testPerform_NavigatesToUrlIfVisible() {
        self.viewController.isVisible = true
        let url = NSURL(string: "http://www.test.com")
        let payload = ["url": url!]
        self.viewController.perform(payload)
        
        XCTAssertNil(self.viewController.url, "")
        XCTAssertEqual(self.webView.URL!.absoluteString!, url!.absoluteString!, "")
    }
    
    func testPerform_SetsCustomUrlIfInvisible() {
        let url = NSURL(string: "http://www.test.com")
        let payload = ["url": url!]
        self.viewController.perform(payload)
        
        XCTAssertNil(self.webView.request, "")
        XCTAssertEqual(self.viewController.url!.absoluteString!, url!.absoluteString!, "")
    }
    
    func testPerform_HandlesMissingUrl() {
        let payload = ["something": "something"]
        self.viewController.perform(payload)
        
        XCTAssertNil(self.viewController.url, "")
        XCTAssertNil(self.webView.request, "")
    }
    
    func testPerform_HandlesInvalidParameters() {
        let payload = ["url": "url"]
        self.viewController.perform(payload)
        
        XCTAssertNil(self.viewController.url, "")
        XCTAssertNil(self.webView.request, "")
    }

}
