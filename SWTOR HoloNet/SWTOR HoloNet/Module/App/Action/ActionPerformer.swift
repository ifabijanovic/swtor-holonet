//
//  ActionPerformer.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 06/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

@objc protocol ActionPerformer {
    
    func perform(userInfo: [NSObject : AnyObject])
    
}
