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

    // MARK: - Properties

    private var settings: Settings?
    private var thread: ForumThread?
    
    private var postRepo: ForumPostRepository?
    private var posts: Array<ForumPost>?
    
    private var threadPage = 1
    
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

        if let url = post.avatarUrl {
            avatarImageView.hidden = false
            avatarImageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "Avatar"))
        } else {
            avatarImageView.hidden = true
        }
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
        func success(posts: Array<ForumPost>) {
            self.posts = posts
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        func failure(error: NSError) {
            println(error)
        }
        
        self.postRepo!.get(thread: self.thread!, page: 1, success: success, failure: failure)
    }

}
