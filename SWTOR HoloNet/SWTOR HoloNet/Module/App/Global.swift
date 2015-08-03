//
//  Globals.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 03/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import Foundation

let ShowAlertNotification = "ShowAlertNotification"
let SwitchToTabNotification = "SwitchToTabNotification"
let ThemeChangedNotification = "ThemeChangedNotification"

func isIOS8() -> Bool {
    let systemVersion = UIDevice.currentDevice().systemVersion
    let result = systemVersion.compare("8.0.0", options: .NumericSearch)
    return result == .OrderedSame
}

func isIOS8OrLater() -> Bool {
    let systemVersion = UIDevice.currentDevice().systemVersion
    let result = systemVersion.compare("8.0.0", options: .NumericSearch)
    return result == .OrderedSame || result == .OrderedDescending
}

func isIOS7() -> Bool {
    return !isIOS8OrLater() && isIOS7OrLater()
}

func isIOS7OrLater() -> Bool {
    let systemVersion = UIDevice.currentDevice().systemVersion
    let result = systemVersion.compare("7.0.0", options: .NumericSearch)
    return result == .OrderedSame || result == .OrderedDescending
}
