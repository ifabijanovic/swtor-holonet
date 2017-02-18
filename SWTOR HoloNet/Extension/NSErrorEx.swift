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

func maintenanceError() -> Error {
    return NSError(domain: errorDomain, code: errorCodeMaintenance, userInfo: nil)
}

extension Error {
    
    func isMaintenanceError() -> Bool {
        let nsError = self as NSError
        return nsError.domain == errorDomain && nsError.code == errorCodeMaintenance
    }
    
}
