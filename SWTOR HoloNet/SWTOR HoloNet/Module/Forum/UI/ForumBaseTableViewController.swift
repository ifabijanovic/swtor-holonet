//
//  ForumBaseTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 27/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumBaseTableViewController: UITableViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // This removes empty cells while the table is still loading
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Setup the pull to refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        self.tableView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height)
        refreshControl.beginRefreshing()
    }
    
    // MARK: - Methods
    
    internal func onRefresh() {
        // Implement in derived classes
    }

}
