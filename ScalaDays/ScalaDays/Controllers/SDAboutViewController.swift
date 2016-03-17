/*
* Copyright (C) 2015 47 Degrees, LLC http://47deg.com hello@47deg.com
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License. You may obtain
* a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import SVProgressHUD

class SDAboutViewController: GAITrackedViewController, SDErrorPlaceholderViewDelegate, SDMenuControllerItem {

    @IBOutlet weak var cnsLeftLabel: NSLayoutConstraint!
    @IBOutlet weak var cnsRightLabel: NSLayoutConstraint!
    @IBOutlet weak var lblCodeConduct: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var errorPlaceholderView : SDErrorPlaceholderView!
    var isDataLoaded = false
    
    var selectedConference : Conference?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("about", comment: "About")
        self.lblCodeConduct.setCustomFont(UIFont.fontHelveticaNeueMedium(17), colorFont: UIColor.appRedColor())
        self.lblDescription.setCustomFont(UIFont.fontHelveticaNeueLight(15), colorFont: UIColor.appColor())
        
        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)
        
        loadData()
        
        self.screenName = kGAScreenNameAbout
    }

    override func viewWillAppear(animated: Bool) {
        if !isDataLoaded {
            loadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.lblDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width
            - self.cnsLeftLabel.constant
            - self.cnsRightLabel.constant
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Data loading
    
    func loadData() {
        SVProgressHUD.show()
        DataManager.sharedInstance.loadDataJson() {
            (bool, error) -> () in
            
            if let _ = error {
                self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
                SVProgressHUD.dismiss()
            } else {
                self.selectedConference = DataManager.sharedInstance.currentlySelectedConference
                self.isDataLoaded = true
                
                SVProgressHUD.dismiss()
                
                if let conference = self.selectedConference {
                    if conference.codeOfConduct == "" {
                        self.errorPlaceholderView.show(NSLocalizedString("error_insufficient_content", comment: ""), isGeneralMessage: true)
                    } else {
                        self.errorPlaceholderView.hide()
                        self.lblDescription.text = conference.codeOfConduct
                    }
                } else {
                    self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
                }
            }
        }
    }

    @IBAction func didTapOn47Logo(sender: AnyObject) {
        SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameAbout, category: nil, action: kGAActionAboutGoToSite, label: nil)
        launchSafariToUrl(NSURL(string: url47Website)!)
    }
    
    // MARK: SDErrorPlaceholderViewDelegate protocol implementation
    
    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }
    
}
