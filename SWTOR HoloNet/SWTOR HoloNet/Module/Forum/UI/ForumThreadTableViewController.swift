//
//  ForumThreadTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 22/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadTableViewController: ForumBaseTableViewController {

    // MARK: - Constants
    
    private let PostCellIdentifier = "postCell"
    private let PostSegue = "postSegue"
    private var PostsPerPage = 10

    // MARK: - Properties

    var thread: ForumThread!
    
    private var postRepo: ForumPostRepository!
    private var posts: Array<ForumPost>?
    
    private var sizingCell: ForumPostTableViewCell?
    private var onceToken: dispatch_once_t = 0
    
    // MARK: - Outlets
    
    @IBOutlet var titleView: UIView!
    @IBOutlet var titleLabel: UILabel!
    
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
        
        self.tableView.registerNib(UINib(nibName: "ForumPostTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: PostCellIdentifier)
        
        self.titleLabel.text = self.thread.title
        
        // Calculate height of title text
        let largeSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width - 30, 9999)
        let font = UIFont.systemFontOfSize(17.0)
        let attributes = [NSFontAttributeName: font]
        let titleSize = (self.thread.title as NSString).boundingRectWithSize(largeSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil).size
        let titleHeight = ceil(titleSize.height)
        
        // Set the height of header view
        var headerFrame = self.tableView.tableHeaderView!.frame
        headerFrame.size.height = titleHeight + 16
        self.tableView.tableHeaderView!.frame = headerFrame
        
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

    // MARK: - Table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.calculateHeightForCellAtIndexPath(indexPath)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PostCellIdentifier, forIndexPath: indexPath) as ForumPostTableViewCell

        self.fillCell(cell, atIndexPath: indexPath)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        self.performSegueWithIdentifier(PostSegue, sender: cell)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == PostSegue {
            let controller = segue.destinationViewController as ForumPostViewController
            let cell = sender as UITableViewCell
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
            self.tableView.reloadData()
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
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
            
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
    
    func fillCell(cell: ForumPostTableViewCell, atIndexPath indexPath: NSIndexPath) {
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
        cell.setDisclosureIndicator(self.theme)
        
        cell.tag = indexPath.row
    }
    
    func calculateHeightForCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        // Initialize the helper cell used for calculating height
        dispatch_once(&self.onceToken) {
            self.sizingCell = self.tableView.dequeueReusableCellWithIdentifier(self.PostCellIdentifier) as? ForumPostTableViewCell
        }
        
        if let cell = self.sizingCell {
            // Fill it with data
            self.fillCell(cell, atIndexPath: indexPath)
            cell.textView.preferredMaxLayoutWidth = CGRectGetWidth(self.tableView.frame) - 30.0
            // Now that it has data tell it to size itself
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            // Add 1.0 for the cell separator height
            return size.height + 1.0
        }
        return 0.0
    }
    
    // MARK: - Themeable
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme)
        
        self.view.backgroundColor = theme.contentBackground
        self.tableView.backgroundColor = theme.contentBackground
        self.titleView.backgroundColor = theme.contentBackground
        self.titleLabel.textColor = theme.contentTitle
    }

}
