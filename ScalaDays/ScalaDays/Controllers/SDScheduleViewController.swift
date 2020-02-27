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
    case cancel = 0
    case all = 1
    case favorites = 2
}

enum SDScheduleSelectedDataSource {
    case all
    case favorites
}

enum SDScheduleEventType: Int {
    case courses = 1
    case keynotes = 2
    case others = 3
}

class SDScheduleViewController: UIViewController,
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
    let votingUrl = "https://scaladays-backend.herokuapp.com/votes/add.php"
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
    let kMaxNumberOfCharactersForVotingComment = 500

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
    var selectedDataSource: SDScheduleSelectedDataSource = .all
    var eventsToShow: [[Event]]? {
        get {
            switch (selectedDataSource) {
            case .all:
                return events
            case .favorites:
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
            btnSendVote.isEnabled = enabled
            btnSendVote.setTitleColor(color, for: UIControl.State())
        }
    }
    var isDataLoaded : Bool = false
    var selectedEventToVote: (eventId: Int, conferenceId: Int)?
    let refreshControl = UIRefreshControl()

    private let analytics: Analytics
    
    init(analytics: Analytics) {
        self.analytics = analytics
        super.init(nibName: String(describing: SDScheduleViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = NSLocalizedString("schedule", comment: "Schedule")
        if isDataLoaded {
            self.loadFavorites()
        } else {
            self.loadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarItem()
        tblSchedule?.register(UINib(nibName: "SDScheduleListTableViewCell", bundle: nil), forCellReuseIdentifier: kReuseIdentifier)
        tblSchedule?.separatorStyle = .none
        if isIOS8OrLater() {
            tblSchedule?.estimatedRowHeight = kEstimatedDynamicCellsRowHeightLow
        }
        
        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)
        
        refreshControl.addTarget(self, action: #selector(SDScheduleViewController.didPullToRefresh), for: UIControl.Event.valueChanged)
        tblSchedule.addSubview(refreshControl)
        
        analytics.logScreenName(.schedule, class: SDScheduleViewController.self)
        
        self.btnSendVote.layer.borderWidth = CGFloat(kVotingButtonsBorderWidth)
        self.btnSendVote.layer.borderColor = UIColor.grayButtonBorder().cgColor
        self.btnCancelVote.layer.borderWidth = CGFloat(kVotingButtonsBorderWidth)
        self.btnCancelVote.layer.borderColor = UIColor.grayButtonBorder().cgColor
        self.txtViewVoteComments.attributedText = placeholderTextForComments()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(SDScheduleViewController.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(SDScheduleViewController.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)

    }
    
    func loadNavigationBar() {
        let barButtonOptions = UIBarButtonItem(image: UIImage(named: "navigation_bar_icon_filter"), style: .plain, target: self, action: #selector(SDScheduleViewController.didTapOptionsButton))
        let barButtonClock = UIBarButtonItem(image: UIImage(named: "navigation_bar_icon_clock"), style: .plain, target: self, action: #selector(SDScheduleViewController.didTapOptionsButtonClock))
        
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
    
    func loadData(_ forceConnection: Bool) {
        if !forceConnection {
            SVProgressHUD.show()
        }
        
        DataManager.sharedInstance.loadDataJson(forceConnection) {
            (bool, error) -> () in
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.refreshControl.endRefreshing()
                SVProgressHUD.dismiss()
            })
            
            if let _ = error {
                self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
            } else {
                self.selectedConference = DataManager.sharedInstance.currentlySelectedConference
                self.selectedDataSource = .all
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
        case let (.some(conference), .some(favoritedEvents)):
            if let currentConferenceFavorites = favoritedEvents[conference.info.id] {
                return currentConferenceFavorites
            }
        default: break
        }
        return nil
    }
    
    @objc func didPullToRefresh() {
        loadData(true)
    }
    
    // MARK: UITableViewDataSource implementation

    func numberOfSections(in tableView: UITableView) -> Int {
        if let scheduledDates = dates {
            return scheduledDates.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = eventsToShow {
            return events[section].count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SDScheduleListTableViewCell? = tableView.dequeueReusableCell(withIdentifier: kReuseIdentifier) as? SDScheduleListTableViewCell
        switch cell {
        case let (.some(cell)):
            return configureCell(cell, indexPath: indexPath)
        default:
            let cell = SDScheduleListTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: kReuseIdentifier)
            return configureCell(cell, indexPath: indexPath)
        }
    }

    func configureCell(_ cell: SDScheduleListTableViewCell, indexPath: IndexPath) -> SDScheduleListTableViewCell {
        if let events = eventsToShow,
            let conferenceId = selectedConference?.info.id {
            let event = events[indexPath.section][indexPath.row]
            cell.drawEventData(event, conferenceId: conferenceId)
            if let currentConferenceFavorites = listOfCurrentConferenceFavoritesIDs() {
                if currentConferenceFavorites.contains(event.id) {
                    cell.imgFavoriteIcon.isHidden = false
                }
            }
        }
        cell.delegate = self
        cell.frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: cell.frame.size.height);
        cell.layoutIfNeeded()
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let dates = dates {
            return dates[section]
        }
        return nil
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scheduleDetailViewController = SDScheduleDetailViewController(analytics: analytics)
        if let events = eventsToShow {
            let event: Event = events[indexPath.section][indexPath.row]
            if (event.type == SDScheduleEventType.keynotes.rawValue || event.type == SDScheduleEventType.courses.rawValue) {
                self.title = ""
                scheduleDetailViewController.event = event
                self.navigationController?.pushViewController(scheduleDetailViewController, animated: true)
                analytics.logEvent(screenName: .schedule, category: .navigate, action: .goToDetail, label: event.title)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (isIOS8OrLater()) {
            return UITableView.automaticDimension
        }
        let cell = self.tableView(tableView, cellForRowAt: indexPath) as! SDScheduleListTableViewCell
        return cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if selectedDataSource == .favorites {
            if let favs = self.favorites {
                if favs[section].count > 0 {
                    return kHeaderHeight
                }
            }
            return 0
        }
        return kHeaderHeight        
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // It seems that there are problems trying to use NIB files to instantiate table view headers in iOS7
        // (the run-time asks for a call to super.layoutSubviews() even if it's specifically overriden in the header subclass).
        // We need to do it by hand in this case...
        if let _dates = dates {
            let headerView = SDTableHeaderView(frame: CGRect(x: 0, y: 0, width: tblSchedule.frame.size.width, height: kHeaderHeight))
            headerView.lblDate.text = _dates[section]
            headerView.lblDate.sizeToFit()
            return headerView
        }
        return nil
    }
    
    // MARK: - Data handling
    
    func scheduledDates() -> [String]? {
        if let schedule = selectedConference?.schedule {
            let result = schedule.reduce([String](), {
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
        case let (.some(_dates), .some(_schedule)):
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
    
    @objc func didTapOptionsButton() {
        if isDataLoaded && errorPlaceholderView.isHidden {
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
                                return favoritedEvents.reduce(false, {
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
            let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: actionTitleAll, style: .default, handler: {
                (alertAction) -> Void in
                self.reloadTableDataWithFilter(.all)
            }))
            actionSheet.addAction(UIAlertAction(title: actionTitleFavorites, style: .default, handler: {
                (alertAction) -> Void in
                self.reloadTableDataWithFilter(.favorites)
            }))
            actionSheet.addAction(UIAlertAction(title: actionTitleCancel, style: .cancel, handler: {
                (alertAction) -> Void in

            }))
            self.present(actionSheet, animated: true, completion: nil)
        } else {
            let actionSheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: actionTitleCancel, destructiveButtonTitle: nil, otherButtonTitles: actionTitleAll, actionTitleFavorites)
            actionSheet.show(in: self.view)
        }
    }

    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        switch (buttonIndex) {
        case actionSheet.cancelButtonIndex:
            return
        case SDScheduleActionSheetButtons.all.rawValue:
            self.reloadTableDataWithFilter(.all)
        case SDScheduleActionSheetButtons.favorites.rawValue:
            self.reloadTableDataWithFilter(.favorites)
        default:
            break
        }
    }

    func reloadTableDataWithFilter(_ filter: SDScheduleSelectedDataSource) {
        if filter == .favorites {
            var favoritesCount = 0
            
            if let currentConferenceFavorites = listOfCurrentConferenceFavoritesIDs() {
                favoritesCount = currentConferenceFavorites.count
            }
            
            if favoritesCount == 0 {
                errorPlaceholderView.show(NSLocalizedString("error_no_favorites", comment: ""), isGeneralMessage: true, buttonTitle: NSLocalizedString("common_back", comment: "").uppercased())
            } else {
                selectedDataSource = filter
                tblSchedule.reloadData()
                analytics.logEvent(screenName: .schedule, category: .filter, action: .filterFavorites)
            }
        } else {
            selectedDataSource = filter
            tblSchedule.reloadData()
            analytics.logEvent(screenName: .schedule, category: .filter, action: .filterAll)
        }
    }

    
    // MARK: - SDErrorPlaceholderViewDelegate protocol implementation
    
    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }
    
    // MARK: - Animations
    
    func showTableView() {
        if(tblSchedule.isHidden) {
            SDAnimationHelper.showViewWithFadeInAnimation(tblSchedule)
        }
    }
    
    //MARK: - Clock
    
    func viewClock() -> (result :Bool, indexRow : Int, indexSection: Int){
        var result = false
        _ = Date()
        if let events = eventsToShow {
            for (indexSection, eventSection) in events.enumerated(){
                for (indexRow, event) in eventSection.enumerated(){
                    if SDDateHandler.sharedInstance.isCurrentDateActive(event.startTime, endTime: event.endTime){
                        result = true
                        return (result, indexRow, indexSection)
                   }
                }
            }
        }
        return (result, 0, 0)
    }
    
    @objc func didTapOptionsButtonClock() {
        let clock = viewClock()
        if clock.result {
            let indexPath = IndexPath(row: clock.indexRow, section: clock.indexSection)
            tblSchedule.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
        }
    }
    
    // MARK: - Voting
    
    @IBAction func didTapOnBtnVoteFace(_ sender: UIButton) {
        switch sender {
        case _ where sender === btnVoteHappy: didSelectVoteValue(.like)
        case _ where sender === btnVoteNeutral: didSelectVoteValue(.neutral)
        case _ where sender === btnVoteSad: didSelectVoteValue(.unlike)
        default: break
        }
    }
    
    @IBAction func didTapOnBtnVoteCancel(_ sender: UIButton) {
        if let comments = currentVotingComments() {
            if let eventToVote = selectedEventToVote,
                let previousVote = StoringHelper.sharedInstance.storedVoteForConferenceId(eventToVote.conferenceId, talkId: eventToVote.eventId) {
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
    
    @IBAction func didTapOnBtnSendVote(_ sender: UIButton) {
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
            let previousVote = StoringHelper.sharedInstance.storedVoteForConferenceId(eventToVote.conferenceId, talkId: eventToVote.eventId) {
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
        
        analytics.logEvent(screenName: .schedule, category: .vote, action: .showVotingDialog)
    }
    
    func enableVotingIconForVoteType(_ voteType: VoteType) {
        switch voteType {
        case .like: setVotingIconToButton(btnVoteHappy, iconName: kVotingLikeIconName)
        case .neutral: setVotingIconToButton(btnVoteNeutral, iconName: kVotingNeutralIconName)
        case .unlike: setVotingIconToButton(btnVoteSad, iconName: kVotingDontLikeIconName)
        }
    }
    
    func didSelectVoteButtonWithEvent(_ event: Event, conferenceId: Int) {
        selectedEventToVote = (event.id, conferenceId)
        currentSelectedVote = nil
        showVotingPopover()
        lblVoteTalkTitle.text = "\"\(event.title)\""
    }
    
    func setVotingIconToButton(_ btn: UIButton, iconName: String) {
        btn.setImage(UIImage(named: iconName), for: UIControl.State())
    }
    
    func disableVoteIcons() {
        setVotingIconToButton(btnVoteHappy, iconName: kVotingLikeIconName + kVotingDisableIconSuffix)
        setVotingIconToButton(btnVoteNeutral, iconName: kVotingNeutralIconName + kVotingDisableIconSuffix)
        setVotingIconToButton(btnVoteSad, iconName: kVotingDontLikeIconName + kVotingDisableIconSuffix)
    }
    
    func didSelectVoteValue(_ voteType: VoteType) {
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
                if alert?.title == NSLocalizedString("schedule_vote_comments_cancel_warning_btn_exit", comment: "") {
                    self.hideVotingPopover()
                }
        }
    }
    
    func sendVote(_ voteType: VoteType, comments: String?) {
        SVProgressHUD.show()
        func votingRequestParametersForVote(_ vote: VoteType, event: Int, conference: Int, uid: String, comments: String?) -> Parameters {
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
            let uid = UIDevice.current.identifierForVendor?.uuidString {
            Alamofire.request(votingUrl, method:HTTPMethod.post,
                parameters: votingRequestParametersForVote(voteType,
                    event: event,
                    conference: conference,
                    uid: uid,
                    comments: comments),
                encoding: URLEncoding.default,
                headers: ["Content-Type": votingParamUrlEncodeHeader]).response { response in
                    let code = response.response?.statusCode ?? 0
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
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.tblSchedule.reloadData()
                        self.hideVotingPopover()
                        SVProgressHUD.dismiss()
                    })
            }
            selectedEventToVote = nil
            
            analytics.logEvent(screenName: .schedule, category: .vote, action: .sendVote)
        }
    }
    
    // MARK: - Keyboard handling
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let notificationInfo = notification.userInfo,
            let keyboardFrame = (notificationInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = (notificationInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) {
            setVerticalPositionForVotingPopoverWithKeyboardHeight(keyboardFrame.size.height,
                kbAnimationDuration: animationDuration)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let notificationInfo = notification.userInfo,
            let animationDuration = (notificationInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) {
                UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                    self.constraintForVotingPopoverTopSpace.constant = CGFloat(self.kVotePopoverDefaultTopPosition)
                })
        }
        
    }
    
    func setVerticalPositionForVotingPopoverWithKeyboardHeight(_ kbHeight: CGFloat, kbAnimationDuration: TimeInterval) {
        if kbHeight + votingPopoverContainer.bounds.size.height + CGFloat(kVotePopoverDefaultTopPosition) >
            self.view.bounds.height + CGFloat(kVotePopoverKeyboardOverlapThreshold) {
                UIView.animate(withDuration: kbAnimationDuration, animations: { () -> Void in
                    self.constraintForVotingPopoverTopSpace.constant = 0
                })
        }
    }
    
    @IBAction func didTapOutsideOfKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: self.view)
        if txtViewVoteComments.isFirstResponder {
            self.view.endEditing(true)
        } else if !votingPopoverContainer.isHidden && !votingPopoverContainer.frame.contains(location) {
            hideVotingPopover()
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.attributedText.string == placeholderTextForComments().string {
            textView.attributedText = nil
            textView.text = ""
            textView.font = UIFont.fontHelveticaNeueLight(kVotePlaceholderFontSize)
            textView.textColor = UIColor.blackForCommentsNormalText()
        }
        textView.becomeFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < kMaxNumberOfCharactersForVotingComment;
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.attributedText.string == "" {
            textView.attributedText = placeholderTextForComments()
        }
        textView.resignFirstResponder()
    }
    
    func placeholderTextForComments() -> NSAttributedString {
        let placeholderString = NSLocalizedString("schedule_vote_comments_placeholder", comment: "")
        return NSAttributedString(string: placeholderString, attributes: [NSAttributedString.Key.font: UIFont.fontHelveticaNeueItalic(kVotePlaceholderFontSize), NSAttributedString.Key.foregroundColor: UIColor.grayCommentsPlaceholder()])
    }
    
    func attributedStringForComment(_ comment: String) -> NSAttributedString {
        return NSAttributedString(string: comment, attributes: [NSAttributedString.Key.font: UIFont.fontHelveticaNeueLight(kVotePlaceholderFontSize),
            NSAttributedString.Key.foregroundColor: UIColor.blackForCommentsNormalText()])
    }
    
    func currentVotingComments() -> String? {
        if txtViewVoteComments.attributedText.string != placeholderTextForComments().string {
            return txtViewVoteComments.attributedText.string
        }
        return nil
    }
    
}

