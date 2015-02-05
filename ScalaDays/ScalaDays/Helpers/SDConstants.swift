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

let IS_IPHONE5 = UIScreen.mainScreen().bounds.size.height == 480;

let icon_menu_schedule = "menu_icon_schedule"
let icon_menu_social = "menu_icon_social"
let icon_menu_contact = "menu_icon_social"
let icon_menu_ticket = "menu_icon_ticket"
let icon_menu_sponsors = "menu_icon_sponsors"
let icon_menu_places = "menu_icon_places"
let icon_menu_about = "menu_icon_about"

let Height_Row_Menu: CGFloat = 50
let Height_Header_Menu: CGFloat = 130

let kAnimationShowHideTimeInterval : NSTimeInterval = 0.3
let kTweetCount = 100
let kGlobalPadding : CGFloat = 15.0

let isIOS8OrLater = {() -> Bool in
    switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
    case .OrderedSame, .OrderedDescending:
        return true
    case .OrderedAscending:
        return false
    }
}

let launchSafariToUrl = {(url: NSURL) -> Bool in
    if UIApplication.sharedApplication().canOpenURL(url) {
        UIApplication.sharedApplication().openURL(url)
        return true
    }
    return false
}