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
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

    @IBOutlet weak var lblSpeakers: UILabel!
    @IBOutlet weak var viewSpeaker: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewSpeakerListContainer: UIView!
    
    @IBOutlet weak var constraintForLblRoomTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForLblDescriptionTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForSpeakerListContainerHeight: NSLayoutConstraint!

    var event: Event?
    let kPadding : CGFloat = 15.0

    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentEvent = event {
            titleSection.text = currentEvent.title
            lblDateSection.text = currentEvent.date
            if currentEvent.date == "" {
                constraintForLblRoomTopSpace.constant = 0
            }
            
            lblRoom.text = ""
            if let room = currentEvent.location {
                lblRoom.text = room.name
            }
            if lblRoom == "" {
                constraintForLblDescriptionTopSpace.constant = 0
            }
            
            lblDescription.text = currentEvent.apiDescription
            lblDescription.preferredMaxLayoutWidth = screenBounds.width - (kPadding * 2)
            
            
            if let speakers = currentEvent.speakers? {
                if (speakers.count < 1) {
                    viewSpeaker.hidden = true
                } else {
                    var lastSpeakerBottomPos : CGFloat = 0
                    for (index, speaker) in enumerate(speakers) {
                        let speakerView = SDSpeakerDetailView(frame: CGRectMake(0, lastSpeakerBottomPos, screenBounds.width, 150.0))
                        speakerView.drawSpeakerData(speaker)
                        viewSpeakerListContainer.addSubview(speakerView)
                        
                        if speakers.last != speaker {
                            speakerView.drawSeparator()
                        }
                        
                        let height = speakerView.contentHeight()
                        speakerView.frame = CGRectMake(0, lastSpeakerBottomPos, screenBounds.width, height)
                        lastSpeakerBottomPos += height
                    }
                    constraintForSpeakerListContainerHeight.constant = lastSpeakerBottomPos
                }
            }
        }
    }

}
