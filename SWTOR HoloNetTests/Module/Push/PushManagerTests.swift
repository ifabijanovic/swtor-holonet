//
//  PushManagerTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 28/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class PushManagerTests: XCTestCase {
    var navigator: TestNavigator!
    fileprivate var actionFactory: TestActionFactory!
    fileprivate var pushManager: PushManagerMock!
    
    override func setUp() {
        super.setUp()
        
        self.navigator = TestNavigator()
        self.actionFactory = TestActionFactory(navigator: self.navigator)
        self.pushManager = PushManagerMock(actionFactory: self.actionFactory, navigator: self.navigator)
        
        self.set(didCancel: nil)
        self.set(didApprove: nil)
        self.set(timestamp: nil)
    }
}

extension PushManagerTests {
    fileprivate func set(didCancel value: Bool?) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: Constants.Push.UserDefaults.didCancelPushAccess)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.Push.UserDefaults.didCancelPushAccess)
        }
    }
    
    fileprivate func set(didApprove value: Bool?) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: Constants.Push.UserDefaults.didApprovePushAccess)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.Push.UserDefaults.didApprovePushAccess)
        }
    }
    
    fileprivate func set(timestamp date: Date?) {
        if let date = date {
            UserDefaults.standard.set(date, forKey: Constants.Push.UserDefaults.lastPushAccessRequestTimestamp)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.Push.UserDefaults.lastPushAccessRequestTimestamp)
        }
    }
}

extension PushManagerTests {
    func testShouldRequestPushAccess_FirstStart() {
        XCTAssertTrue(self.pushManager.shouldRequestAccess)
    }

    func testShouldRequestPushAccess_PushEnabled() {
        self.pushManager.isEnabledValue = true
        
        XCTAssertFalse(self.pushManager.shouldRequestAccess)
    }
    
    func testShouldRequestPushAccess_ApprovedButPushDisabled() {
        self.set(didApprove: true)
        let manager = PushManagerMock(actionFactory: self.actionFactory, navigator: self.navigator)
        
        XCTAssertFalse(manager.shouldRequestAccess)
    }
    
    func testShouldRequestPushAccess_CanceledRecently() {
        self.set(didCancel: true)
        self.set(timestamp: Date())
        let manager = PushManagerMock(actionFactory: self.actionFactory, navigator: self.navigator)
        
        XCTAssertFalse(manager.shouldRequestAccess)
    }
    
    func testShouldRequestPushAccess_CanceledSomeTimeAgo() {
        self.set(didCancel: true)
        self.set(timestamp: Date(timeIntervalSinceNow: -Constants.Push.accessRequestRetryInterval))
        let manager = PushManagerMock(actionFactory: self.actionFactory, navigator: self.navigator)
        
        XCTAssertTrue(manager.shouldRequestAccess)
    }
    
    // MARK: - requestPushAccess
    
    func testRequestPushAccess_Canceled() {
        XCTAssertFalse(self.navigator.didShowAlert)
        self.pushManager.requestAccess(navigator: self.navigator)
        XCTAssertTrue(self.navigator.didShowAlert)
        
        self.navigator.tap(style: .cancel)
        
        XCTAssertFalse(self.pushManager.didRegisterForPush)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: Constants.Push.UserDefaults.didCancelPushAccess))
        let date = UserDefaults.standard.object(forKey: Constants.Push.UserDefaults.lastPushAccessRequestTimestamp) as? Date
        XCTAssertNotNil(date)
        let diff = NSDate().timeIntervalSince(date!)
        XCTAssertLessThanOrEqual(diff, 3)
    }
    
    func testRequestPushAccess_Accepted() {
        XCTAssertFalse(self.navigator.didShowAlert)
        self.pushManager.requestAccess(navigator: self.navigator)
        XCTAssertTrue(self.navigator.didShowAlert)
        
        self.navigator.tap(style: .default)
        
        XCTAssertTrue(self.pushManager.didRegisterForPush)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: Constants.Push.UserDefaults.didApprovePushAccess), "")
    }
    
    // MARK: - handleRemoteNotification
    
    func testHandleRemoteNotification_PerformsForegroundAction() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.active
        
        self.pushManager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertTrue(actionFactory.action!.didPerform)
        XCTAssertNotNil(actionFactory.action!.userInfo)
        XCTAssertEqual(actionFactory.action!.userInfo!.count, userInfo.count)
        XCTAssertEqual(actionFactory.action!.userInfo!["action"] as! String, userInfo["action"]!)
        XCTAssertTrue(actionFactory.action!.isForeground)
        XCTAssertTrue(self.pushManager.didResetBadge)
    }
    
    func testHandleRemoteNotification_PerformsBackgroundAction() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.inactive
        
        self.pushManager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertTrue(actionFactory.action!.didPerform)
        XCTAssertNotNil(actionFactory.action!.userInfo)
        XCTAssertEqual(actionFactory.action!.userInfo!.count, userInfo.count)
        XCTAssertEqual(actionFactory.action!.userInfo!["action"] as! String, userInfo["action"]!)
        XCTAssertFalse(actionFactory.action!.isForeground)
        XCTAssertTrue(self.pushManager.didResetBadge)
    }
    
    func testHandleRemoteNotification_InvalidAction() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.active
        self.actionFactory.action = nil

        self.pushManager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertTrue(self.pushManager.didResetBadge)
    }
    
    func testHandleRemoteNotification_ActionFailed() {
        let userInfo = ["action":"test"]
        let appState = UIApplicationState.active
        self.actionFactory.action!.returnValue = false
        
        self.pushManager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        
        XCTAssertTrue(self.pushManager.didResetBadge)
    }
}

fileprivate class TestAction: Action {
    var type: String { get { return "test" } }
    
    var didPerform = false
    var userInfo: [AnyHashable : Any]?
    var isForeground = false
    var returnValue = true
    
    func perform(userInfo: [AnyHashable : Any]?, isForeground: Bool) -> Bool {
        self.didPerform = true
        self.userInfo = userInfo
        self.isForeground = isForeground
        return self.returnValue
    }
}

fileprivate class TestActionFactory: ActionFactory {
    var action: TestAction? = TestAction()
    
    override func create(userInfo: [AnyHashable : Any]) -> Action? {
        return self.action
    }
}

fileprivate class PushManagerMock: DefaultPushManager {
    var didRegisterForPush = false
    var didResetBadge = false
    
    var isEnabledValue = false
    override var isEnabled: Bool { return self.isEnabledValue }
    
    override func register() {
        self.didRegisterForPush = true
    }
    
    override func resetBadge() {
        self.didResetBadge = true
    }
}
