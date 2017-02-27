//
//  TabViewControllerTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 10/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest
import RxSwift
import RxCocoa

class TabViewControllerTests: XCTestCase {

    class TestTabViewController: TabViewController {
    
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
    
    var controller: TestTabViewController!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: TabViewControllerTests.self)
        let settings = Settings(bundle: bundle)
        let analytics = DefaultAnalytics()
        let navigator = DefaultNavigator(settings: settings)
        let theme = Driver.just(Theme(bundle: bundle))
        let services = StandardServices(analytics: analytics, navigator: navigator, theme: theme, settings: settings)
        let pushManager = DefaultPushManager(actionFactory: ActionFactory(navigator: navigator))

        self.controller = TestTabViewController(services: services, pushManager: pushManager)
        let viewControllers = [UIViewController(), UIViewController(), UIViewController()]
        self.controller.setViewControllers(viewControllers, animated: false)
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
