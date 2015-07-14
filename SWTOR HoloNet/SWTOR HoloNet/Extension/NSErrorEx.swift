//
//  NSErrorEx.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 14/07/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

let errorDomain = "HoloNetErrorDomain"
let errorCodeMaintenance = 13001

extension NSError {
   
    class func maintenanceError() -> NSError {
        return NSError(domain: errorDomain, code: errorCodeMaintenance, userInfo: nil)
    }
    
    func isMaintenanceError() -> Bool {
        return self.domain == errorDomain && self.code == errorCodeMaintenance
    }
    
}
