//
//  EntityTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 05/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class EntityTests: XCTestCase {

    // MARK: - Tests
    
    func testEntityIsEqual() {
        let entity1 = Entity(id: 5)
        let entity2 = Entity(id: 5)
        
        XCTAssertEqual(entity1, entity2, "")
    }
    
    func testEntityNotEqual() {
        let entity1 = Entity(id: 5)
        let entity2 = Entity(id: 7)
        
        XCTAssertNotEqual(entity1, entity2, "")
    }
    
}
