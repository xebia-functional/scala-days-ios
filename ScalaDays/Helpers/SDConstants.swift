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

import Foundation
import UIKit

let kExternalKeysPlistFilename = "SDExternalKeys"
let kExternalKeysDKLocalytics = "Localytics"
let kExternalKeysDKTwitterConsumerKey = "TwitterConsumerKey"
let kExternalKeysDKTwitterConsumerSecret = "TwitterConsumerSecret"

let IS_IPHONE5 = UIScreen.main.bounds.size.height == 480;

let icon_menu_schedule = "menu_icon_schedule"
let icon_menu_social = "menu_icon_social"
let icon_menu_contact = "menu_icon_contact"
let icon_menu_ticket = "menu_icon_ticket"
let icon_menu_sponsors = "menu_icon_sponsors"
let icon_menu_places = "menu_icon_places"
let icon_menu_about = "menu_icon_about"
let icon_menu_speakers = "menu_icon_speakers"

let Height_Row_Menu: CGFloat = 50
let Height_Header_Menu: CGFloat = 130
let kEstimatedDynamicCellsRowHeightHigh : CGFloat = 160.0
let kEstimatedDynamicCellsRowHeightLow : CGFloat = 132.0

let kAnimationShowHideTimeInterval : TimeInterval = 0.3
let kTweetCount = 100
let kGlobalPadding : CGFloat = 15.0

let kMinimumTimeToDownloadDataFromApiInSeconds : TimeInterval = 5*60

let lastModifiedDate = "Last-Modified"
let url47Website = "http://www.47deg.com"
let kAlphaValueFull: CGFloat = 1.0

let isIOS8OrLater = {() -> Bool in
    switch UIDevice.current.systemVersion.compare("8.0.0", options: NSString.CompareOptions.numeric) {
    case .orderedSame, .orderedDescending:
        return true
    case .orderedAscending:
        return false
    }
}

@discardableResult
func launchSafariToUrl(_ url: URL) -> Bool {
    guard UIApplication.shared.canOpenURL(url) else { return false }
    UIApplication.shared.openURL(url)
    return true
}

let screenBounds = UIScreen.main.bounds
let colorScheduleTime = UIColor(red: 70/255, green: 149/255, blue: 174/255, alpha: 1)
let colorScheduleTimeActive = UIColor(red: 51/255, green: 116/255, blue: 136/255, alpha: 1)
