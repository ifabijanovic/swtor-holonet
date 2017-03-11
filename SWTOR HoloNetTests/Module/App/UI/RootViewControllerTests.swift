//
//  RootViewControllerTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 10/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest
import RxSwift
import RxCocoa

class RootViewControllerTests: XCTestCase {

    class TestRootViewController: RootViewController {
    
        var didRegisterForNotifications = false
        var didSwitchToTab = false
        
        override func registerForNotifications() {
            self.didRegisterForNotifications = true
            super.registerForNotifications()
        }
        
        override func switchToTab(notification: NSNotification) {
            self.didSwitchToTab = true
            super.switchToTab(notification: notification)
        }
        
    }
    
    class TestActionPerformer: UIViewController, ActionPerformer {
        
        var didPerform = false
        
        func perform(userInfo: [AnyHashable : Any]) {
            self.didPerform = true
        }
        
    }
    
    var controller: TestRootViewController!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: RootViewControllerTests.self)
        let settings = Settings(bundle: bundle)
        let analytics = DefaultAnalytics()
        let navigator = DefaultNavigator(settings: settings)
        let themeManager = DefaultThemeManager(bundle: bundle)
        let toolbox = Toolbox(analytics: analytics, navigator: navigator, themeManager: themeManager, settings: settings)
        let pushManager = DefaultPushManager(actionFactory: ActionFactory(navigator: navigator), navigator: navigator)

        self.controller = TestRootViewController(toolbox: toolbox, pushManager: pushManager, items: (0..<3).map { RootTabBarItem(viewController: UIViewController(), index: $0) })
    }
    
    func testRegistersForNotifications() {
        XCTAssertTrue(self.controller.didRegisterForNotifications, "")
    }
    
    func testSwitchToTab_Fires() {
        NotificationCenter.default.post(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: nil)
        
        XCTAssertTrue(self.controller.didSwitchToTab, "")
    }
    
    func testSwitchToTab_IgnoresEmptyNotifications() {
        let notification = NSNotification(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self)
        self.controller.switchToTab(notification: notification)
        
        XCTAssertEqual(self.controller.selectedIndex, 0, "")
    }
    
    func testSwitchToTab_IgnoresIfIndexMissing() {
        let payload = ["test":"test"]
        let notification = NSNotification(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: payload)
        self.controller.switchToTab(notification: notification)
        
        XCTAssertEqual(self.controller.selectedIndex, 0, "")
    }
    
    func testSwitchToTab_IgnoresIfIndexInvalid() {
        var payload = ["index":-1]
        var notification = NSNotification(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: payload)
        self.controller.switchToTab(notification: notification)
        
        XCTAssertEqual(self.controller.selectedIndex, 0, "")
        
        payload["index"] = 5
        notification = NSNotification(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: payload)
        self.controller.switchToTab(notification: notification)
        
        XCTAssertEqual(self.controller.selectedIndex, 0, "")
    }
    
    func testSwitchToTab_Succeeds() {
        let payload = ["index":1]
        let notification = NSNotification(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: payload)
        self.controller.switchToTab(notification: notification)
        
        XCTAssertEqual(self.controller.selectedIndex, 1, "")
    }
    
    func testSwitchToTab_CallsActionPerformer() {
        let actionPerformer = TestActionPerformer()
        var viewControllers = self.controller.viewControllers!
        viewControllers[2] = actionPerformer
        self.controller.setViewControllers(viewControllers, animated: false)
        
        let payload = ["index":2]
        let notification = NSNotification(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: payload)
        self.controller.switchToTab(notification: notification)
        
        XCTAssertTrue(actionPerformer.didPerform, "")
        XCTAssertEqual(self.controller.selectedIndex, 2, "")
    }
    
    func testSwitchToTab_CallsActionPerformerEmbeddedInNavigationController() {
        let actionPerformer = TestActionPerformer()
        var viewControllers = self.controller.viewControllers!
        viewControllers[1] = UINavigationController(rootViewController: actionPerformer)
        self.controller.setViewControllers(viewControllers, animated: false)
        
        let payload = ["index":1]
        let notification = NSNotification(name: NSNotification.Name(Constants.Notifications.switchToTab), object: self, userInfo: payload)
        self.controller.switchToTab(notification: notification)
        
        XCTAssertTrue(actionPerformer.didPerform, "")
        XCTAssertEqual(self.controller.selectedIndex, 1, "")
    }

}