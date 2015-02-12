//
//  SDScheduleListTableViewCell.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 11/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class SDScheduleListTableViewCell: UITableViewCell {
    
    let kDefaultHeightForLblLocation : CGFloat = 15.0
    let kDefaultHeightForLblSpeaker : CGFloat = 17.0
    let kDefaultHeightForLblTwitter : CGFloat = 17.0
    let kDefaultBottomSpaceForLblLocation : CGFloat = 6.0
    let kDefaultTopSpaceForSpeakerTwitter : CGFloat = 6.0
    let kWidthOfTimeContainer : CGFloat = 68.0
    let kDefaultHorizontalPadding : CGFloat = 15.0
    let kDefaultMaxAlphaForSelectionBG : CGFloat = 0.3
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSpeaker: UILabel!
    @IBOutlet weak var lblTwitter: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var selectedBGView: UIView!
    
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
        lblTitle?.preferredMaxLayoutWidth = self.frame.size.width - kWidthOfTimeContainer - kDefaultHorizontalPadding * 2
    }
    
    func drawEventData(event: Event) {
        if let startDate = SDDateHandler.sharedInstance.parseScheduleDate(event.startTime) {
            lblTime.text = SDDateHandler.sharedInstance.hoursAndMinutesFromDate(startDate)
        }        
        lblTitle.text = event.title        
        if let eventLocation = event.location {
            constraintForLblLocationHeight.constant = kDefaultHeightForLblLocation
            constraintForLblLocationBottomSpace.constant = kDefaultBottomSpaceForLblLocation
            lblLocation.text = eventLocation.name
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
        layoutSubviews()        
    }
}
