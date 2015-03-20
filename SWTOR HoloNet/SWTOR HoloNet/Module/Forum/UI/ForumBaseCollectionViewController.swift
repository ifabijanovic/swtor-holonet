//
//  ForumBaseCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumBaseCollectionViewController: UICollectionViewController, Injectable {

    // MARK: - Injectable
    
    var settings: Settings!
    var theme: Theme!
    var alertFactory: AlertFactory!
    
    // MARK: - Properties
    
    private var footer: UIView?
    
    internal var refreshControl: UIRefreshControl?
    internal var canLoadMore = false
    internal var loadedPage = 1
    
    // MARK: - Activity indicator
    
    internal func showLoader() {
        //self.tableView.tableFooterView = self.footer
    }
    
    internal func hideLoader() {
        //self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // MARK: - Abstract methods
    
    internal func onRefresh() {
        // Implement in derived classes
    }
    
    internal func onLoadMore() {
        // Implement in derived classes
    }

}
