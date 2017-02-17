//
//  DelegateBase.swift
//  SwiftAlert
//
//  Created by Ivan Fabijanovic on 15/02/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

internal class DelegateBase: NSObject {
    
    // MARK: - Properties
    
    var holdSelf: DelegateBase?
    var cb: (Int) -> ()
    
    // MARK: - Init
    
    init(cb: @escaping (Int) -> ()) {
        self.cb = cb
        super.init()
        self.holdSelf = self
    }
    
    // MARK: - Public methods
    
    func finish(index: Int) {
        self.cb(index)
        self.holdSelf = nil
    }
    
}
