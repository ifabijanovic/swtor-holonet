//
//  Action.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 06/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

let SwitchToTabNotification = "SwitchToTabNotification"

protocol Action {
    
    // MARK: - Properties
    
    var type: String { get }
    
    // MARK: - Public methods
    
    func perform(userInfo: [NSObject : AnyObject]?, isForeground: Bool) -> Bool
    
}
