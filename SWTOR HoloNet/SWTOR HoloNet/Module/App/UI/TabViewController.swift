//
//  TabViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 21/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
#if !DEBUG && !TEST
        PFAnalytics.trackEvent("tab", dimensions: ["type": item.title!])
#endif
    }

}
