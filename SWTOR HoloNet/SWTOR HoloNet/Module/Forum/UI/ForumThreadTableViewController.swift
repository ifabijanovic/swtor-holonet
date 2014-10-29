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
    private let PostsPerPage = 10

    // MARK: - Properties

    private var settings: Settings?
    private var thread: ForumThread?
    
    private var postRepo: ForumPostRepository?
    private var posts: Array<ForumPost>?
    
    // MARK: - Public methods

    func setup(#settings: Settings, thread: ForumThread) {
        self.settings = settings
        self.thread = thread
        self.postRepo = ForumPostRepository(settings: settings)
        self.navigationItem.title = thread.title
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set so each row will resize to fit content
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 94.0
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier(PostCellIdentifier, forIndexPath: indexPath) as UITableViewCell

        let post = self.posts![indexPath.row]
        let avatarImageView = cell.viewWithTag(100) as UIImageView
        let dateLabel = cell.viewWithTag(101) as UILabel
        let usernameLabel = cell.viewWithTag(102) as UILabel
        let textLabel = cell.viewWithTag(103) as UILabel
        let devImageView = cell.viewWithTag(104) as UIImageView

        // Set user avatar image if URL is defined in the model
        if let url = post.avatarUrl {
            avatarImageView.hidden = false
            avatarImageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "Avatar"))
        } else {
            avatarImageView.hidden = true
        }
        
        // Set dev icon if post is marked as Bioware post
        if post.isBiowarePost {
            devImageView.hidden = false
            devImageView.sd_setImageWithURL(NSURL(string: self.settings!.devTrackerIconUrl), placeholderImage: UIImage(named: "DevTrackerIcon"))
        } else {
            devImageView.hidden = true
        }
        
        dateLabel.text = "\(post.date) | #\(post.postNumber)"
        usernameLabel.text = post.username
        textLabel.text = post.text

        return cell
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
        
        self.postRepo!.get(thread: self.thread!, page: 1, success: success, failure: failure)
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
        
        self.postRepo!.get(thread: self.thread!, page: self.loadedPage + 1, success: success, failure: failure)
    }

}
