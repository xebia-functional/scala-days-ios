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

class SDSocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SDErrorPlaceholderViewDelegate, SDMenuControllerItem {

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

    private let analytics: Analytics
    
    init(analytics: Analytics) {
        self.analytics = analytics
        super.init(nibName: String(describing: SDSocialViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("social", comment: "social")
        
        tblView?.register(UINib(nibName: "SDSocialTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        tblView?.addSubview(refreshControl)
        if isIOS8OrLater() {
            tblView?.estimatedRowHeight = kEstimatedDynamicCellsRowHeightHigh
        }
        refreshControl.addTarget(self, action: #selector(SDSocialViewController.didActivateRefresh), for: UIControl.Event.valueChanged)

        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tblView.reloadData()
        initializePostTwitterButton()
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
        
        analytics.logScreenName(.social, class: SDSocialViewController.self)
    }
    
    private func initializePostTwitterButton() {
        guard TwitterSocialController.installed else {
            self.navigationItem.rightBarButtonItem = nil
            return
        }
        
        let barButtonCreateTweet = UIBarButtonItem(image: UIImage(named: "navigation_bar_post_tweet"), style: .plain, target: self, action: #selector(didTapPostTweet))
        barButtonCreateTweet.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -14)
        self.navigationItem.rightBarButtonItem = barButtonCreateTweet
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
            showProgressHUD()
        }
        
        if let query = query, !query.isEmpty {
            socialHandler.fetchTweetList(withHashtag: query, count: count) { [weak self] getTweetsResult in
                guard let `self` = self else { return }
                
                self.hideProgressHUD()
                
                switch (getTweetsResult) {
                case .success(let tweets):
                    self.listOfTweets = tweets
                    if self.listOfTweets.count > 0 {
                        self.tblView.reloadData()
                        self.tblView.setContentOffset(CGPoint.zero, animated: true)
                        self.errorPlaceholderView.hide()
                        self.showTableView()
                    } else {
                        self.errorPlaceholderView.show(NSLocalizedString("social_error_no_tweets_for_current_hashtag", comment: ""))
                    }
                    
                case .failure(_):
                    self.errorPlaceholderView.show(NSLocalizedString("social_error_no_valid_tweets", comment: ""))
                }
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

                analytics.logEvent(screenName: .speakers, category: .navigate, action: .goToUser)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableView.automaticDimension
        }
        let cell = self.tableView(tableView, cellForRowAt: indexPath) as! SDSocialTableViewCell
        return cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
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
            let cell = SDSocialTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: kReuseIdentifier)
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
    
    // MARK: - Composing tweet
    @objc func didTapPostTweet() {
        TwitterSocialController.present(in: self, text: hashtag)
        analytics.logEvent(screenName: .social, category: .navigate, action: .postTweet)
    }

    // MARK: - SDErrorPlaceholderViewDelegate protocol implementation

    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }

    // MARK: - Progress HUD

    func showProgressHUD() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }

    func hideProgressHUD() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
        }
    }
}
