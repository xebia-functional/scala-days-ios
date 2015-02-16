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

class SDSocialViewController: UIViewController {
    
    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var viewError : UIView!
    @IBOutlet weak var lblError : UILabel!
    
    let kReuseIdentifier = "socialViewControllerCell"
    var listOfTweets : Array<SDTweet> = []
    let socialHandler = SDSocialHandler()
    lazy var refreshControl = UIRefreshControl()
    var isFirstLoad : Bool = true
    lazy var selectedConference : Conference? = DataManager.sharedInstance.currentlySelectedConference
    var hashtag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("social",comment: "social")
        
        let barButtonCreateTweet = UIBarButtonItem(image: UIImage(named: "navigation_bar_icon_create"), style: .Plain, target: self, action: "didTapCreateTweetButton")
        self.navigationItem.rightBarButtonItem = barButtonCreateTweet
        
        tblView?.registerNib(UINib(nibName: "SDSocialTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        tblView?.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "didActivateRefresh", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool){
        self.tblView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        if let conference = selectedConference {
            hashtag = conference.info.hashtag
            reloadTweets()
        } else {
            // TODO: handle error if we don't have enough data from the servers to get the hashtag...
        }
    }
    
    // MARK: - Network access implementation
    
    func reloadTweets() {
        loadTweetData(kTweetCount, isRefreshing: false)
    }
    
    func refreshTweets() {
        loadTweetData(kTweetCount, isRefreshing: true)
    }
    
    func loadTweetData(count: Int, isRefreshing: Bool) {
        if isFirstLoad {
            isFirstLoad = false
        }
        
        if !isRefreshing {
            self.showProgressHUD()
        }
        
        if(hashtag != "") {
            socialHandler.requestTweetListWithHashtag(hashtag, count: count) { (tweets, error) -> Void in
                self.hideProgressHUD()
                
                switch(tweets, error) {
                case let (.Some(tweets), nil) :
                    self.listOfTweets = tweets as Array<SDTweet>
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.listOfTweets.count > 0 {
                            self.tblView.reloadData()
                            self.hideErrorFeedback()
                            self.showTableView()
                        } else {
                            self.showErrorFeedback(NSLocalizedString("social_error_no_tweets_for_current_hashtag", comment: ""))
                        }
                    }
                    
                default :
                    if let error = error {
                        var errorMessage : String = ""
                        
                        switch(error.code) {
                        case SDSocialErrors.AccountAccessNotGranted.rawValue:
                            errorMessage = NSLocalizedString("social_error_message_not_granted_access", comment: "")
                        case SDSocialErrors.NoTwitterAccountAvailable.rawValue:
                            errorMessage = NSLocalizedString("social_error_message_no_twitter_account_configured", comment: "")
                        case SDSocialErrors.NoValidDataFromAPI.rawValue, SDSocialErrors.InvalidRequest.rawValue:
                            if(self.listOfTweets.count == 0) {
                                errorMessage = NSLocalizedString("social_error_no_valid_tweets", comment: "")
                            }
                        default:
                            break
                        }
                        
                        if(errorMessage != "") {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.showErrorFeedback(errorMessage)
                            }
                        }
                    }
                }
            }
        } else {
            // TODO: handle error if we don't have enough data from the servers to get the hashtag...
        }
    }
    
    // MARK: - Tableview's refresh control
    
    func didActivateRefresh() {
        refreshTweets()
    }
    
    // MARK: - UITableViewDelegate protocol implementation
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(listOfTweets.count > indexPath.row) {
            let tweet = listOfTweets[indexPath.row] as SDTweet
            if let url = SDSocialHandler.urlForTweetDetail(tweet) {
                launchSafariToUrl(url)
            }
        }        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableViewAutomaticDimension
        }        
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as SDSocialTableViewCell
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    // MARK: UITableViewDataSource protocol implementation

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfTweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : SDSocialTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier) as? SDSocialTableViewCell
        switch cell {
        case let(.Some(cell)):
            return configureCell(cell, indexPath: indexPath)
        default:
            let cell = SDSocialTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kReuseIdentifier)
            return configureCell(cell, indexPath: indexPath)
        }
    }
    
    func configureCell(cell: SDSocialTableViewCell, indexPath: NSIndexPath) -> SDSocialTableViewCell {
        if(listOfTweets.count > indexPath.row) {
            let currentTweet : SDTweet = listOfTweets[indexPath.row]
            cell.drawTweetData(currentTweet)
        }
        cell.frame = CGRectMake(0, 0, tblView.bounds.size.width, cell.frame.size.height);
        cell.layoutIfNeeded()
        return cell
    }
    
    // MARK: - Error feedback
    
    func showErrorFeedback(message: String) {
        if(viewError.hidden) {
            lblError.text = message
            viewError.alpha = 0
            viewError.hidden = false
            UIView.animateWithDuration(kAnimationShowHideTimeInterval, animations: {() -> Void in
                self.viewError.alpha = 1.0
                return
                }, completion: { (delay) -> Void in
                    self.tblView.hidden = true
                    return
            })
        }
    }
    
    func hideErrorFeedback() {
        if(!viewError.hidden) {
            UIView.animateWithDuration(kAnimationShowHideTimeInterval, animations: {() -> Void in
                self.viewError.alpha = 0
                return
                }, completion: { (delay) -> Void in
                    self.viewError.alpha = 1.0
                    self.viewError.hidden = true
                    self.showTableView()
                    return
            })
        }
    }
    
    func showTableView() {
        if(tblView.hidden) {
            tblView.alpha = 0
            tblView.hidden = false
            UIView.animateWithDuration(kAnimationShowHideTimeInterval, animations: {() -> Void in
                self.tblView.alpha = 1
                return
            })
        }
    }
    
    @IBAction func didTapOnErrorView() {
        SVProgressHUD.show()
        reloadTweets()
    }
    
    // MARK: - Composing tweet
    
    func didTapCreateTweetButton() {
        let error = self.socialHandler.showTweetComposerWithTweetText(NSLocalizedString("social_default_message", comment: ""), onViewController: self)
        if(error != .NoError) {
            SDAlertViewHelper.showSimpleAlertViewOnViewController(self, title: nil, message: NSLocalizedString("social_error_message_no_twitter_account_configured", comment: ""), cancelButtonTitle: NSLocalizedString("common_ok", comment: ""), otherButtonTitle: nil, tag: nil, delegate: nil, handler: nil)
        }
    }
    
    // MARK: - Progress HUD
    
    func showProgressHUD() {
        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.show()
        })
    }
    
    func hideProgressHUD() {
        dispatch_async(dispatch_get_main_queue()) {
            SVProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
        }
    }
}
