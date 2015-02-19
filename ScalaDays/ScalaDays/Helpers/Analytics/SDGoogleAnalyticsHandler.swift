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

let kGACategoryList = "List"
let kGACategoryDetail = "Detail"

let kGAActionScheduleFilterAll = "Filter All"
let kGAActionScheduleFilterFavorites = "Filter Favorites"
let kGAActionScheduleDetailAddToFavorite = "Add to Favorite"
let kGAActionScheduleDetailRemoveToFavorite = "Remove Favorite"
let kGAActionSocialGoToTweet = "Go to Tweet"
let kGAActionSpeakersGoToUser = "Go to User"
let kGAActionContactScanContact = "Scan Contact"
let kGAActionSponsorsGoToSponsor = "Go to Sponsor"
let kGAActionPlacesGoToMap = "Go to Map"
let kGAActionAboutGoToSite = "Go to 47Deg Website"
let kGAActionMenuChangeConference = "Change Conference"

class SDGoogleAnalyticsHandler: NSObject {
    
    class func sendGoogleAnalyticsTrackingWithScreenName(screenName: String, category: String?, action: String?, label: String?) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: screenName)
        
        let parameters = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: nil).build()
        tracker.send(parameters)
    }
}
