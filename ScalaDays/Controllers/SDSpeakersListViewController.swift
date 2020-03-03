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

class SDSpeakersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SDErrorPlaceholderViewDelegate, SDMenuControllerItem {
    
    @IBOutlet weak var tblView: UITableView!
    var errorPlaceholderView : SDErrorPlaceholderView!
    var isDataLoaded = false
    
    var speakers : Array<Speaker>?
    let kReuseIdentifier = "SpeakersListCell"
    private let analytics: Analytics
    
    init(analytics: Analytics) {
        self.analytics = analytics
        super.init(nibName: String(describing: SDSpeakersListViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarItem()
        self.title = NSLocalizedString("speakers",comment: "speakers")
        
        tblView.register(UINib(nibName: "SDSpeakersTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        
        if isIOS8OrLater() {
            tblView.estimatedRowHeight = kEstimatedDynamicCellsRowHeightHigh
        }
        
        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isDataLoaded { loadData() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.logScreenName(.speakers, class: SDSpeakersListViewController.self)
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
                self.speakers = DataManager.sharedInstance.currentlySelectedConference?.speakers
                self.isDataLoaded = true
                
                SVProgressHUD.dismiss()
                
                if let _speakers = self.speakers {
                    if _speakers.count == 0 {
                        self.errorPlaceholderView.show(NSLocalizedString("error_insufficient_content", comment: ""), isGeneralMessage: true)
                    } else {
                        self.errorPlaceholderView.hide()
                        self.tblView.reloadData()
                        self.showTableView()
                    }
                } else {
                    self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
                }
                
                self.tblView.reloadData()
                self.tblView.setContentOffset(CGPoint.zero, animated: true)
            }
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource implementation
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let listOfSpeakers = speakers {
            if listOfSpeakers.count > indexPath.row {
                let currentSpeaker = listOfSpeakers[indexPath.row]
                if let twitterAccount = currentSpeaker.twitter {
                    if let urlApp = SDSocialHandler.urlAppForTwitterAccount(twitterAccount) {
                        let result = launchSafariToUrl(urlApp)
                        if !result {
                            if let url = SDSocialHandler.urlForTwitterAccount(twitterAccount) {
                                launchSafariToUrl(url)
                            }
                        }

                        analytics.logEvent(screenName: .speakers, category: .navigate, action: .goToUser)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableView.automaticDimension
        }
        let cell = self.tableView(tableView, cellForRowAt: indexPath) as! SDSpeakersTableViewCell
        return cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let listOfSpeakers = speakers {
            return listOfSpeakers.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SDSpeakersTableViewCell? = tableView.dequeueReusableCell(withIdentifier: kReuseIdentifier) as? SDSpeakersTableViewCell
        switch cell {
        case let(.some(cell)):
            return configureCell(cell, indexPath: indexPath)
        default:
            let cell = SDSpeakersTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: kReuseIdentifier)
            return configureCell(cell, indexPath: indexPath)
        }
    }
    
    func configureCell(_ cell: SDSpeakersTableViewCell, indexPath: IndexPath) -> SDSpeakersTableViewCell {
        if let listOfSpeakers = speakers {
            if(listOfSpeakers.count > indexPath.row) {
                let speakerCell = cell as SDSpeakersTableViewCell
                speakerCell.drawSpeakerData(listOfSpeakers[indexPath.row])
                speakerCell.layoutSubviews()
            }
        }
        cell.frame = CGRect(x: 0, y: 0, width: tblView.bounds.size.width, height: cell.frame.size.height);
        cell.layoutIfNeeded()
        return cell
    }
    
    // MARK: SDErrorPlaceholderViewDelegate protocol implementation
    
    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }
    
    // Animations
    
    func showTableView() {
        if self.tblView.isHidden {
            SDAnimationHelper.showViewWithFadeInAnimation(self.tblView)
        }
    }
}
