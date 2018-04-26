//
//  TWTRTweet+SDTweet.swift
//  ScalaDays
//
//  Created by Juan Cazalla Estrella on 25/04/2018.
//  Copyright © 2018 47 Degrees. All rights reserved.
//

import Foundation
import TwitterKit

extension TWTRTweet {
    func sdTweet() -> SDTweet {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return SDTweet(username: author.name,
                       fullName: author.screenName,
                       tweetText: text,
                       profileImage: author.profileImageURL,
                       date: createdAt,
                       id: tweetID)
    }
}
