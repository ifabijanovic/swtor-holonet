//
//  ForumThreadCollectionViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 20/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadCollectionViewController: ForumBaseCollectionViewController {

    // MARK: - Constants
    
    private let PostCellIdentifier = "postCell"
    private let PostSegue = "postSegue"
    private let HeaderIdentifier = "header"
    private var PostsPerPage = 10
    
    // MARK: - Properties
    
    var thread: ForumThread!
    
    private var postRepo: ForumPostRepository!
    private var posts: Array<ForumPost>?
    
    private var sizingCell: ForumPostCollectionViewCell!
    
    // MARK: - Outlets
    
    @IBAction func safariTapped(sender: AnyObject) {
        let urlString = self.postRepo.url(thread: self.thread, page: 0)
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        // Poor man's dependency injection, remove ASAP
        InstanceHolder.sharedInstance().inject(self)
        
        super.viewDidLoad()
        
        self.postRepo = ForumPostRepository(settings: self.settings)
        
        let bundle = NSBundle.mainBundle()
        let cellNib = UINib(nibName: "ForumPostCollectionViewCell", bundle: bundle)
        self.sizingCell = cellNib.instantiateWithOwner(nil, options: nil).first as ForumPostCollectionViewCell
        
        self.collectionView!.registerNib(cellNib, forCellWithReuseIdentifier: PostCellIdentifier)
        self.collectionView!.registerNib(UINib(nibName: "ForumThreadHeaderCollectionReusableView", bundle: bundle), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIdentifier)
        
        if thread.isDevTracker {
            self.PostsPerPage = 20
        }
        
        self.onRefresh()
        
#if !DEBUG && !TEST
        // Analytics
        PFAnalytics.trackEvent("forum", dimensions: ["type": "thread"])
#endif

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.posts?.removeAll(keepCapacity: false)
        self.posts = nil
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.calculateSizeForItemAtIndexPath(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Calculate height of title text
        let largeSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width - 30, 9999)
        let font = UIFont.systemFontOfSize(17.0)
        let attributes = [NSFontAttributeName: font]
        let titleSize = (self.thread.title as NSString).boundingRectWithSize(largeSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil).size
        let titleHeight = ceil(titleSize.height)

        return CGSizeMake(0, titleHeight + 16.0)
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PostCellIdentifier, forIndexPath: indexPath) as ForumPostCollectionViewCell
        
        self.fillCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: HeaderIdentifier, forIndexPath: indexPath) as ForumThreadHeaderCollectionReusableView
            header.textLabel.text = self.thread.title
            header.applyTheme(self.theme)
            return header
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        self.performSegueWithIdentifier(PostSegue, sender: cell)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == PostSegue {
            let controller = segue.destinationViewController as ForumPostViewController
            let cell = sender as UICollectionViewCell
            let post = self.posts![cell.tag]
            controller.post = post
        }
    }
    
    // MARK: - Helper methods
    
    override func onRefresh() {
        // Reloading content, set loaded page back to the first page
        self.loadedPage = 1
        // Disable infinite scroll while loading
        self.canLoadMore = false
        // Show loading indicator
        self.showLoader()
        
        func success(posts: Array<ForumPost>) {
            // Set retrieved posts and reload table
            self.posts = posts
            self.collectionView!.reloadData()
            self.refreshControl?.endRefreshing()
            // Enable infinite scroll if initial page is full
            if posts.count == PostsPerPage {
                self.canLoadMore = true
            } else {
                self.canLoadMore = false
                self.hideLoader()
            }
        }
        func failure(error: NSError) {
            self.refreshControl?.endRefreshing()
            let alert = self.alertFactory.createAlert(self, title: "Network error", message: "Something went wrong while loading the data. Would you like to try again?", buttons:
                (style: .Cancel, title: "No", { self.hideLoader() }),
                (style: .Default, title: "Yes", { self.onRefresh() })
            )
            alert.show()
        }
        
        self.postRepo.get(thread: self.thread, page: 1, success: success, failure: failure)
    }
    
    override func onLoadMore() {
        // Disable infinite scroll while loading
        self.canLoadMore = false
        
        func success(posts: Array<ForumPost>) {
            // Get a difference of freshly loaded posts with the ones already loaded before
            let newPosts = posts.difference(self.posts!)
            
            if newPosts.isEmpty {
                // No new posts, disable infinite scrolling
                self.canLoadMore = false
                self.hideLoader()
                return
            }
            
            // Append the new posts and prepare indexes for table update
            var indexes = Array<NSIndexPath>()
            for post in newPosts {
                indexes.append(NSIndexPath(forRow: self.posts!.count, inSection: 0))
                self.posts!.append(post)
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
        
        self.postRepo.get(thread: self.thread, page: self.loadedPage + 1, success: success, failure: failure)
    }
    
    func fillCell(cell: ForumPostCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        let post = self.posts![indexPath.row]
        
        // Set user avatar image if URL is defined in the model
        if let url = post.avatarUrl {
            cell.avatarImageView.hidden = false
            cell.avatarImageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "Avatar"))
        } else {
            cell.avatarImageView.hidden = true
        }
        
        // Set dev icon if post is marked as Bioware post
        if post.isBiowarePost {
            cell.devImageView.hidden = false
            cell.devImageView.sd_setImageWithURL(NSURL(string: self.settings.devTrackerIconUrl), placeholderImage: UIImage(named: "DevTrackerIcon"))
        } else {
            cell.devImageView.hidden = true
        }
        
        cell.dateLabel.text = post.postNumber != nil ? "\(post.date) | #\(post.postNumber!)" : post.date
        cell.usernameLabel.text = post.username
        cell.textView.text = post.text
        cell.applyTheme(self.theme)
        
        cell.tag = indexPath.row
    }
    
    func calculateSizeForItemAtIndexPath(indexPath: NSIndexPath) -> CGSize {
        if let cell = self.sizingCell {
            // Fill it with data
            self.fillCell(cell, atIndexPath: indexPath)
            cell.textView.preferredMaxLayoutWidth = CGRectGetWidth(self.collectionView!.frame) - 30.0
            // Now that it has data tell it to size itself
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)

            return CGSizeMake(self.collectionView!.frame.size.width, size.height)
        }
        return CGSizeZero
    }
    
    // MARK: - Themeable
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme)
        
        self.view.backgroundColor = theme.contentBackground
        self.collectionView!.backgroundColor = theme.contentBackground
    }

}
