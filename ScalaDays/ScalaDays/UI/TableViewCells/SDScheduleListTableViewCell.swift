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

class SDScheduleListTableViewCell: UITableViewCell {
    
    let kDefaultHeightForLblLocation : CGFloat = 15.0
    let kDefaultHeightForLblSpeaker : CGFloat = 17.0
    let kDefaultHeightForLblTwitter : CGFloat = 17.0
    let kDefaultBottomSpaceForLblLocation : CGFloat = 6.0
    let kDefaultTopSpaceForSpeakerTwitter : CGFloat = 6.0
    let kWidthOfTimeContainer : CGFloat = 68.0
    let kDefaultHorizontalLeading : CGFloat = 15.0
    let kDefaultHorizontalTrailing : CGFloat = 40.0
    let kDefaultMaxAlphaForSelectionBG : CGFloat = 0.3
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSpeaker: UILabel!
    @IBOutlet weak var lblTwitter: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var selectedBGView: UIView!
    @IBOutlet weak var imgFavoriteIcon: UIImageView!
    
    @IBOutlet weak var constraintForLblLocationHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForLblSpeaker: NSLayoutConstraint!
    @IBOutlet weak var constraintForLblTwitter: NSLayoutConstraint!
    @IBOutlet weak var constraintForLblLocationBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForLblSpeakerTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForLblTwitterTopSpace: NSLayoutConstraint!
    
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        self.selectedBGView.alpha = highlighted ? kDefaultMaxAlphaForSelectionBG : 0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        self.selectedBGView.alpha = selected ? kDefaultMaxAlphaForSelectionBG : 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lblTitle?.preferredMaxLayoutWidth = self.frame.size.width - kWidthOfTimeContainer - kDefaultHorizontalLeading - kDefaultHorizontalTrailing
    }
    
    func drawEventData(event: Event) {
        if let timeZoneName = DataManager.sharedInstance.conferences?.conferences[DataManager.sharedInstance.selectedConferenceIndex].info.utcTimezoneOffset {
            if let startDate = SDDateHandler.sharedInstance.parseScheduleDate(event.startTime) {
                if let localStartDate = SDDateHandler.convertDateToLocalTime(startDate, timeZoneName: timeZoneName) {
                    lblTime.text = SDDateHandler.sharedInstance.hoursAndMinutesFromDate(localStartDate)
                     if SDDateHandler.sharedInstance.isCurrentDateActive(event.startTime, endTime: event.endTime){
                        viewTime.backgroundColor = colorScheduleTimeActive
                     } else{
                        viewTime.backgroundColor = colorScheduleTime
                    }
                }
            }
        }
        
        
        lblTitle.text = event.title        
        if let eventLocation = event.location {
            constraintForLblLocationHeight.constant = kDefaultHeightForLblLocation
            constraintForLblLocationBottomSpace.constant = kDefaultBottomSpaceForLblLocation
            lblLocation.text = NSLocalizedString("schedule_location_title", comment: "") + eventLocation.name
        } else {
            constraintForLblLocationHeight.constant = 0
            constraintForLblLocationBottomSpace.constant = 0
        }
        if let speakers = event.speakers {
            let lblHeight = CGFloat(speakers.count) * kDefaultHeightForLblSpeaker
            constraintForLblSpeaker.constant = lblHeight
            constraintForLblTwitter.constant = lblHeight
            constraintForLblSpeakerTopSpace.constant = kDefaultTopSpaceForSpeakerTwitter
            constraintForLblTwitterTopSpace.constant = kDefaultTopSpaceForSpeakerTwitter
            
            lblSpeaker.text = speakers.reduce("", { $0! + "\($1.name)\n" })
            lblTwitter.text = speakers.reduce("", {
                if let twitter = $1.twitter {
                    return $0! + "\(twitter)\n"
                } else {
                    return $0! + "\n"
                }
            })
        } else {
            constraintForLblSpeaker.constant = 0
            constraintForLblTwitter.constant = 0
            constraintForLblSpeakerTopSpace.constant = 0
            constraintForLblTwitterTopSpace.constant = 0
            lblSpeaker.text = ""
            lblTwitter.text = ""
        }
        imgFavoriteIcon.hidden = true
        layoutSubviews()        
    }
}
