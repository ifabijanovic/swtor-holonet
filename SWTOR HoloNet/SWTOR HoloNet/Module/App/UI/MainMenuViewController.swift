//
//  MainMenuViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 21/10/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    // MARK: - Constants
    
    private let ForumSegue = "forumSegue"
    
    // MARK: - Properties
    
    private let settings = Settings()
    private let theme = Theme()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().barTintColor = self.theme.navBarBackground
        UINavigationBar.appearance().tintColor = self.theme.navBarText
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: self.theme.navBarText]
        
        self.view.backgroundColor = self.theme.contentBackground
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ForumSegue {
            let controller = segue.destinationViewController as ForumListTableViewController
            controller.setup(settings: self.settings, theme: self.theme)
        }
    }
    
}
