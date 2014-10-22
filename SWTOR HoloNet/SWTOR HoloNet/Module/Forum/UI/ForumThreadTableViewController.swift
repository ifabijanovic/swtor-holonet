//
//  ForumThreadTableViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 22/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class ForumThreadTableViewController: UITableViewController {

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
        self.tableView.estimatedRowHeight = 44.0
        
        func success(posts: Array<ForumPost>) {
            self.posts = posts
            self.tableView.reloadData()
        }
        func failure(error: NSError) {
            println(error)
        }
        
        self.postRepo!.get(thread: self.thread!, page: 1, success: success, failure: failure)
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
        cell.textLabel.text = post.text

        return cell
    }

}
