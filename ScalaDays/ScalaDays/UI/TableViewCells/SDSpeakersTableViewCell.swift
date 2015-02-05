//
//  SDSpeakersTableViewCell.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 05/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class SDSpeakersTableViewCell: SDSocialTableViewCell {
    override func awakeFromNib() {
        self.imgView.circularImage()
        self.lblContent.numberOfLines = 0
        self.lblContent.setCustomFont(UIFont.fontHelveticaNeueLight(15), colorFont: UIColor.appColor())
        self.lblFullName.setCustomFont(UIFont.fontHelveticaNeueMedium(15), colorFont: UIColor.appColor())
        self.lblUsername.setCustomFont(UIFont.fontHelveticaNeue(15), colorFont: UIColor.appRedColor())
    }
    
    func drawSpeakerData(speaker: Speaker) {
        lblFullName.text = speaker.name
        if let twitterUsername = speaker.twitter {
            lblUsername.text = twitterUsername
        } else {
            lblUsername.text = ""
        }
        lblContent.text = speaker.bio.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if let pictureUrlString = speaker.picture {
            if let pictureUrl = NSURL(string: pictureUrlString) {
                imgView.sd_setImageWithURL(pictureUrl)
            }
        }
        layoutSubviews()
    }
}
