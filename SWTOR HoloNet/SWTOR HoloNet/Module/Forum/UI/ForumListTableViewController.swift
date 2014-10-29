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
            // Category
            cell = tableView.dequeueReusableCellWithIdentifier(CategoryCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            self.setupCategoryCell(cell, indexPath: indexPath)
        } else if indexPath.section == ThreadSection {
            cell = tableView.dequeueReusableCellWithIdentifier(ThreadCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            self.setupThreadCell(cell, indexPath: indexPath)
        } else {
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
        let lock = dispatch_queue_create("com.if.locl", nil)
        var requestCount = 0
        
        self.loadedPage = 1
        self.canLoadMore = false
        self.showLoader()
        
        let hideLoader: () -> Void = {
            dispatch_sync(lock) { requestCount -= 1 }
            if requestCount == 0 {
                if self.category != nil {
                    self.canLoadMore = true
                } else {
                    self.hideLoader()
                }
            }
        }
        
        func categorySuccess(categories: Array<ForumCategory>) {
            self.categories = categories
            self.tableView.reloadSections(NSIndexSet(index: CategorySection), withRowAnimation: UITableViewRowAnimation.Automatic)
            hideLoader()
        }
        func threadSuccess(threads: Array<ForumThread>) {
            self.threads = threads
            self.tableView.reloadSections(NSIndexSet(index: ThreadSection), withRowAnimation: UITableViewRowAnimation.Automatic)
            hideLoader()
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
        if self.category == nil { return }
        
        self.canLoadMore = false
        
        func success(threads: Array<ForumThread>) {
            if threads.isEmpty {
                self.hideLoader()
                return
            }
            
            var indexes = Array<NSIndexPath>()
            for thread in threads {
                indexes.append(NSIndexPath(forRow: self.threads!.count, inSection: ThreadSection))
                self.threads!.append(thread)
            }
            
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
            
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
        
        if let url = category.iconUrl {
            imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "CategoryIcon"))
        }
        
        titleLabel.text = category.title
        statsLabel.text = category.stats
        lastPostLabel.text = category.lastPost
        
        cell.tag = indexPath.row
    }
    
    private func setupThreadCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let thread = self.threads![indexPath.row]
        let titleLabel = cell.viewWithTag(100) as UILabel
        let authorLabel = cell.viewWithTag(101) as UILabel
        let devImageView = cell.viewWithTag(102) as UIImageView
        let stickyImageView = cell.viewWithTag(103) as UIImageView
        let repliesViewsLabel = cell.viewWithTag(104) as UILabel
        
        if thread.hasBiowareReply {
            devImageView.hidden = false
            devImageView.sd_setImageWithURL(NSURL(string: self.settings!.devTrackerIconUrl), placeholderImage: UIImage(named: "DevTrackerIcon"))
        } else {
            devImageView.hidden = true
        }
        
        if thread.isSticky {
            stickyImageView.hidden = false
            stickyImageView.sd_setImageWithURL(NSURL(string: self.settings!.stickyIconUrl), placeholderImage: UIImage(named: "StickyIcon"))
        } else {
            stickyImageView.hidden = true
        }
        
        titleLabel.text = thread.title
        authorLabel.text = thread.author
        repliesViewsLabel.text = "R: \(thread.replies), V: \(thread.views)"
        
        cell.tag = indexPath.row
    }

}
