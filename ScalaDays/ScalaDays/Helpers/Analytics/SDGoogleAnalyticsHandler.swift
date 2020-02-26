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

let kAnalyticScreenNameSchedule = "Schedule"
let kAnalyticScreenNameSocial = "Social"
let kAnalyticScreenNameSpeakers = "Speakers"
let kAnalyticScreenNameTickets = "Tickets"
let kAnalyticScreenNameContact = "Contact"
let kAnalyticScreenNameSponsors = "Sponsors"
let kAnalyticScreenNamePlaces = "Schedule"
let kAnalyticScreenNameAbout = "About"
let kAnalyticScreenNameMenu = "Menu"

let kAnalyticCategoryFilter = "Filter"
let kAnalyticCategoryFavorites = "Favorites"
let kAnalyticCategoryNaviAnalyticte = "NaviAnalyticte"
let kAnalyticCategoryVote = "Vote"

let kAnalyticActionScheduleFilterAll = "All"
let kAnalyticActionScheduleFilterFavorites = "Favorites"
let kAnalyticActionScheduleGoToDetail = "Go to Detail"
let kAnalyticActionScheduleDetailAddToFavorite = "Add"
let kAnalyticActionScheduleDetailRemoveToFavorite = "Remove"
let kAnalyticActionSocialGoToTweet = "Go to Tweet"
let kAnalyticActionSocialPostTweet = "Post Tweet"
let kAnalyticActionSpeakersGoToUser = "Go to User"
let kAnalyticActionTicketsGoToTicket = "Go to Ticket"
let kAnalyticActionContactScanContact = "Scan Contact"
let kAnalyticActionSponsorsGoToSponsor = "Go to Sponsor"
let kAnalyticActionPlacesGoToMap = "Go to Map"
let kAnalyticActionAboutGoToSite = "Go to 47Deg Website"
let kAnalyticActionMenuChangeConference = "Change Conference"
let kAnalyticActionShowVotingDialog = "Show Voting Dialog"
let kAnalyticActionSendVote = "Send Vote"

#warning("send analytics")
//class SDGoogleAnalyticsHandler: NSObject {
//
//    class func sendGoogleAnalyticsTrackingWithScreenName(_ screenName: String?, category: String?, action: String?, label: String?) {
//        #warning("send analytics")
////        if let _ = AppDeleAnalyticte.loadExternalKeys().googleAnalyticsKey {
////            let tracker = AnalyticI.sharedInstance().defaultTracker
////            if let _screenName = screenName {
////                tracker?.set(kAnalyticIScreenName, value: _screenName)
////            }
////
////            let parameters = AnalyticIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: nil).build()
////            tracker?.send(parameters as! [AnyHashable: Any])
////        }
//    }
//}

protocol Analytics {
    func screenName(_ screen: String)
}
