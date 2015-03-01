//
//  DelegateBaseTests.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 01/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class DelegateBaseTests: XCTestCase {
    
    func testRetainsSelf() {
        let delegate = DelegateBase { index in return }
        
        XCTAssertNotNil(delegate.holdSelf, "")
        XCTAssertEqual(delegate.holdSelf!, delegate, "")
    }
    
    func testFinishReleasesSelf() {
        let delegate = DelegateBase { index in return }
        delegate.finish(0)
        
        XCTAssertNil(delegate.holdSelf, "")
    }
    
    func testFinishFiresCallback() {
        let ex = expectationWithDescription("")
        let random = Int(arc4random())
        let delegate = DelegateBase { index in
            XCTAssertEqual(index, random, "")
            ex.fulfill()
        }
        
        delegate.finish(random)
        waitForExpectationsWithTimeout(3, handler: { error in
            if error != nil {
                XCTFail("")
            }
        })
    }

}
