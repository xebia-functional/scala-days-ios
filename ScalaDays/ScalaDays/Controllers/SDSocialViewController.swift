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

class SDSocialViewController: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource, SDErrorPlaceholderViewDelegate, SDMenuControllerItem {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewError: UIView!
    @IBOutlet weak var lblError: UILabel!

    var errorPlaceholderView: SDErrorPlaceholderView!

    let kReuseIdentifier = "socialViewControllerCell"
    var listOfTweets: Array<SDTweet> = []
    let socialHandler = SDSocialHandler()
    lazy var refreshControl = UIRefreshControl()
    var isFirstLoad: Bool = true
    var selectedConference: Conference?
    var hashtag = ""
    var query: String?
    var isDataLoaded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("social", comment: "social")

        let barButtonCreateTweet = UIBarButtonItem(image: UIImage(named: "navigation_bar_icon_create"), style: .plain, target: self, action: #selector(SDSocialViewController.didTapCreateTweetButton))
        self.navigationItem.rightBarButtonItem = barButtonCreateTweet

        tblView?.register(UINib(nibName: "SDSocialTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        tblView?.addSubview(refreshControl)
        if isIOS8OrLater() {
            tblView?.estimatedRowHeight = kEstimatedDynamicCellsRowHeightHigh
        }
        refreshControl.addTarget(self, action: #selector(SDSocialViewController.didActivateRefresh), for: UIControlEvents.valueChanged)

        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)

        self.screenName = kGAScreenNameSocial
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tblView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        if isDataLoaded {
            if let conference = selectedConference {
                query = conference.info.query
                hashtag = conference.info.hashtag
                reloadTweets()
            } else {
                loadData()
            }
        } else {
            loadData()
        }
    }

    // MARK: - Network access implementation

    func loadData() {
        SVProgressHUD.show()
        DataManager.sharedInstance.loadDataJson() {
            (bool, error) -> () in

            if let _ = error {
                self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
                SVProgressHUD.dismiss()
            } else {
                self.selectedConference = DataManager.sharedInstance.currentlySelectedConference

                SVProgressHUD.dismiss()

                if let conference = self.selectedConference {
                    self.hashtag = conference.info.hashtag
                    self.query = conference.info.query
                    self.reloadTweets()
                    self.isDataLoaded = true
                } else {
                    // Handling error if we don't have enough data from the servers to get the hashtag...
                    self.errorPlaceholderView.show(NSLocalizedString("social_error_no_valid_tweets", comment: ""))
                }
            }
        }
    }

    func reloadTweets() {
        loadTweetData(kTweetCount, isRefreshing: false)
    }

    func refreshTweets() {
        loadTweetData(kTweetCount, isRefreshing: true)
    }

    func loadTweetData(_ count: Int, isRefreshing: Bool) {
        if isFirstLoad {
            isFirstLoad = false
        }

        if !isRefreshing {
            self.showProgressHUD()
        }

        if let _query = query {
            if _query != "" {
                socialHandler.requestTweetListWithHashtag(_query, count: count) {
                    (tweets, error) -> Void in
                    self.hideProgressHUD()

                    switch (tweets, error) {
                    case let (.some(tweets), nil):
                        self.listOfTweets = tweets as! Array<SDTweet>
                        DispatchQueue.main.async {
                            if self.listOfTweets.count > 0 {
                                self.tblView.reloadData()
                                self.tblView.setContentOffset(CGPoint.zero, animated: true)
                                self.errorPlaceholderView.hide()
                                self.showTableView()
                            } else {
                                self.errorPlaceholderView.show(NSLocalizedString("social_error_no_tweets_for_current_hashtag", comment: ""))
                            }
                        }
                    default:
                        if let error = error {
                            var errorMessage: String = ""

                            switch (error.code) {
                            case SDSocialErrors.accountAccessNotGranted.rawValue:
                                errorMessage = NSLocalizedString("social_error_message_not_granted_access", comment: "")
                            case SDSocialErrors.noTwitterAccountAvailable.rawValue:
                                errorMessage = NSLocalizedString("social_error_message_no_twitter_account_configured", comment: "")
                            case SDSocialErrors.noValidDataFromAPI.rawValue, SDSocialErrors.invalidRequest.rawValue:
                                if (self.listOfTweets.count == 0) {
                                    errorMessage = NSLocalizedString("social_error_no_valid_tweets", comment: "")
                                }
                            default:
                                break
                            }

                            if (errorMessage != "") {
                                DispatchQueue.main.async {
                                    self.errorPlaceholderView.show(errorMessage)
                                }
                            }
                        }
                    }
                }
            } else {
                self.hideProgressHUD()
                self.errorPlaceholderView.show(NSLocalizedString("social_error_no_valid_tweets", comment: ""))
            }
        } else {
            self.hideProgressHUD()
            self.errorPlaceholderView.show(NSLocalizedString("social_error_no_valid_tweets", comment: ""))
        }
    }

    // MARK: - Tableview's refresh control

    @objc func didActivateRefresh() {
        refreshTweets()
    }

    // MARK: - UITableViewDelegate protocol implementation

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (listOfTweets.count > indexPath.row) {
            let tweet = listOfTweets[indexPath.row] as SDTweet
            if let urlApp = SDSocialHandler.urlAppForTweetDetail(tweet) {
                let result = launchSafariToUrl(urlApp)
                if !result {
                    if let url = SDSocialHandler.urlForTweetDetail(tweet) {
                        launchSafariToUrl(url)
                    }
                }
                SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameSpeakers, category: kGACategoryNavigate, action: kGAActionSpeakersGoToUser, label: nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableViewAutomaticDimension
        }
        let cell = self.tableView(tableView, cellForRowAt: indexPath) as! SDSocialTableViewCell
        return cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }

    // MARK: UITableViewDataSource protocol implementation

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfTweets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SDSocialTableViewCell? = tableView.dequeueReusableCell(withIdentifier: kReuseIdentifier) as? SDSocialTableViewCell
        switch cell {
        case let (.some(cell)):
            return configureCell(cell, indexPath: indexPath)
        default:
            let cell = SDSocialTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: kReuseIdentifier)
            return configureCell(cell, indexPath: indexPath)
        }
    }

    func configureCell(_ cell: SDSocialTableViewCell, indexPath: IndexPath) -> SDSocialTableViewCell {
        if (listOfTweets.count > indexPath.row) {
            let currentTweet: SDTweet = listOfTweets[indexPath.row]
            cell.drawTweetData(currentTweet)
        }
        cell.frame = CGRect(x: 0, y: 0, width: tblView.bounds.size.width, height: cell.frame.size.height);
        cell.layoutIfNeeded()
        return cell
    }

    func showTableView() {
        if (tblView.isHidden) {
            SDAnimationHelper.showViewWithFadeInAnimation(tblView)
        }
    }

    // MARK: - SDErrorPlaceholderViewDelegate protocol implementation

    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }

    // MARK: - Composing tweet

    @objc func didTapCreateTweetButton() {
        let error = self.socialHandler.showTweetComposerWithTweetText(hashtag ?? "", onViewController: self)
        if (error != .noError) {
            SDAlertViewHelper.showSimpleAlertViewOnViewController(self, title: nil, message: NSLocalizedString("social_error_message_no_twitter_account_configured", comment: ""), cancelButtonTitle: NSLocalizedString("common_ok", comment: ""), otherButtonTitle: nil, tag: nil, delegate: nil, handler: nil)
            SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameSocial, category: kGACategoryNavigate, action: kGAActionSocialPostTweet, label: nil)
        }
    }

    // MARK: - Progress HUD

    func showProgressHUD() {
        DispatchQueue.main.async(execute: {
            SVProgressHUD.show()
        })
    }

    func hideProgressHUD() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
        }
    }

}
