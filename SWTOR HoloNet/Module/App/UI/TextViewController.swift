//
//  TextViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 19/12/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit

class TextViewController: BaseViewController {
    var file: String?
    var text: String?
    var analyticsEvent: String?
    var analyticsPropeties: [AnyHashable: Any]?
    
    fileprivate var textView: UITextView!
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTextView()
        self.automaticallyAdjustsScrollViewInsets = false
        
        if self.file != nil {
            let bundle = Bundle.main
            let path = bundle.path(forResource: file, ofType: "txt")
            if let path = path {
                let content = try? String(contentsOfFile: path, encoding: .utf8)
                self.textView.text = content
            }
        } else if self.text != nil {
            self.textView.text = self.text!
        }
        
        self.apply(theme: self.theme)
        
#if !DEBUG && !TEST
        if let event = self.analyticsEvent {
            if let properties = self.analyticsPropeties {
                self.analytics.track(event: event, properties: properties)
            } else {
                self.analytics.track(event: event)
            }
        }
#endif
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.textView.textContainerInset = UIEdgeInsetsMake(self.topLayoutGuide.length + 8, 8, self.bottomLayoutGuide.length + 8, 8)
        self.textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    private func setupTextView() {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8)
        self.view.addSubview(textView)
        self.textView = textView
        
        let views: [String: Any] = ["textView": textView]
        var constraints = [NSLayoutConstraint]()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[textView]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[textView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        
        self.view.backgroundColor = theme.contentBackground
        self.textView.backgroundColor = UIColor.clear
        self.textView.textColor = theme.contentText
        self.textView.font = UIFont.systemFont(ofSize: theme.textSize.rawValue)
        self.textView.indicatorStyle = theme.scrollViewIndicatorStyle
    }
}
