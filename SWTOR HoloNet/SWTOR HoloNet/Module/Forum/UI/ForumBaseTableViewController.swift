//
//  ForumBaseTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 27/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumBaseTableViewController: UITableViewController {

    // MARK: - Constants
    
    let InfiniteScrollOffset: CGFloat = 50.0
    let ScreenHeight = UIScreen.mainScreen().bounds.height
    
    // MARK: - Properties
    
    private var footer: UIView?
    
    internal var canLoadMore = false
    internal var loadedPage = 1
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.footer = self.tableView.tableFooterView
        
        // Setup the pull to refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    // MARK: - Scroll
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if !canLoadMore { return }
        
        let actualPosition = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - ScreenHeight - InfiniteScrollOffset
        if actualPosition >= contentHeight {
            self.onLoadMore()
        }
    }
    
    // MARK: - Activity indicator
    
    internal func showLoader() {
        self.tableView.tableFooterView = self.footer
    }
    
    internal func hideLoader() {
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // MARK: - Abstract methods
    
    internal func onRefresh() {
        // Implement in derived classes
    }
    
    internal func onLoadMore() {
        // Implement in derived classes
    }

}
