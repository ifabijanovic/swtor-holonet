//
//  ForumListTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 22/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumListTableViewController: ForumBaseTableViewController {
    
    // MARK: - Constants
    
    private let CategorySection = 0
    private let ThreadSection = 1
    private let CategoriesSectionTitle = "Categories"
    private let ThreadsSectionTitle = "Threads"
    private let CategoryCellIdentifier = "categoryCell"
    private let ThreadCellIdentifier = "threadCell"
    private let SubCategorySegue = "categorySegue"
    private let PostSegue = "postSegue"
    
    // MARK: - Properties
    
    private var settings: Settings?
    private var category: ForumCategory?
    
    private var categoryRepo: ForumCategoryRepository?
    private var threadRepo: ForumThreadRepository?
    
    private var categories: Array<ForumCategory>?
    private var threads: Array<ForumThread>?
    
    // MARK: - Public methods
    
    func setup(#settings: Settings) {
        self.setup(settings: settings, category: nil)
    }
    
    func setup(#settings: Settings, category: ForumCategory?) {
        self.settings = settings
        self.category = category
        self.categoryRepo = ForumCategoryRepository(settings: settings)
        
        if category != nil {
            // Threads exist only inside categories, not in forum root
            self.threadRepo = ForumThreadRepository(settings: settings)
            self.navigationItem.title = category!.title
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle.mainBundle()
        self.tableView.registerNib(UINib(nibName: "ForumThreadTableViewCell", bundle: bundle), forCellReuseIdentifier: ThreadCellIdentifier)
        
        self.onRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.categories?.removeAll(keepCapacity: false)
        self.categories = nil
        self.threads?.removeAll(keepCapacity: false)
        self.threads = nil
    }

    // MARK: - Table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.threadRepo != nil {
            return 2
        }
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == CategorySection {
            return self.categories?.count ?? 0
        } else if section == ThreadSection {
            return self.threads?.count ?? 0
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == CategorySection && self.hasCategories() {
            return CategoriesSectionTitle
        } else if section == ThreadSection && self.hasThreads() {
            return ThreadsSectionTitle
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == CategorySection {
            return 104.0
        }
        return 64.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell

        if indexPath.section == CategorySection {
            cell = tableView.dequeueReusableCellWithIdentifier(CategoryCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            self.setupCategoryCell(cell, indexPath: indexPath)
        } else if indexPath.section == ThreadSection {
            let threadCell = tableView.dequeueReusableCellWithIdentifier(ThreadCellIdentifier, forIndexPath: indexPath) as ForumThreadTableViewCell
            self.setupThreadCell(threadCell, indexPath: indexPath)
            cell = threadCell
        } else {
            // Safeguard, should not happen
            cell = UITableViewCell()
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SubCategorySegue {
            let controller = segue.destinationViewController as ForumListTableViewController
            let cell = sender as UITableViewCell
            let category = self.categories![cell.tag]
            controller.setup(settings: self.settings!, category: category)
        } else if segue.identifier == PostSegue {
            let controller = segue.destinationViewController as ForumThreadTableViewController
            let cell = sender as UITableViewCell
            let thread = self.threads![cell.tag]
            controller.setup(settings: self.settings!, thread: thread)
        }
    }

    // MARK: - Helper methods
    
    private func hasCategories() -> Bool {
        return self.categories?.count > 0 ?? false
    }
    
    private func hasThreads() -> Bool {
        return self.threads?.count > 0 ?? false
    }
    
    override func onRefresh() {
        // Setup a thread lock which will be used to synchronize two HTTP requests
        let lock = dispatch_queue_create("com.if.lock", nil)
        var requestCount = 0
        
        // Reloading content, set loaded page back to the first page
        self.loadedPage = 1
        // Disable infinite scroll while loading
        self.canLoadMore = false
        // Show loading indicator
        self.showLoader()
        
        // Hides loading indicators and enables infinite scroll if applicable
        // Uses thread locking to make sure it is only executed once
        let finishLoad: () -> Void = {
            dispatch_sync(lock) { requestCount -= 1 }
            if requestCount == 0 {
                self.refreshControl?.endRefreshing()
                if self.category != nil {
                    // Enable infinite scrolling only if inside a category
                    // because forum root does not contain any threads
                    self.canLoadMore = true
                } else {
                    self.hideLoader()
                }
            }
        }
        
        func categorySuccess(categories: Array<ForumCategory>) {
            // Set retrieved categories and reload the category section
            self.categories = categories
            self.tableView.reloadSections(NSIndexSet(index: CategorySection), withRowAnimation: UITableViewRowAnimation.Automatic)
            finishLoad()
        }
        func threadSuccess(threads: Array<ForumThread>) {
            // Set retrieved threads and reload the thread section
            self.threads = threads
            self.tableView.reloadSections(NSIndexSet(index: ThreadSection), withRowAnimation: UITableViewRowAnimation.Automatic)
            finishLoad()
        }
        func failure(error: NSError) {
            println(error)
        }
        
        if let category = self.category {
            // Load subcategories and threads for the current category
            requestCount = 2
            self.categoryRepo!.get(category: category, success: categorySuccess, failure: failure)
            self.threadRepo!.get(category: category, page: 1, success: threadSuccess, failure: failure)
        } else {
            // Forum root, only load categories
            requestCount = 1
            self.categoryRepo!.get(language: self.settings!.forumLanguage, success: categorySuccess, failure: failure)
        }
    }
    
    override func onLoadMore() {
        // Only applicable in categories, forum root does not contain threads
        if self.category == nil { return }
        
        // Disable infinite scroll while loading
        self.canLoadMore = false
        
        func success(threads: Array<ForumThread>) {
            let newThreads = threads.difference(self.threads!)
            
            if newThreads.isEmpty {
                // No new threads, disable infinite scrolling
                self.canLoadMore = false
                self.hideLoader()
                return
            }
            
            // Append the new threads and prepare indexes for table update
            var indexes = Array<NSIndexPath>()
            for thread in newThreads {
                indexes.append(NSIndexPath(forRow: self.threads!.count, inSection: ThreadSection))
                self.threads!.append(thread)
            }
            
            // Smoothly update the table by just inserting the new indexes
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
            
            // Mark this page as loaded and enable infinite scroll again
            self.loadedPage++
            self.canLoadMore = true
        }
        func failure(error: NSError) {
            println(error)
        }
        
        self.threadRepo!.get(category: self.category!, page: self.loadedPage + 1, success: success, failure: failure)
    }
    
    private func setupCategoryCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let category = self.categories![indexPath.row]
        let imageView = cell.viewWithTag(100) as UIImageView
        let titleLabel = cell.viewWithTag(101) as UILabel
        let statsLabel = cell.viewWithTag(102) as UILabel
        let lastPostLabel = cell.viewWithTag(103) as UILabel
        
        // Set category icon if URL is defined in the model
        if let url = category.iconUrl {
            imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "CategoryIcon"))
        }
        
        titleLabel.text = category.title
        statsLabel.text = category.stats
        lastPostLabel.text = category.lastPost
        
        cell.tag = indexPath.row
    }
    
    private func setupThreadCell(cell: ForumThreadTableViewCell, indexPath: NSIndexPath) {
        let thread = self.threads![indexPath.row]
        
        // Set dev icon if thread is marked as having Bioware reply
        if thread.hasBiowareReply {
            cell.devImageView.hidden = false
            cell.devImageView.sd_setImageWithURL(NSURL(string: self.settings!.devTrackerIconUrl), placeholderImage: UIImage(named: "DevTrackerIcon"))
        } else {
            cell.devImageView.hidden = true
        }
        
        // Set sticky icon if thread is marked with sticky
        if thread.isSticky {
            cell.stickyImageView.hidden = false
            cell.stickyImageView.sd_setImageWithURL(NSURL(string: self.settings!.stickyIconUrl), placeholderImage: UIImage(named: "StickyIcon"))
        } else {
            cell.stickyImageView.hidden = true
        }
        
        cell.titleLabel.text = thread.title
        cell.authorLabel.text = thread.author
        cell.repliesViewsLabel.text = "R: \(thread.replies), V: \(thread.views)"
        
        cell.tag = indexPath.row
    }

}
