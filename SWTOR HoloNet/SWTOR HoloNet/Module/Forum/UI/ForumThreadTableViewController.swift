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
    private let PostsPerPage = 10

    // MARK: - Properties

    var thread: ForumThread!
    
    private var postRepo: ForumPostRepository!
    private var posts: Array<ForumPost>?
    
    // MARK: - Outlets
    
    @IBOutlet var titleView: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postRepo = ForumPostRepository(settings: self.settings)
        
        // Set so each row will resize to fit content
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 110.0
        
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
        
        self.view.backgroundColor = self.theme.contentBackground
        self.tableView.backgroundColor = self.theme.contentBackground
        self.titleView.backgroundColor = self.theme.contentBackground
        self.titleLabel.textColor = self.theme.contentTitle
        
        self.onRefresh()
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PostCellIdentifier, forIndexPath: indexPath) as ForumPostTableViewCell

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
        
        cell.dateLabel.text = "\(post.date) | #\(post.postNumber)"
        cell.usernameLabel.text = post.username
        cell.textView.text = post.text
        cell.applyTheme(self.theme)
        
        cell.tag = indexPath.row

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
            println(error)
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
            println(error)
        }
        
        self.postRepo.get(thread: self.thread, page: self.loadedPage + 1, success: success, failure: failure)
    }

}
