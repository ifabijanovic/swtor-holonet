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
        super.viewDidLoad()

        self.categoryRepo = ForumCategoryRepository(settings: self.settings)
        if self.category != nil {
            // Threads exist only inside categories, not in forum root
            self.threadRepo = ForumThreadRepository(settings: self.settings)
            self.navigationItem.title = self.category!.title
        }
        
        let bundle = Bundle.main
        self.collectionView!.register(UINib(nibName: "ForumCategoryCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: CategoryCellIdentifier)
        self.collectionView!.register(UINib(nibName: "ForumThreadCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: ThreadCellIdentifier)
        self.collectionView!.register(UINib(nibName: "TableHeaderCollectionReusableView", bundle: bundle), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIdentifier)
        
#if !DEBUG && !TEST
        // Analytics
        PFAnalytics.trackEvent("forum", dimensions: ["type": "list"])
#endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Controller is being popped from the navigation stack
        if self.isMovingFromParentViewController {
            // Cancel any pending requests to prevent wasted processing
            self.categoryRepo.cancelAllOperations()
            self.threadRepo?.cancelAllOperations()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
        self.categories?.removeAll(keepingCapacity: false)
        self.categories = nil
        self.threads?.removeAll(keepingCapacity: false)
        self.threads = nil
        self.collectionView?.reloadData()
    }

    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.threadRepo != nil {
            return 2
        }
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == CategorySection {
            return self.categories?.count ?? 0
        } else if section == ThreadSection {
            return self.threads?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // This value represents the difference from currently selected text size and
        // the smallest (default) value. It is added to the cell height for each label
        let textSizeDiff = self.theme.textSize.rawValue - TextSize.Small.rawValue
        let width: CGFloat
        let height: CGFloat
            
        if indexPath.section == CategorySection {
            width = self.isPad ? floor(collectionView.frame.width / 2.0) : collectionView.frame.width
            height = 104.0 + (3 * textSizeDiff)
        } else {
            width = collectionView.frame.width
            height = 64.0 + (2 * textSizeDiff)
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == CategorySection && (self.categories == nil || self.categories!.isEmpty) {
            return CGSize.zero
        }
        
        return CGSize(width: 0, height: 22.0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == CategorySection && self.threadRepo != nil { return CGSize.zero }
        return super.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        if indexPath.section == CategorySection {
            let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCellIdentifier, for: indexPath) as! ForumCategoryCollectionViewCell
            self.setupCategoryCell(categoryCell, indexPath: indexPath)
            cell = categoryCell
        } else if indexPath.section == ThreadSection {
            let threadCell = collectionView.dequeueReusableCell(withReuseIdentifier: ThreadCellIdentifier, for: indexPath) as! ForumThreadCollectionViewCell
            self.setupThreadCell(threadCell, indexPath: indexPath)
            cell = threadCell
        } else {
            // Safeguard, should not happen
            cell = UICollectionViewCell()
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderIdentifier, for: indexPath) as! TableHeaderCollectionReusableView
            view.titleLabel.text = indexPath.section == CategorySection ? CategoriesSectionTitle : ThreadsSectionTitle
            view.applyTheme(self.theme)
            return view
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let cell = collectionView.cellForItem(at: indexPath)
        if indexPath.section == CategorySection {
            // Category
            let category = self.categories![cell!.tag]
            
            // Special case for Developer Tracker, treat this sub category as a thread
            if category.id == self.settings.devTrackerId {
                let thread = ForumThread.devTracker()
                self.performSegue(withIdentifier: ThreadSegue, sender: thread)
                return
            }
            
            self.performSegue(withIdentifier: SubCategorySegue, sender: category)
        } else {
            // Thread
            let thread = self.threads![cell!.tag]
            self.performSegue(withIdentifier: ThreadSegue, sender: thread)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SubCategorySegue {
            let controller = segue.destination as! ForumListCollectionViewController
            let category = sender as! ForumCategory
            controller.category = category
        } else if segue.identifier == ThreadSegue {
            let controller = segue.destination as! ForumThreadCollectionViewController
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
        let lock = DispatchQueue(label: "com.if.lock")
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
            
            lock.sync() { requestCount -= 1 }
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
            self.collectionView!.reloadSections(IndexSet(integer: CategorySection))
            finishLoad()
        }
        func threadSuccess(threads: Array<ForumThread>) {
            // Set retrieved threads and reload the thread section
            self.threads = threads
            self.collectionView!.reloadSections(IndexSet(integer: ThreadSection))
            finishLoad()
        }
        func failure(error: Error) {
            // Check for error state
            if requestCount == -1 { return }
            // Set an error state on the requestCount variable
            lock.sync() { requestCount = -1 }
            
            self.refreshControl?.endRefreshing()
            
            let alert: Alert!
            
            if (error.isMaintenanceError()) {
                alert = self.alertFactory.createAlert(presenter: self, title: "Maintenance", message: "SWTOR.com is currently unavailable while scheduled maintenance is being performed.", buttons: (style: .default, title: "OK", { self.hideLoader() })
                )
            } else {
                alert = self.alertFactory.createAlert(presenter: self, title: "Network error", message: "Something went wrong while loading the data. Would you like to try again?", buttons:
                    (style: .cancel, title: "No", { self.hideLoader() }),
                    (style: .default, title: "Yes", { self.onRefresh() })
                )
            }
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
            let threadsSet = Set(threads)
            let cachedThreadsSet = Set(self.threads!)
            let newThreads = threadsSet.subtracting(cachedThreadsSet)
            
            if newThreads.isEmpty {
                // No new threads, disable infinite scrolling
                self.canLoadMore = false
                self.hideLoader()
                return
            }
            
            // Append the new threads and prepare indexes for table update
            var indexes = Array<IndexPath>()
            for thread in newThreads {
                indexes.append(IndexPath(row: self.threads!.count, section: ThreadSection))
                self.threads!.append(thread)
            }
            
            // Smoothly update the table by just inserting the new indexes
            self.collectionView!.insertItems(at: indexes)
            
            // Mark this page as loaded and enable infinite scroll again
            self.loadedPage += 1
            self.canLoadMore = true
        }
        func failure(error: Error) {
            let alert = self.alertFactory.createAlert(presenter: self, title: "Network error", message: "Something went wrong while loading the data. Would you like to try again?", buttons:
                (style: .cancel, title: "No", { self.hideLoader() }),
                (style: .default, title: "Yes", { self.onRefresh() })
            )
            alert.show()
        }
        
        self.threadRepo!.get(category: self.category!, page: self.loadedPage + 1, success: success, failure: failure)
    }
    
    private func setupCategoryCell(_ cell: ForumCategoryCollectionViewCell, indexPath: IndexPath) {
        let category = self.categories![indexPath.row]
        
        // Set category icon if URL is defined in the model
        if let url = category.iconUrl {
            cell.iconImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "CategoryIcon"))
        }
        
        cell.titleLabel.text = category.title
        cell.statsLabel.text = category.stats
        cell.lastPostLabel.text = category.lastPost
        cell.applyTheme(self.theme)
        
        cell.tag = indexPath.row
    }
    
    private func setupThreadCell(_ cell: ForumThreadCollectionViewCell, indexPath: IndexPath) {
        let thread = self.threads![indexPath.row]
        
        // Set dev icon if thread is marked as having Bioware reply
        if thread.hasBiowareReply {
            cell.devImageView.isHidden = false
            cell.devImageView.sd_setImage(with: URL(string: self.settings.devTrackerIconUrl), placeholderImage: UIImage(named: "DevTrackerIcon"))
        } else {
            cell.devImageView.isHidden = true
        }
        
        // Set sticky icon if thread is marked with sticky
        if thread.isSticky {
            cell.stickyImageView.isHidden = false
            cell.stickyImageView.sd_setImage(with: URL(string: self.settings.stickyIconUrl), placeholderImage: UIImage(named: "StickyIcon"))
        } else {
            cell.stickyImageView.isHidden = true
        }
        
        cell.titleLabel.text = thread.title
        cell.authorLabel.text = thread.author
        cell.repliesViewsLabel.text = "R: \(thread.replies), V: \(thread.views)"
        cell.applyTheme(self.theme)
        
        cell.tag = indexPath.row
    }
    
    // MARK: - Themeable
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        self.view.backgroundColor = theme.contentBackground
        self.collectionView!.backgroundColor = theme.contentBackground
    }

}
