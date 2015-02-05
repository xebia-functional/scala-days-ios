//
//  SDTweet.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 04/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import Foundation

class SDTweet: NSObject {
    let username : String
    let fullName : String
    let tweetText : String
    let profileImage : String
    let dateString : String
    
    init(username : String, fullName : String, tweetText : String, profileImage : String, dateString : String) {
        self.username = username
        self.fullName = fullName
        self.tweetText = tweetText
        self.profileImage = profileImage
        self.dateString = dateString
    }
}
