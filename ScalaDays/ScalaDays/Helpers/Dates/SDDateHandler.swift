//
//  SDDateHandler.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 05/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import UIKit

class SDDateHandler: NSObject {
    lazy var dateFormatter : NSDateFormatter = NSDateFormatter()
    let kTwitterDateFormat = "EEE MMM d HH:mm:ss Z y"
    
    class var sharedInstance: SDDateHandler {
        struct Static {
            static let instance: SDDateHandler = SDDateHandler()
        }
        return Static.instance
    }
    
    func parseTwitterDate(twitterDate: String) -> NSDate? {
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = kTwitterDateFormat
        return dateFormatter.dateFromString(twitterDate)
    }
}
