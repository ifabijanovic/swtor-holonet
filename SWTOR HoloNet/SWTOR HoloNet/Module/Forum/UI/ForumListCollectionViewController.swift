//
//  ForumListCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import Parse

class ForumListCollectionViewController: ForumBaseCollectionViewController {

    // MARK: - Constants
    
    private let CategorySection = 0
    private let ThreadSection = 1
    private let CategoriesSectionTitle = "Categories"
    private let ThreadsSectionTitle = "Threads"
    private let CategoryCellIdentifier = "categoryCell"
    private let ThreadCellIdentifier = "threadCell"
    private let HeaderIdentifier = "header"
    private let SubCategorySegue = "categorySegue"
    private let ThreadSegue = "threadSegue"
    
    // MARK: - Properties
    
    var category: ForumCategory?
    
    private var categoryRepo: ForumCategoryRepository!
    private var threadRepo: ForumThreadRepository?
    
    private var categories: Array<ForumCategory>?
    private var threads: Array<ForumThread>?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()

        self.categoryRepo = ForumCategoryRepository(settings: self.settings)
        if self.category != nil {
            // Threads exist only inside categories, not in forum root
            self.threadRepo = ForumThreadRepository(settings: self.settings)
            self.navigationItem.title = self.category!.title
        }
        
        let bundle = NSBundle.mainBundle()
        self.collectionView!.registerNib(UINib(nibName: "ForumCategoryCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: CategoryCellIdentifier)
        self.collectionView!.registerNib(UINib(nibName: "ForumThreadCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: ThreadCellIdentifier)
        self.collectionView!.registerNib(UINib(nibName: "TableHeaderCollectionReusableView", bundle: bundle), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIdentifier)
        
#if !DEBUG && !TEST
        // Analytics
        PFAnalytics.trackEvent("forum", dimensions: ["type": "list"])
#endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
        self.categories?.removeAll(keepCapacity: false)
        self.categories = nil
        self.threads?.removeAll(keepCapacity: false)
        self.threads = nil
        self.collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if self.threadRepo != nil {
            return 2
        }
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == CategorySection {
            return self.categories?.count ?? 0
        } else if section == ThreadSection {
            return self.threads?.count ?? 0
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == CategorySection {
            let width = self.isPad ? floor(collectionView.frame.width / 2.0) : collectionView.frame.width
            return CGSizeMake(width, 104.0)
        }
        return CGSizeMake(collectionView.frame.width, 64.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == CategorySection && (self.categories == nil || self.categories!.isEmpty) {
            return CGSizeZero
        }
        
        return CGSizeMake(0, 22.0)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == CategorySection && self.threadRepo != nil { return CGSizeZero }
        return super.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        if indexPath.section == CategorySection {
            let categoryCell = collectionView.dequeueReusableCellWithReuseIdentifier(CategoryCellIdentifier, forIndexPath: indexPath) as! ForumCategoryCollectionViewCell
            self.setupCategoryCell(categoryCell, indexPath: indexPath)
            cell = categoryCell
        } else if indexPath.section == ThreadSection {
            let threadCell = collectionView.dequeueReusableCellWithReuseIdentifier(ThreadCellIdentifier, forIndexPath: indexPath) as! ForumThreadCollectionViewCell
            self.setupThreadCell(threadCell, indexPath: indexPath)
            cell = threadCell
        } else {
            // Safeguard, should not happen
            cell = UICollectionViewCell()
        }
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: HeaderIdentifier, forIndexPath: indexPath) as! TableHeaderCollectionReusableView
            view.titleLabel.text = indexPath.section == CategorySection ? CategoriesSectionTitle : ThreadsSectionTitle
            view.applyTheme(self.theme)
            return view
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if indexPath.section == CategorySection {
            // Category
            let category = self.categories![cell!.tag]
            
            // Special case for Developer Tracker, treat this sub category as a thread
            if category.id == self.settings.devTrackerId {
                let thread = ForumThread.devTracker()
                self.performSegueWithIdentifier(ThreadSegue, sender: thread)
                return
            }
            
            self.performSegueWithIdentifier(SubCategorySegue, sender: category)
        } else {
            // Thread
            let thread = self.threads![cell!.tag]
            self.performSegueWithIdentifier(ThreadSegue, sender: thread)
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SubCategorySegue {
            let controller = segue.destinationViewController as! ForumListCollectionViewController
            let category = sender as! ForumCategory
            controller.category = category
        } else if segue.identifier == ThreadSegue {
            let controller = segue.destinationViewController as! ForumThreadCollectionViewController
            let thread = sender as! ForumThread
            controller.thread = thread
        }
    }
    
    // MARK: - Helper methods
    
    private func hasCategories() -> Bool {
        if let categories = self.categories {
            return categories.count > 0
        }
        return false
    }
    
    private func hasThreads() -> Bool {
        if let threads = self.threads {
            return threads.count > 0
        }
        return false
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
            // Check for error state
            if requestCount == -1 { return }
            
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
            self.collectionView!.reloadSections(NSIndexSet(index: CategorySection))
            finishLoad()
        }
        func threadSuccess(threads: Array<ForumThread>) {
            // Set retrieved threads and reload the thread section
            self.threads = threads
            self.collectionView!.reloadSections(NSIndexSet(index: ThreadSection))
            finishLoad()
        }
        func failure(error: NSError) {
            // Check for error state
            if requestCount == -1 { return }
            // Set an error state on the requestCount variable
            dispatch_sync(lock) { requestCount = -1 }
            
            self.refreshControl?.endRefreshing()
            let alert = self.alertFactory.createAlert(self, title: "Network error", message: "Something went wrong while loading the data. Would you like to try again?", buttons:
                (style: .Cancel, title: "No", { self.hideLoader() }),
                (style: .Default, title: "Yes", { self.onRefresh() })
            )
            alert.show()
        }
        
        if let category = self.category {
            // Load subcategories and threads for the current category
            requestCount = 2
            self.categoryRepo.get(category: category, success: categorySuccess, failure: failure)
            self.threadRepo!.get(category: category, page: 1, success: threadSuccess, failure: failure)
        } else {
            // Forum root, only load categories
            requestCount = 1
            self.categoryRepo.get(language: self.settings.forumLanguage, success: categorySuccess, failure: failure)
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
            self.collectionView!.insertItemsAtIndexPaths(indexes)
            
            // Mark this page as loaded and enable infinite scroll again
            self.loadedPage++
            self.canLoadMore = true
        }
        func failure(error: NSError) {
            let alert = self.alertFactory.createAlert(self, title: "Network error", message: "Something went wrong while loading the data. Would you like to try again?", buttons:
                (style: .Cancel, title: "No", { self.hideLoader() }),
                (style: .Default, title: "Yes", { self.onRefresh() })
            )
            alert.show()
        }
        
        self.threadRepo!.get(category: self.category!, page: self.loadedPage + 1, success: success, failure: failure)
    }
    
    private func setupCategoryCell(cell: ForumCategoryCollectionViewCell, indexPath: NSIndexPath) {
        let category = self.categories![indexPath.row]
        
        // Set category icon if URL is defined in the model
        if let url = category.iconUrl {
            cell.iconImageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "CategoryIcon"))
        }
        
        cell.titleLabel.text = category.title
        cell.statsLabel.text = category.stats
        cell.lastPostLabel.text = category.lastPost
        cell.applyTheme(self.theme)
        
        cell.tag = indexPath.row
    }
    
    private func setupThreadCell(cell: ForumThreadCollectionViewCell, indexPath: NSIndexPath) {
        let thread = self.threads![indexPath.row]
        
        // Set dev icon if thread is marked as having Bioware reply
        if thread.hasBiowareReply {
            cell.devImageView.hidden = false
            cell.devImageView.sd_setImageWithURL(NSURL(string: self.settings.devTrackerIconUrl), placeholderImage: UIImage(named: "DevTrackerIcon"))
        } else {
            cell.devImageView.hidden = true
        }
        
        // Set sticky icon if thread is marked with sticky
        if thread.isSticky {
            cell.stickyImageView.hidden = false
            cell.stickyImageView.sd_setImageWithURL(NSURL(string: self.settings.stickyIconUrl), placeholderImage: UIImage(named: "StickyIcon"))
        } else {
            cell.stickyImageView.hidden = true
        }
        
        cell.titleLabel.text = thread.title
        cell.authorLabel.text = thread.author
        cell.repliesViewsLabel.text = "R: \(thread.replies), V: \(thread.views)"
        cell.applyTheme(self.theme)
        
        cell.tag = indexPath.row
    }
    
    // MARK: - Themeable
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme)
        
        self.view.backgroundColor = theme.contentBackground
        self.collectionView!.backgroundColor = theme.contentBackground
    }

}
