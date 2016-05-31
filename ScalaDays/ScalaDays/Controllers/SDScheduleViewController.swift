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
import Alamofire

enum SDScheduleActionSheetButtons: Int {
    case Cancel = 0
    case All = 1
    case Favorites = 2
}

enum SDScheduleSelectedDataSource {
    case All
    case Favorites
}

enum SDScheduleEventType: Int {
    case Courses = 1
    case Keynotes = 2
    case Others = 3
}

class SDScheduleViewController: GAITrackedViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UIActionSheetDelegate,
    SDErrorPlaceholderViewDelegate,
    SDMenuControllerItem,
    SDScheduleListTableViewCellDelegate,
    UIGestureRecognizerDelegate,
    UITextViewDelegate,
    SlideMenuControllerDelegate {

    @IBOutlet weak var tblSchedule: UITableView!
    @IBOutlet weak var alphaBackgroundView: UIView!
    
    let kReuseIdentifier = "SDScheduleViewControllerCell"
    let kHeaderHeight: CGFloat = 40.0
    let kVotePopoverSize = CGSize(width: 300, height: 300)
    let kVotePopoverDefaultTopPosition = 100.0
    let kVotePopoverKeyboardOverlapThreshold = 20.0
    let kVotePlaceholderFontSize = CGFloat(14.0)
    let kBackgroundDarknessValue: CGFloat = 0.25
    let votingUrl = "http://www.47deg.com/scaladays/votes/add.php"
    let votingParamVote = "vote"
    let votingParamUID = "deviceUID"
    let votingParamTalkId = "talkId"
    let votingParamConferenceId = "conferenceId"
    let votingParamCommentsMessage = "message"
    let votingParamUrlEncodeHeader = "application/x-www-form-urlencoded"
    let kConnectionErrorCode400 = 400
    let kVotingButtonsBorderWidth = 0.5
    let kVotingLikeIconName = "popup_icon_vote_like"
    let kVotingNeutralIconName = "popup_icon_vote_neutral"
    let kVotingDontLikeIconName = "popup_icon_vote_unlike"
    let kVotingDisableIconSuffix = "_disabled"

    var selectedConference: Conference?
    var errorPlaceholderView : SDErrorPlaceholderView!
    @IBOutlet weak var votingPopoverContainer: UIView!
    @IBOutlet weak var btnVoteHappy: UIButton!
    @IBOutlet weak var btnVoteNeutral: UIButton!
    @IBOutlet weak var btnVoteSad: UIButton!
    @IBOutlet weak var txtViewVoteComments: UITextView!
    @IBOutlet weak var btnSendVote: UIButton!
    @IBOutlet weak var lblVoteTalkTitle: UILabel!
    @IBOutlet weak var constraintForVotingPopoverTopSpace: NSLayoutConstraint!
    @IBOutlet weak var btnCancelVote: UIButton!

    var dates: [String]?
    var events: [[Event]]?
    var favorites: [[Event]]?
    var selectedDataSource: SDScheduleSelectedDataSource = .All
    var eventsToShow: [[Event]]? {
        get {
            switch (selectedDataSource) {
            case .All:
                return events
            case .Favorites:
                if let _favoritesIndexes = DataManager.sharedInstance.favoritedEvents {
                    return _favoritesIndexes.count == 0 ? [[Event]]() : favorites
                }
                return [[Event]]()
            }
        }
    }
    var currentSelectedVote: VoteType? {
        didSet {
            let (color, enabled) = currentSelectedVote != nil ?
                (UIColor.enabledSendVoteButtonColor(), true) :
                (UIColor.disabledButtonColor(), false)
            btnSendVote.enabled = enabled
            btnSendVote.setTitleColor(color, forState: .Normal)
        }
    }
    var isDataLoaded : Bool = false
    var selectedEventToVote: (eventId: Int, conferenceId: Int)?
    let refreshControl = UIRefreshControl()

    override func viewWillAppear(animated: Bool) {
        self.title = NSLocalizedString("schedule", comment: "Schedule")
        if isDataLoaded {
            self.loadFavorites()
        } else {
            self.loadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarItem()
        tblSchedule?.registerNib(UINib(nibName: "SDScheduleListTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        tblSchedule?.separatorStyle = .None
        if isIOS8OrLater() {
            tblSchedule?.estimatedRowHeight = kEstimatedDynamicCellsRowHeightLow
        }
        
        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)
        
        refreshControl.addTarget(self, action: "didPullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tblSchedule.addSubview(refreshControl)
        
        self.screenName = kGAScreenNameSchedule
        
        self.btnSendVote.layer.borderWidth = CGFloat(kVotingButtonsBorderWidth)
        self.btnSendVote.layer.borderColor = UIColor.grayButtonBorder().CGColor
        self.btnCancelVote.layer.borderWidth = CGFloat(kVotingButtonsBorderWidth)
        self.btnCancelVote.layer.borderColor = UIColor.grayButtonBorder().CGColor
        self.txtViewVoteComments.attributedText = placeholderTextForComments()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil)

    }
    
    func loadNavigationBar() {
        let barButtonOptions = UIBarButtonItem(image: UIImage(named: "navigation_bar_icon_filter"), style: .Plain, target: self, action: "didTapOptionsButton")
        let barButtonClock = UIBarButtonItem(image: UIImage(named: "navigation_bar_icon_clock"), style: .Plain, target: self, action: "didTapOptionsButtonClock")
        
        if viewClock().result {
            self.navigationItem.rightBarButtonItems = [barButtonOptions,barButtonClock]
        } else {
            self.navigationItem.rightBarButtonItem = barButtonOptions
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func willBeHiddenFromMenu() {
        txtViewVoteComments.resignFirstResponder()
        votingPopoverContainer.endEditing(true)
    }

    // MARK: - Data loading / SDMenuControllerItem protocol implementation

    func loadData() {
        loadData(false)
    }
    
    func loadData(forceConnection: Bool) {
        if !forceConnection {
            SVProgressHUD.show()
        }
        
        DataManager.sharedInstance.loadDataJson(forceConnection) {
            (bool, error) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.refreshControl.endRefreshing()
                SVProgressHUD.dismiss()
            })
            
            if let _ = error {
                self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
            } else {
                self.selectedConference = DataManager.sharedInstance.currentlySelectedConference
                self.selectedDataSource = .All
                self.isDataLoaded = true
                
                self.dates = self.scheduledDates()
                self.events = self.listOfEventsSortedByDates()
                self.tblSchedule.reloadData()
                self.showTableView()
                self.view.backgroundColor = UIColor.appScheduleTimeBlueBackgroundColor()
                
                self.loadFavorites()
                
                if let _dates = self.dates {
                    if _dates.count == 0 {
                        self.errorPlaceholderView.show(NSLocalizedString("error_insufficient_content", comment: ""), isGeneralMessage: true)
                    } else {
                        self.errorPlaceholderView.hide()
                    }
                }
                
                self.tblSchedule.reloadData()
                self.loadNavigationBar()
            }
        }
    }
    
    func loadFavorites() {
        if let favs = self.favoritedEvents() {
            self.favorites = favs
            reloadTableDataWithFilter(selectedDataSource)
        }
    }
    
    func listOfCurrentConferenceFavoritesIDs() -> [Int]? {
        switch (selectedConference, DataManager.sharedInstance.favoritedEvents) {
        case let (.Some(conference), .Some(favoritedEvents)):
            if let currentConferenceFavorites = favoritedEvents[conference.info.id] {
                return currentConferenceFavorites
            }
        default: break
        }
        return nil
    }
    
    func didPullToRefresh() {
        loadData(true)
    }
    
    // MARK: UITableViewDataSource implementation

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let scheduledDates = dates {
            return scheduledDates.count
        }
        return 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = eventsToShow {
            return events[section].count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SDScheduleListTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier) as? SDScheduleListTableViewCell
        switch cell {
        case let (.Some(cell)):
            return configureCell(cell, indexPath: indexPath)
        default:
            let cell = SDScheduleListTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kReuseIdentifier)
            return configureCell(cell, indexPath: indexPath)
        }
    }

    func configureCell(cell: SDScheduleListTableViewCell, indexPath: NSIndexPath) -> SDScheduleListTableViewCell {
        if let events = eventsToShow,
            conferenceId = selectedConference?.info.id {
            let event = events[indexPath.section][indexPath.row]
            cell.drawEventData(event, conferenceId: conferenceId)
            if let currentConferenceFavorites = listOfCurrentConferenceFavoritesIDs() {
                if currentConferenceFavorites.contains(event.id) {
                    cell.imgFavoriteIcon.hidden = false
                }
            }
        }
        cell.delegate = self
        cell.frame = CGRectMake(0, 0, screenBounds.width, cell.frame.size.height);
        cell.layoutIfNeeded()
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let dates = dates {
            return dates[section]
        }
        return nil
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let scheduleDetailViewController = SDScheduleDetailViewController(nibName: "SDScheduleDetailViewController", bundle: nil)
        if let events = eventsToShow {
            let event: Event = events[indexPath.section][indexPath.row]
            if (event.type == SDScheduleEventType.Keynotes.rawValue || event.type == SDScheduleEventType.Courses.rawValue) {
                self.title = ""
                scheduleDetailViewController.event = event
                self.navigationController?.pushViewController(scheduleDetailViewController, animated: true)
                SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameSchedule, category: kGACategoryNavigate, action: kGAActionScheduleGoToDetail, label: event.title)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableViewAutomaticDimension
        }
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! SDScheduleListTableViewCell
        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if selectedDataSource == .Favorites {
            if let favs = self.favorites {
                if favs[section].count > 0 {
                    return kHeaderHeight
                }
            }
            return 0
        }
        return kHeaderHeight        
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // It seems that there are problems trying to use NIB files to instantiate table view headers in iOS7
        // (the run-time asks for a call to super.layoutSubviews() even if it's specifically overriden in the header subclass).
        // We need to do it by hand in this case...
        if let _dates = dates {
            let headerView = SDTableHeaderView(frame: CGRectMake(0, 0, tblSchedule.frame.size.width, kHeaderHeight))
            headerView.lblDate.text = _dates[section]
            headerView.lblDate.sizeToFit()
            return headerView
        }
        return nil
    }

// MARK: - Data handling

    func scheduledDates() -> [String]? {
        if let schedule = selectedConference?.schedule {
            let result = schedule.reduce([String](), combine: {
                var temp = $0

                if $0.count == 0 {
                    return [$1.date]
                } else if $1.date != $0.last {
                    temp.append($1.date)
                }
                return temp
            })
            return result
        }
        return nil
    }

    func listOfEventsSortedByDates() -> [[Event]]? {
        var temp = [[Event]]()

        switch (dates, selectedConference?.schedule) {
        case let (.Some(_dates), .Some(_schedule)):
            for date in _dates {
                let filteredEvents = _schedule.filter {
                    $0.date == date
                }
                temp.append(filteredEvents)
            }
            return temp
        default:
            break;
        }

        return nil
    }

// MARK: - Button handling

    func didTapOptionsButton() {
        if isDataLoaded && errorPlaceholderView.hidden {
            launchFilterSheet()
        }
    }

// MARK: - Favorites handling

    func favoritedEvents() -> [[Event]]? {
        if let _conference = selectedConference {
            if let _events = events {
                return _events.map({
                    $0.filter({
                        if let favoritesDict = DataManager.sharedInstance.favoritedEvents {
                            if let favoritedEvents = favoritesDict[_conference.info.id] {
                                let event = $0
                                return favoritedEvents.reduce(false, combine: {
                                    return $0 ? $0 : event.id == $1
                                })
                            }
                        }
                        return false
                    })
                })
            }
        }
        return nil
    }

    func launchFilterSheet() {
        let title = NSLocalizedString("schedule_action_sheet_filter_title", comment: "")
        let actionTitleAll = NSLocalizedString("schedule_action_sheet_filter_message_all", comment: "")
        let actionTitleFavorites = NSLocalizedString("schedule_action_sheet_filter_message_favorites", comment: "")
        let actionTitleCancel = NSLocalizedString("common_cancel", comment: "")

        if (isIOS8OrLater()) {
            let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
            actionSheet.addAction(UIAlertAction(title: actionTitleAll, style: .Default, handler: {
                (alertAction) -> Void in
                self.reloadTableDataWithFilter(.All)
            }))
            actionSheet.addAction(UIAlertAction(title: actionTitleFavorites, style: .Default, handler: {
                (alertAction) -> Void in
                self.reloadTableDataWithFilter(.Favorites)
            }))
            actionSheet.addAction(UIAlertAction(title: actionTitleCancel, style: .Cancel, handler: {
                (alertAction) -> Void in

            }))
            self.presentViewController(actionSheet, animated: true, completion: nil)
        } else {
            let actionSheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: actionTitleCancel, destructiveButtonTitle: nil, otherButtonTitles: actionTitleAll, actionTitleFavorites)
            actionSheet.showInView(self.view)
        }
    }

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch (buttonIndex) {
        case actionSheet.cancelButtonIndex:
            return
        case SDScheduleActionSheetButtons.All.rawValue:
            self.reloadTableDataWithFilter(.All)
        case SDScheduleActionSheetButtons.Favorites.rawValue:
            self.reloadTableDataWithFilter(.Favorites)
        default:
            break
        }
    }

    func reloadTableDataWithFilter(filter: SDScheduleSelectedDataSource) {
        if filter == .Favorites {
            var favoritesCount = 0
            
            if let currentConferenceFavorites = listOfCurrentConferenceFavoritesIDs() {
                favoritesCount = currentConferenceFavorites.count
            }
            
            if favoritesCount == 0 {
                errorPlaceholderView.show(NSLocalizedString("error_no_favorites", comment: ""), isGeneralMessage: true, buttonTitle: NSLocalizedString("common_back", comment: "").uppercaseString)
            } else {
                selectedDataSource = filter
                tblSchedule.reloadData()
                SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameSchedule, category: kGACategoryFilter, action: kGAActionScheduleFilterFavorites, label: nil)
            }
        } else {
            selectedDataSource = filter
            tblSchedule.reloadData()
            SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameSchedule, category: kGACategoryFilter, action: kGAActionScheduleFilterAll, label: nil)
        }
    }

    
    // MARK: - SDErrorPlaceholderViewDelegate protocol implementation
    
    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }
    
    // MARK: - Animations
    
    func showTableView() {
        if(tblSchedule.hidden) {
            SDAnimationHelper.showViewWithFadeInAnimation(tblSchedule)
        }
    }
    
    //MARK: - Clock
    
    func viewClock() -> (result :Bool, indexRow : Int, indexSection: Int){
        var result = false
        _ = NSDate()
        if let events = eventsToShow {
            for (indexSection, eventSection) in events.enumerate(){
                for (indexRow, event) in eventSection.enumerate(){
                    if SDDateHandler.sharedInstance.isCurrentDateActive(event.startTime, endTime: event.endTime){
                        result = true
                        return (result, indexRow, indexSection)
                   }
                }
            }
        }
        return (result, 0, 0)
    }
    
    func didTapOptionsButtonClock() {
        let clock = viewClock()
        if clock.result {
            let indexPath = NSIndexPath(forRow: clock.indexRow, inSection: clock.indexSection)
            tblSchedule.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    // MARK: - Voting
    
    @IBAction func didTapOnBtnVoteFace(sender: UIButton) {
        switch sender {
        case _ where sender === btnVoteHappy: didSelectVoteValue(.Like)
        case _ where sender === btnVoteNeutral: didSelectVoteValue(.Neutral)
        case _ where sender === btnVoteSad: didSelectVoteValue(.Unlike)
        default: break
        }
    }
    
    @IBAction func didTapOnBtnVoteCancel(sender: UIButton) {
        if let comments = currentVotingComments() {
            if let eventToVote = selectedEventToVote,
                previousVote = StoringHelper.sharedInstance.storedVoteForConferenceId(eventToVote.conferenceId, talkId: eventToVote.eventId) {
                    if comments != previousVote.comments {
                        launchVotingCancelAlert()
                    } else {
                        hideVotingPopover()
                    }
            } else {
                launchVotingCancelAlert()
            }
        } else {
            hideVotingPopover()
        }
    }
    
    @IBAction func didTapOnBtnSendVote(sender: UIButton) {
        if let vote = currentSelectedVote {
            sendVote(vote, comments: currentVotingComments())
        }
    }
    
    func hideVotingPopover() {
        SDAnimationHelper.hideViewWithFadeOutAnimation(votingPopoverContainer)
        SDAnimationHelper.hideViewWithFadeOutAnimation(alphaBackgroundView)
    }
    
    func showVotingPopover() {
        disableVoteIcons()
        SDAnimationHelper.showViewWithFadeInAnimation(alphaBackgroundView, maxAlphaValue: kBackgroundDarknessValue)
        SDAnimationHelper.showViewWithFadeInAnimation(votingPopoverContainer)
        
        if let eventToVote = selectedEventToVote,
            previousVote = StoringHelper.sharedInstance.storedVoteForConferenceId(eventToVote.conferenceId, talkId: eventToVote.eventId) {
                txtViewVoteComments.attributedText = previousVote.comments != nil ?
                    attributedStringForComment(previousVote.comments ?? "") :
                    placeholderTextForComments()
                
                if let voteType = VoteType(rawValue: previousVote.voteValue) {
                    currentSelectedVote = voteType
                    enableVotingIconForVoteType(voteType)
                }
        } else {
            txtViewVoteComments.attributedText = placeholderTextForComments()
        }
        
        SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameSchedule,
            category: kGACategoryVote,
            action: kGAActionShowVotingDialog,
            label: nil)
    }
    
    func enableVotingIconForVoteType(voteType: VoteType) {
        switch voteType {
        case .Like: setVotingIconToButton(btnVoteHappy, iconName: kVotingLikeIconName)
        case .Neutral: setVotingIconToButton(btnVoteNeutral, iconName: kVotingNeutralIconName)
        case .Unlike: setVotingIconToButton(btnVoteSad, iconName: kVotingDontLikeIconName)
        }
    }
    
    func didSelectVoteButtonWithEvent(event: Event, conferenceId: Int) {
        selectedEventToVote = (event.id, conferenceId)
        currentSelectedVote = nil
        showVotingPopover()
        lblVoteTalkTitle.text = "\"\(event.title)\""
    }
    
    func setVotingIconToButton(btn: UIButton, iconName: String) {
        btn.setImage(UIImage(named: iconName), forState: .Normal)
    }
    
    func disableVoteIcons() {
        setVotingIconToButton(btnVoteHappy, iconName: kVotingLikeIconName + kVotingDisableIconSuffix)
        setVotingIconToButton(btnVoteNeutral, iconName: kVotingNeutralIconName + kVotingDisableIconSuffix)
        setVotingIconToButton(btnVoteSad, iconName: kVotingDontLikeIconName + kVotingDisableIconSuffix)
    }
    
    func didSelectVoteValue(voteType: VoteType) {
        currentSelectedVote = voteType
        disableVoteIcons()
        enableVotingIconForVoteType(voteType)
    }
    
    func launchVotingCancelAlert() {
        SDAlertViewHelper.showSimpleAlertViewOnViewController(self,
            title: NSLocalizedString("schedule_vote_comments_cancel_warning_title", comment: ""),
            message: NSLocalizedString("schedule_vote_comments_cancel_warning_message", comment: ""),
            cancelButtonTitle: NSLocalizedString("common_cancel", comment: ""), otherButtonTitle: NSLocalizedString("schedule_vote_comments_cancel_warning_btn_exit", comment: ""),
            tag: nil,
            delegate: nil) { (alert) -> Void in
                if alert.title == NSLocalizedString("schedule_vote_comments_cancel_warning_btn_exit", comment: "") {
                    self.hideVotingPopover()
                }
        }
    }
    
    func sendVote(voteType: VoteType, comments: String?) {
        SVProgressHUD.show()
        func votingRequestParametersForVote(vote: VoteType, event: Int, conference: Int, uid: String, comments: String?) -> [String: AnyObject] {
            if let actualComments = comments {
                return [votingParamVote: voteType.rawValue,
                        votingParamUID: uid,
                        votingParamTalkId: event,
                        votingParamConferenceId: conference,
                        votingParamCommentsMessage: actualComments]
            }
            return [votingParamVote: voteType.rawValue,
                votingParamUID: uid,
                votingParamTalkId: event,
                votingParamConferenceId: conference]
        }
        
        if let (event, conference) = selectedEventToVote,
            uid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
            Alamofire.request(.POST,
                votingUrl,
                parameters: votingRequestParametersForVote(voteType,
                    event: event,
                    conference: conference,
                    uid: uid,
                    comments: comments),
                encoding: .URL,
                headers: ["Content-Type": votingParamUrlEncodeHeader])
                .response { response in
                    let code = response.1?.statusCode ?? 0
                    if code >= self.kConnectionErrorCode400 || code == 0 {
                        SDAlertViewHelper.showSimpleAlertViewOnViewController(self,
                            title: NSLocalizedString("schedule_error_vote_title", comment: ""),
                            message: NSLocalizedString("schedule_error_vote_message", comment: ""),
                            cancelButtonTitle: NSLocalizedString("OK", comment: ""),
                            otherButtonTitle: nil,
                            tag: nil,
                            delegate: nil,
                            handler: nil)
                    } else {
                        // Storing/updating vote
                        let key = "\(conference)\(event)"
                        let vote = Vote(_voteValue: voteType.rawValue,
                            _talkId: event,
                            _conferenceId: conference,
                            _comments: comments)
                        if let currentlyStoredVotes = StoringHelper.sharedInstance.loadVotesData() {
                            var tmp = currentlyStoredVotes
                            tmp[key] = vote
                            StoringHelper.sharedInstance.storeVotesData(tmp)
                        } else {
                            StoringHelper.sharedInstance.storeVotesData([key: vote])
                        }
                    }                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tblSchedule.reloadData()
                        self.hideVotingPopover()
                        SVProgressHUD.dismiss()
                    })
            }
            selectedEventToVote = nil
            SDGoogleAnalyticsHandler.sendGoogleAnalyticsTrackingWithScreenName(kGAScreenNameSchedule,
                category: kGACategoryVote,
                action: kGAActionSendVote,
                label: nil)
        }
    }
    
    // MARK: - Keyboard handling
    
    func keyboardWillShow(notification: NSNotification) {
        if let notificationInfo = notification.userInfo,
            keyboardFrame = (notificationInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(),
            animationDuration = (notificationInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval) {
            setVerticalPositionForVotingPopoverWithKeyboardHeight(keyboardFrame.size.height,
                kbAnimationDuration: animationDuration)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let notificationInfo = notification.userInfo,
            animationDuration = (notificationInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval) {
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    self.constraintForVotingPopoverTopSpace.constant = CGFloat(self.kVotePopoverDefaultTopPosition)
                })
        }
        
    }
    
    func setVerticalPositionForVotingPopoverWithKeyboardHeight(kbHeight: CGFloat, kbAnimationDuration: NSTimeInterval) {
        if kbHeight + votingPopoverContainer.bounds.size.height + CGFloat(kVotePopoverDefaultTopPosition) >
            self.view.bounds.height + CGFloat(kVotePopoverKeyboardOverlapThreshold) {
                UIView.animateWithDuration(kbAnimationDuration, animations: { () -> Void in
                    self.constraintForVotingPopoverTopSpace.constant = 0
                })
        }
    }
    
    @IBAction func didTapOutsideOfKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.locationInView(self.view)
        if txtViewVoteComments.isFirstResponder() {
            self.view.endEditing(true)
        } else if !votingPopoverContainer.hidden && !CGRectContainsPoint(votingPopoverContainer.frame, location) {
            hideVotingPopover()
        }
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.attributedText.string == placeholderTextForComments().string {
            textView.attributedText = nil
            textView.text = ""
            textView.font = UIFont.fontHelveticaNeueLight(kVotePlaceholderFontSize)
            textView.textColor = UIColor.blackForCommentsNormalText()
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.attributedText.string == "" {
            textView.attributedText = placeholderTextForComments()
        }
        textView.resignFirstResponder()
    }
    
    func placeholderTextForComments() -> NSAttributedString {
        let placeholderString = NSLocalizedString("schedule_vote_comments_placeholder", comment: "")
        return NSAttributedString(string: placeholderString, attributes: [NSFontAttributeName: UIFont.fontHelveticaNeueItalic(kVotePlaceholderFontSize), NSForegroundColorAttributeName: UIColor.grayCommentsPlaceholder()])
    }
    
    func attributedStringForComment(comment: String) -> NSAttributedString {
        return NSAttributedString(string: comment, attributes: [NSFontAttributeName: UIFont.fontHelveticaNeueLight(kVotePlaceholderFontSize),
            NSForegroundColorAttributeName: UIColor.blackForCommentsNormalText()])
    }
    
    func currentVotingComments() -> String? {
        if txtViewVoteComments.attributedText.string != placeholderTextForComments().string {
            return txtViewVoteComments.attributedText.string
        }
        return nil
    }
    
}

