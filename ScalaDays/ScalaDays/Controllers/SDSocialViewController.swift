//
//  SDSocialViewController.swift
//  ScalaDays
//
//  Created by Ana on 29/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class SDSocialViewController: UIViewController {
    
    @IBOutlet var tblView : UITableView?
    
    let kReuseIdentifier = "socialViewControllerCell"
    let kTweetCount = 100
    var listOfTweets : Array<SDTweet> = []
    let socialHandler = SDSocialHandler()
    lazy var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("social",comment: "social")
        tblView?.registerNib(UINib(nibName: "SDSocialTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        if(isIOS8OrLater()) {
            tblView?.estimatedRowHeight = 68.0
        }
        tblView?.hidden = true
        tblView?.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "didActivateRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        SVProgressHUD.show()
        reloadTweets()
    }
    
    // MARK: - Network access implementation
    
    func reloadTweets() {
        loadTweetData(kTweetCount)
    }
    
    func loadTweetData(count: Int) {
        socialHandler.requestTweetListWithHashtag("#MaterialFest", count: count) { (tweets, error) -> Void in
            switch(tweets, error) {
            case let (.Some(tweets), nil) :
                // Success! We got tweets!
                self.listOfTweets = tweets as Array<SDTweet>
                dispatch_async(dispatch_get_main_queue()) {
                    SVProgressHUD.dismiss()
                    self.refreshControl.endRefreshing()
                    
                    if let tableView = self.tblView {
                        tableView.reloadData()
                        
                        if tableView.hidden {
                            tableView.alpha = 0
                            tableView.hidden = false
                            UIView.animateWithDuration(animationShowHideTimeInterval, animations: {() -> Void in
                                tableView.alpha = 1
                                return
                            })
                        }
                    }
                }
            default :
                // Darn! We got an error!!
                if let error = error {
                    println("We got error!! :( \n \(error)")
                }
            }
        }
    }
    
    // MARK: - Tableview's refresh control
    
    func didActivateRefresh() {
        reloadTweets()
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
    
    
}
