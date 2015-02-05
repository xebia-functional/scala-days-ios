//
//  SDSocialViewController.swift
//  ScalaDays
//
//  Created by Ana on 29/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class SDSocialViewController: UIViewController {
    
    @IBOutlet weak var tblView : UITableView!
    @IBOutlet weak var viewError : UIView!
    @IBOutlet weak var lblError : UILabel!
    
    let kReuseIdentifier = "socialViewControllerCell"
    let kTweetCount = 100
    var listOfTweets : Array<SDTweet> = []
    let socialHandler = SDSocialHandler()
    lazy var refreshControl = UIRefreshControl()
    var isFirstLoad : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("social",comment: "social")
        
        let barButtonCreateTweet = UIBarButtonItem(image: UIImage(named: "navigation_bar_icon_create"), style: .Plain, target: self, action: "didTapCreateTweetButton")
        self.navigationItem.rightBarButtonItem = barButtonCreateTweet
        
        tblView?.registerNib(UINib(nibName: "SDSocialTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        if(isIOS8OrLater()) {
            tblView?.estimatedRowHeight = 68.0
        }
        tblView?.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "didActivateRefresh", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        if isFirstLoad {
            reloadTweets()
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
        
        socialHandler.requestTweetListWithHashtag("#MaterialFest", count: count) { (tweets, error) -> Void in
            self.hideProgressHUD()
            
            switch(tweets, error) {
            case let (.Some(tweets), nil) :
                self.listOfTweets = tweets as Array<SDTweet>
                dispatch_async(dispatch_get_main_queue()) {
                    self.tblView.reloadData()
                    self.hideErrorFeedback()
                    self.showTableView()
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
    }
    
    // MARK: - Tableview's refresh control
    
    func didActivateRefresh() {
        refreshTweets()
    }
    
    // MARK: - UITableViewDelegate protocol implementation
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableViewAutomaticDimension
        }
        
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as SDSocialTableViewCell
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }
    
    //MARK: UITableViewDataSource protocol implementation

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfTweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier) as? SDSocialTableViewCell
        switch cell {
        case let(.Some(cell)):
            configureCell(cell, forRowAtIndexPath: indexPath)
            cell.frame = CGRectMake(0, 0, tableView.bounds.size.width, cell.frame.size.height);
            cell.layoutIfNeeded()
            cell.layoutSubviews()
            return cell
        default:
            return SDSocialTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kReuseIdentifier)
        }
    }
    
    func configureCell(cell: UITableViewCell, forRowAtIndexPath: NSIndexPath) {
        if(listOfTweets.count > forRowAtIndexPath.row) {
            let currentTweet : SDTweet = listOfTweets[forRowAtIndexPath.row]
            let socialCell = cell as SDSocialTableViewCell
            socialCell.lblFullName?.text = currentTweet.fullName
            socialCell.lblUsername?.text = "@\(currentTweet.username)"
            socialCell.lblContent?.text = currentTweet.tweetText
            if let date = socialHandler.parseTwitterDate(currentTweet.dateString) {
                socialCell.lblDate?.text = date.timeAgoSimple()
            }
            let imageUrl = NSURL(string: currentTweet.profileImage)
            if let profileImageUrl = imageUrl {
                socialCell.imgView?.sd_setImageWithURL(profileImageUrl)
            }
            socialCell.layoutSubviews()
        }
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
