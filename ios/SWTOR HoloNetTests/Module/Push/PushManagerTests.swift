//
//  PushManagerTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 28/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest
import RxSwift
import RxCocoa

class PushManagerTests: XCTestCase {
    fileprivate var appActionQueue: AppActionQueue!
    fileprivate var pushManager: PushManagerMock!
    fileprivate var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        
        self.appActionQueue = AppActionQueue()
        self.pushManager = PushManagerMock(appActionQueue: self.appActionQueue)
        self.disposeBag = DisposeBag()
        
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
        let manager = PushManagerMock(appActionQueue: self.appActionQueue)
        
        XCTAssertFalse(manager.shouldRequestAccess)
    }
    
    func testShouldRequestPushAccess_CanceledRecently() {
        self.set(didCancel: true)
        self.set(timestamp: Date())
        let manager = PushManagerMock(appActionQueue: self.appActionQueue)
        
        XCTAssertFalse(manager.shouldRequestAccess)
    }
    
    func testShouldRequestPushAccess_CanceledSomeTimeAgo() {
        self.set(didCancel: true)
        self.set(timestamp: Date(timeIntervalSinceNow: -Constants.Push.accessRequestRetryInterval))
        let manager = PushManagerMock(appActionQueue: self.appActionQueue)
        
        XCTAssertTrue(manager.shouldRequestAccess)
    }
    
    // MARK: - requestPushAccess
    
    func testRequestPushAccess_Canceled() {
        let navigator = TestNavigator()
        self.pushManager.requestAccess(navigator: navigator)
        XCTAssertTrue(navigator.didShowAlert)
        
        navigator.tap(style: .cancel)
        
        XCTAssertFalse(self.pushManager.didRegisterForPush)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: Constants.Push.UserDefaults.didCancelPushAccess))
        let date = UserDefaults.standard.object(forKey: Constants.Push.UserDefaults.lastPushAccessRequestTimestamp) as? Date
        XCTAssertNotNil(date)
        let diff = NSDate().timeIntervalSince(date!)
        XCTAssertLessThanOrEqual(diff, 3)
    }
    
    func testRequestPushAccess_Accepted() {
        let navigator = TestNavigator()
        self.pushManager.requestAccess(navigator: navigator)
        XCTAssertTrue(navigator.didShowAlert)
        
        navigator.tap(style: .default)
        
        XCTAssertTrue(self.pushManager.didRegisterForPush)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: Constants.Push.UserDefaults.didApprovePushAccess), "")
    }
    
    // MARK: - handleRemoteNotification
    
    func testHandleRemoteNotification_EnqueuesAction() {
        let userInfo: [AnyHashable: Any] = ["aps":["alert":"test"],"type":"dulfy","url":"http://www.test.com"]
        let appState = UIApplicationState.active
        
        let ex = self.expectation(description: "")
        self.appActionQueue
            .queue
            .drive(onNext: { action in
                switch action {
                case .dulfy(_, _, _): ex.fulfill()
                default: XCTFail()
                }
            })
            .disposed(by: self.disposeBag)
        
        self.pushManager.handleRemoteNotification(applicationState: appState, userInfo: userInfo)
        self.waitForExpectations(timeout: 3, handler: nil)
        XCTAssertTrue(self.pushManager.didResetBadge)
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
