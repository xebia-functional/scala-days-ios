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

class SDAboutViewController: UIViewController, SDErrorPlaceholderViewDelegate, SDMenuControllerItem {

    @IBOutlet weak var cnsLeftLabel: NSLayoutConstraint!
    @IBOutlet weak var cnsRightLabel: NSLayoutConstraint!
    @IBOutlet weak var lblCodeConduct: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var separatorH: NSLayoutConstraint!
    
    var errorPlaceholderView : SDErrorPlaceholderView!
    var isDataLoaded = false
    
    private(set) var selectedConference : Conference?
    private let analytics: Analytics
    
    private var feedbackURL: URL? {
        guard let feedback = selectedConference?.info.feedback else { return nil }
        return URL(string: feedback)
    }
    
    init(analytics: Analytics) {
        self.analytics = analytics
        super.init(nibName: String(describing: SDAboutViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("about", comment: "About")
        
        self.separatorH.constant = 0.25
        
        self.lblCodeConduct.setCustomFont(UIFont.fontHelveticaNeueMedium(17), colorFont: UIColor.appRedColor())
        self.lblDescription.setCustomFont(UIFont.fontHelveticaNeueLight(15), colorFont: UIColor.appColor())
        
        self.feedbackButton.setTitle(i18n.feebackTitle, for: .normal)
        self.feedbackButton.setTitleColor(.white, for: .normal)
        self.feedbackButton.backgroundColor = UIColor.appRedColor()
        
        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)
        
        loadData()
        
        self.analytics.logScreenName(.about, class: SDAboutViewController.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        if !isDataLoaded {
            loadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.lblDescription.preferredMaxLayoutWidth = UIScreen.main.bounds.width
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

    @IBAction func didTapOn47Logo(_ sender: AnyObject) {
        guard let url = URL(string: url47Website) else { return }
        
        self.analytics.logEvent(screenName: .about, category: .navigate, action: .goToSite)
        launchSafariToUrl(url)
    }
    
    @IBAction func didTapOnFeedback(_ button: UIButton) {
        guard let feedbackURL = feedbackURL else { return }
        
        self.analytics.logEvent(screenName: .about, category: .navigate, action: .goToFeedbackForm)
        launchSafariToUrl(feedbackURL)
    }
    
    // MARK: SDErrorPlaceholderViewDelegate protocol implementation
    
    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }
    
    enum i18n {
        static let feebackTitle = NSLocalizedString("feeback_button", comment: "")
    }
}
