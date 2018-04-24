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

let kGAScreenNameSchedule = "Schedule"
let kGAScreenNameSocial = "Social"
let kGAScreenNameSpeakers = "Speakers"
let kGAScreenNameTickets = "Tickets"
let kGAScreenNameContact = "Contact"
let kGAScreenNameSponsors = "Sponsors"
let kGAScreenNamePlaces = "Schedule"
let kGAScreenNameAbout = "About"
let kGAScreenNameMenu = "Menu"

let kGACategoryFilter = "Filter"
let kGACategoryFavorites = "Favorites"
let kGACategoryNavigate = "Navigate"
let kGACategoryVote = "Vote"

let kGAActionScheduleFilterAll = "All"
let kGAActionScheduleFilterFavorites = "Favorites"
let kGAActionScheduleGoToDetail = "Go to Detail"
let kGAActionScheduleDetailAddToFavorite = "Add"
let kGAActionScheduleDetailRemoveToFavorite = "Remove"
let kGAActionSocialGoToTweet = "Go to Tweet"
let kGAActionSocialPostTweet = "Post Tweet"
let kGAActionSpeakersGoToUser = "Go to User"
let kGAActionTicketsGoToTicket = "Go to Ticket"
let kGAActionContactScanContact = "Scan Contact"
let kGAActionSponsorsGoToSponsor = "Go to Sponsor"
let kGAActionPlacesGoToMap = "Go to Map"
let kGAActionAboutGoToSite = "Go to 47Deg Website"
let kGAActionMenuChangeConference = "Change Conference"
let kGAActionShowVotingDialog = "Show Voting Dialog"
let kGAActionSendVote = "Send Vote"

class SDGoogleAnalyticsHandler: NSObject {
    
    class func sendGoogleAnalyticsTrackingWithScreenName(_ screenName: String?, category: String?, action: String?, label: String?) {
        if let _ = AppDelegate.loadExternalKeys().googleAnalyticsKey {
            let tracker = GAI.sharedInstance().defaultTracker
            if let _screenName = screenName {
                tracker?.set(kGAIScreenName, value: _screenName)
            }
            
            let parameters = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: nil).build()
            tracker?.send(parameters as! [AnyHashable: Any])
        }        
    }
}
