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

func <=(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 <= rhs.timeIntervalSince1970
}
func >=(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 >= rhs.timeIntervalSince1970
}
func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970
}
func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}
func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}

class SDDateHandler: NSObject {
    lazy var dateFormatter: NSDateFormatter = NSDateFormatter()
    let kTwitterDateFormat = "EEE MMM d HH:mm:ss Z y"
    let kResponseDateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    let kScheduleDateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    let kScheduleOutputWeekDay = "EEEE"
    let kScheduleOutputMonthDay = "dd"
    let kScheduleOutputMonthName = "MMM"
    let kScheduleOutputHours = "HH"
    let kScheduleOutputMinutes = "mm"
    
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

    func parseServerDate(dateString: NSString) -> NSDate? {
        dateFormatter.dateFormat = kResponseDateFormat
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.dateFromString(dateString as String)
    }

    func parseScheduleDate(dateString: NSString) -> NSDate? {
        dateFormatter.dateFormat = kScheduleDateFormat
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.dateFromString(dateString as String)
    }
    
    func formatScheduleDetailDate(date: NSDate) -> String? {
        
        
        dateFormatter.dateFormat = kScheduleOutputWeekDay
        let weekDay = dateFormatter.stringFromDate(date)
        dateFormatter.dateFormat = kScheduleOutputMonthDay
        let monthDayNumber = dateFormatter.stringFromDate(date)
        dateFormatter.dateFormat = kScheduleOutputMonthName
        let monthName = dateFormatter.stringFromDate(date)
        dateFormatter.dateFormat = kScheduleOutputHours
        let hours = dateFormatter.stringFromDate(date)
        dateFormatter.dateFormat = kScheduleOutputMinutes
        let minutes = dateFormatter.stringFromDate(date)
        
        if let monNumber = Int(monthDayNumber){
            return "\(weekDay) (\(monNumber)\(SDDateHandler.ordinalSuffixFromDayNumber(monNumber)) \(monthName).) \(hours):\(minutes)"
        } else {
            dateFormatter.dateStyle = .FullStyle
            dateFormatter.timeStyle = .ShortStyle
            dateFormatter.locale = NSLocale.currentLocale()
            
            return dateFormatter.stringFromDate(date)
        }
    }

    
    func hoursAndMinutesFromDate(date: NSDate) -> String? {
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(date)
    }
    
    
    class func ordinalSuffixFromDayNumber(day: Int) -> String {
        let suffixes = ["th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th"]
        var suffix = "th"
        
        let value = abs(day % 100)
        if (value < 10) || (value > 19) {
            suffix = suffixes[value % 10]
        }
        return suffix
    }
    
    class func convertDateToLocalTime(date: NSDate, timeZoneName: String) -> NSDate? {
        if let tz = NSTimeZone(name: timeZoneName) {
            let seconds : NSTimeInterval = NSTimeInterval(tz.secondsFromGMTForDate(date))
            return NSDate(timeInterval: seconds, sinceDate: date)
        }
        return nil
    }
    
    class func isSafeToVoteForConferenceWithDate(confDate: NSDate, fromReferenceDate refDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let confDateDay = calendar.component(NSCalendarUnit.Day, fromDate: confDate)
        let refDateDay = calendar.component(NSCalendarUnit.Day, fromDate: refDate)
        return confDate.compare(refDate) == NSComparisonResult.OrderedAscending && confDateDay == refDateDay
    }
    
    func isCurrentDateActive(startTime: NSString , endTime: NSString) -> (Bool) {
        var result = false
        let currentDate = NSDate()
        if let timeZoneName = DataManager.sharedInstance.conferences?.conferences[DataManager.sharedInstance.selectedConferenceIndex].info.utcTimezoneOffset,
            startDate = SDDateHandler.sharedInstance.parseScheduleDate(startTime),
            localStartDate = SDDateHandler.convertDateToLocalTime(startDate, timeZoneName: timeZoneName),
            endDate = SDDateHandler.sharedInstance.parseScheduleDate(endTime),
            localEndDate = SDDateHandler.convertDateToLocalTime(endDate, timeZoneName: timeZoneName),
            localCurrentDate = SDDateHandler.convertDateToLocalTime(currentDate, timeZoneName: timeZoneName) {
                if localCurrentDate < localEndDate && localCurrentDate >= localStartDate{
                    result = true
                    return result
                }
        }
        return result
    }
   
}
