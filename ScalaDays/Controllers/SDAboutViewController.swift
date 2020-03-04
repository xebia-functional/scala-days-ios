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
    @IBOutlet weak var separatorH: NSLayoutConstraint!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var errorPlaceholderView : SDErrorPlaceholderView!
    var isDataLoaded = false
    
    private(set) var selectedConference : Conference?
    private let analytics: Analytics
    
    init(analytics: Analytics) {
        self.analytics = analytics
        super.init(nibName: String(describing: SDAboutViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = i18n.codeConductTitle
        self.setNavigationBarItem()
        
        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)
        
        setupAppareance()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isDataLoaded { loadData() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.logScreenName(.about, class: SDAboutViewController.self)
    }
    
    private func setupAppareance() {
        separatorH.constant = 0.25
        descriptionTextView.textColor = UIColor.appColor()
        descriptionTextView.linkTextAttributes = [.foregroundColor: UIColor.appRedColor()]
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
                        self.descriptionTextView.textHTML = conference.codeOfConduct
                    }
                } else {
                    self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
                }
            }
        }
    }

    @IBAction func didTapOn47Logo(_ sender: AnyObject) {
        guard let url = URL(string: url47Website) else { return }
        
        analytics.logEvent(screenName: .about, category: .navigate, action: .goToSite)
        launchSafariToUrl(url)
    }
    
    // MARK: SDErrorPlaceholderViewDelegate protocol implementation
    
    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }
    
    enum i18n {
        static let codeConductTitle = NSLocalizedString("code_conduct", comment: "")
    }
}
