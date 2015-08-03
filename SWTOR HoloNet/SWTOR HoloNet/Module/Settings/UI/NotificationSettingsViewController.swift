//
//  NotificationSettingsViewController.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 04/03/15.
//  Copyright (c) 2015 Ivan Fabijanović. All rights reserved.
//

import UIKit
import QuartzCore
import Parse

class NotificationSettingsViewController: BaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var thenLabel: UILabel!
    
    @IBOutlet weak var settingsImageView: UIImageView!
    @IBOutlet weak var notificationCenterImageView: UIImageView!
    @IBOutlet weak var holoNetImageView: UIImageView!
    
    @IBOutlet weak var largeFrameImageView: UIImageView!
    @IBOutlet weak var noneImageView: UIImageView!
    @IBOutlet weak var bannersImageView: UIImageView!
    @IBOutlet weak var alertsImageView: UIImageView!
    
    @IBOutlet weak var smallFrameImageView: UIImageView!
    @IBOutlet weak var showOnLockScreenLabel: UILabel!
    @IBOutlet weak var onOffView: UIView!
    @IBOutlet weak var onOffImageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadImages()
        self.applyTheme(self.theme)
        
        let status = InstanceHolder.sharedInstance().pushManager.isPushEnabled ? "enabled" : "disabled"
        self.titleLabel.text = "Notifications are \(status)"
        
#if !DEBUG && !TEST
        // Analytics
        PFAnalytics.trackEvent("settings", dimensions: ["page":"notification"])
#endif
    }
    
    private func loadImages() {
        self.settingsImageView.layer.cornerRadius = 5.0
        self.settingsImageView.layer.masksToBounds = true
        self.settingsImageView.image = UIImage(named: "TintSettings")?.imageWithRenderingMode(.AlwaysTemplate)
        
        self.notificationCenterImageView.layer.cornerRadius = 5.0
        self.notificationCenterImageView.layer.masksToBounds = true
        self.notificationCenterImageView.image = UIImage(named: "TintNotificationCenter")?.imageWithRenderingMode(.AlwaysTemplate)
        
        self.holoNetImageView.layer.cornerRadius = 5.0
        self.holoNetImageView.layer.masksToBounds = true
        self.holoNetImageView.image = UIImage(named: "TintHoloNet")?.imageWithRenderingMode(.AlwaysTemplate)
        
        self.largeFrameImageView.image = UIImage(named: "TintFrameLarge")?.imageWithRenderingMode(.AlwaysTemplate)
        self.noneImageView.image = UIImage(named: "TintPushNone")?.imageWithRenderingMode(.AlwaysTemplate)
        self.bannersImageView.image = UIImage(named: "TintPushBanners")?.imageWithRenderingMode(.AlwaysTemplate)
        self.alertsImageView.image = UIImage(named: "TintPushAlerts")?.imageWithRenderingMode(.AlwaysTemplate)
        
        self.smallFrameImageView.image = UIImage(named: "TintFrameSmall")?.imageWithRenderingMode(.AlwaysTemplate)
        self.onOffView.layer.cornerRadius = 10.0
        self.onOffView.layer.masksToBounds = true
        self.onOffImageView.image = UIImage(named: "TintOnSwitch")?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    // MARK: - Themeable
    
    override func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.contentBackground
        
        self.settingsImageView.tintColor = theme.instructionsIcon
        self.settingsImageView.backgroundColor = theme.instructionsIconBackground
        self.notificationCenterImageView.tintColor = theme.instructionsIcon
        self.notificationCenterImageView.backgroundColor = theme.instructionsIconBackground
        self.holoNetImageView.tintColor = theme.instructionsIcon
        self.holoNetImageView.backgroundColor = theme.instructionsIconBackground
        
        self.titleLabel.textColor = theme.instructionsIconBackground
        self.infoLabel.textColor = theme.instructionsFrame
        
        self.step1Label.textColor = theme.instructionsIconBackground
        self.step2Label.textColor = theme.instructionsIconBackground
        self.step3Label.textColor = theme.instructionsIconBackground
        self.thenLabel.textColor = theme.instructionsIconBackground
        
        self.largeFrameImageView.tintColor = theme.instructionsFrame
        self.noneImageView.tintColor = theme.instructionsFrame
        self.bannersImageView.tintColor = theme.instructionsIconBackground
        self.alertsImageView.tintColor = theme.instructionsFrame
        
        self.smallFrameImageView.tintColor = theme.instructionsFrame
        self.showOnLockScreenLabel.textColor = theme.instructionsIconBackground
        self.onOffView.backgroundColor = theme.instructionsIconBackground
        self.onOffImageView.tintColor = theme.instructionsIcon
    }
    
}
