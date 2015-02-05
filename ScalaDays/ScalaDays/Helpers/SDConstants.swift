//
//  SDConstants.swift
//  ScalaDays
//
//  Created by Ana on 30/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import Foundation

let icon_menu_schedule = "menu_icon_schedule"
let icon_menu_social = "menu_icon_social"
let icon_menu_ticket = "menu_icon_ticket"
let icon_menu_sponsors = "menu_icon_sponsors"
let icon_menu_places = "menu_icon_places"
let icon_menu_about = "menu_icon_about"

let isIOS8OrLater : () -> Bool = {
    switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
    case .OrderedSame, .OrderedDescending:
        return true
    case .OrderedAscending:
        return false
    }
}

let animationShowHideTimeInterval : NSTimeInterval = 0.3