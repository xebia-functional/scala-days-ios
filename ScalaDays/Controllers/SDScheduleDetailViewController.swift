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

class SDScheduleDetailViewController: UIViewController {
    @IBOutlet weak var titleSection: UILabel!
    @IBOutlet weak var lblDateSection: UILabel!
    @IBOutlet weak var lblTrack: UILabel!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

    @IBOutlet weak var lblSpeakers: UILabel!
    @IBOutlet weak var viewSpeaker: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewSpeakerListContainer: UIView!
    
    @IBOutlet weak var constraintForLblRoomTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForLblTrackTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForLblDescriptionTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForSpeakerListContainerHeight: NSLayoutConstraint!

    private let analytics: Analytics
    var event: Event?
    let kPadding : CGFloat = 15.0
    var barButtonFavorites : UIBarButtonItem!
    lazy var selectedConference: Conference? = DataManager.sharedInstance.currentlySelectedConference
    
    init(analytics: Analytics) {
        self.analytics = analytics
        super.init(nibName: String(describing: SDScheduleDetailViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentEvent = event {            
            let favoritesIconColor = DataManager.sharedInstance.isFavoriteEvent(event, selectedConference: selectedConference) ? UIColor.appRedColor() : UIColor.white
            barButtonFavorites = UIBarButtonItem(image: UIImage(named: "navigation_bar_icon_favorite_default"), style: .plain, target: self, action: #selector(SDScheduleDetailViewController.didTapFavoritesButton))
            barButtonFavorites.tintColor = favoritesIconColor
            self.navigationItem.rightBarButtonItem = barButtonFavorites
            
            titleSection.text = currentEvent.title
            
            if let timeZoneName = DataManager.sharedInstance.conferences?.conferences[DataManager.sharedInstance.selectedConferenceIndex].info.utcTimezoneOffset {
                if let startDate = SDDateHandler.sharedInstance.parseScheduleDate(currentEvent.startTime) {
                    if let localStartDate = SDDateHandler.convertDateToLocalTime(startDate, timeZoneName: timeZoneName) {
                        lblDateSection.text = SDDateHandler.sharedInstance.formatScheduleDetailDate(localStartDate)
                    }
                }
            }
            
            if currentEvent.date == "" {
                constraintForLblRoomTopSpace.constant = 0
            }
            
            lblTrack.text = ""
            if let trackName = currentEvent.track?.name {
                lblTrack.text = trackName
            }
            if lblTrack.text == "" {
                constraintForLblTrackTopSpace.constant = 0
            }
            
            lblRoom.text = ""
            if let room = currentEvent.location {
                let roomTitle = NSLocalizedString("schedule_location_title", comment: "") + room.name
                lblRoom.attributedText = NSAttributedString(string: roomTitle)
                if let _ = currentEventLocationMapUrl() {
                    lblRoom.attributedText = NSAttributedString(string: roomTitle, attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
                    lblRoom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SDScheduleDetailViewController.didTapOnLocationLabel)))
                    lblRoom.isUserInteractionEnabled = true
                }
            }
            if lblRoom.text == "" {
                constraintForLblDescriptionTopSpace.constant = 0
            }
            
            lblDescription.text = currentEvent.eventDescription
            
            if let speakers = currentEvent.speakers {
                if (speakers.count < 1) {
                    viewSpeaker.isHidden = true
                } else {
                    var lastSpeakerBottomPos : CGFloat = 0
                    speakers.forEach { speaker in
                        let speakerView = SDSpeakerDetailView(frame: CGRect(x: 0, y: lastSpeakerBottomPos, width: screenBounds.width, height: 0),
                                                              analytics: self.analytics)
                        speakerView.drawSpeakerData(speaker)
                        viewSpeakerListContainer.addSubview(speakerView)
                        viewSpeakerListContainer.setNeedsLayout()
                        viewSpeakerListContainer.layoutIfNeeded()
                        
                        let height = speakerView.contentHeight()
                        speakerView.frame = CGRect(x: 0, y: lastSpeakerBottomPos, width: screenBounds.width, height: height)
                        lastSpeakerBottomPos += height
                    }
                    constraintForSpeakerListContainerHeight.constant = lastSpeakerBottomPos
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.logScreenName(.schedule, class: SDScheduleDetailViewController.self)
    }
    
    @objc func didTapFavoritesButton() {
        if DataManager.sharedInstance.isFavoriteEvent(event, selectedConference: selectedConference) {
            DataManager.sharedInstance.storeOrRemoveFavoriteEvent(true, event: event, selectedConference: selectedConference)
            barButtonFavorites.tintColor = UIColor.white
            analytics.logEvent(screenName: .schedule, category: .favorites, action: .removeToFavorite, label: event?.title ?? "event-no-title")
        } else {
            DataManager.sharedInstance.storeOrRemoveFavoriteEvent(false, event: event, selectedConference: selectedConference)
            barButtonFavorites.tintColor = UIColor.appRedColor()
            analytics.logEvent(screenName: .schedule, category: .favorites, action: .addToFavorite, label: event?.title ?? "event-no-title")
        }
    }
    
    // MARK: - Location map stuff
    
    func currentEventLocationMapUrl() -> URL? {
        if let currentEvent = event {
            if let locationMapString = currentEvent.location?.mapUrl {
                if locationMapString == "" {
                    return nil
                }
                return URL(string: locationMapString)
            }
        }
        return nil
    }
    
    @objc func didTapOnLocationLabel() {
        let webViewController = SDWebViewController(analytics: analytics)
        self.navigationController?.pushViewController(webViewController, animated: true)
        self.title = ""
        
        if let url = currentEventLocationMapUrl() {
            webViewController.url = url
        }
    }
}
