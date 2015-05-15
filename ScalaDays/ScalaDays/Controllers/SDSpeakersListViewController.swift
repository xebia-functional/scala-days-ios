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

class SDSpeakersListViewController: GAITrackedViewController, SDErrorPlaceholderViewDelegate, SDMenuControllerItem {
    
    @IBOutlet weak var tblView: UITableView!
    var errorPlaceholderView : SDErrorPlaceholderView!
    var isDataLoaded = false
    
    var speakers : Array<Speaker>?
    let kReuseIdentifier = "SpeakersListCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarItem()
        self.title = NSLocalizedString("speakers",comment: "speakers")
        
        tblView.registerNib(UINib(nibName: "SDSpeakersTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        
        if isIOS8OrLater() {
            tblView.estimatedRowHeight = kEstimatedDynamicCellsRowHeightHigh
        }
        
        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)
        
        self.screenName = kGAScreenNameSpeakers
    }
    
    override func viewWillAppear(animated: Bool) {
        if !isDataLoaded {
            loadData()
        }
    }
    
    // MARK: - Data loading
    
    func loadData() {
        SVProgressHUD.show()
        DataManager.sharedInstance.loadDataJson() {
            (bool, error) -> () in
            
            if let badError = error {
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
                self.tblView.setContentOffset(CGPointZero, animated: true)
            }
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource implementation
   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let listOfSpeakers = speakers {
            if listOfSpeakers.count > indexPath.row {
                let currentSpeaker = listOfSpeakers[indexPath.row]
                if let twitterAccount = currentSpeaker.twitter {                    
                    if let url = SDSocialHandler.urlAppForTwitterAccount(twitterAccount) {
                        SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameSpeakers, category: kGACategoryNavigate, action: kGAActionSpeakersGoToUser, label: nil)
                        launchSafariToUrl(url)
                    } else if let url = SDSocialHandler.urlForTwitterAccount(twitterAccount) {
                        SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameSpeakers, category: kGACategoryNavigate, action: kGAActionSpeakersGoToUser, label: nil)
                        launchSafariToUrl(url)
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableViewAutomaticDimension
        }
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as SDSpeakersTableViewCell
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let listOfSpeakers = speakers {
            return listOfSpeakers.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : SDSpeakersTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier) as? SDSpeakersTableViewCell
        switch cell {
        case let(.Some(cell)):
            return configureCell(cell, indexPath: indexPath)
        default:
            let cell = SDSpeakersTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kReuseIdentifier)
            return configureCell(cell, indexPath: indexPath)
        }
    }
    
    func configureCell(cell: SDSpeakersTableViewCell, indexPath: NSIndexPath) -> SDSpeakersTableViewCell {
        if let listOfSpeakers = speakers {
            if(listOfSpeakers.count > indexPath.row) {
                let speakerCell = cell as SDSpeakersTableViewCell
                speakerCell.drawSpeakerData(listOfSpeakers[indexPath.row])
                speakerCell.layoutSubviews()
            }
        }
        cell.frame = CGRectMake(0, 0, tblView.bounds.size.width, cell.frame.size.height);
        cell.layoutIfNeeded()
        return cell
    }
    
    // MARK: SDErrorPlaceholderViewDelegate protocol implementation
    
    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }
    
    // Animations
    
    func showTableView() {
        if self.tblView.hidden {
            SDAnimationHelper.showViewWithFadeInAnimation(self.tblView)
        }
    }
}
