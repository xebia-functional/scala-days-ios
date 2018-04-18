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

func <=(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 <= rhs.timeIntervalSince1970
}
func >=(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 >= rhs.timeIntervalSince1970
}
func >(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970
}
func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}
func ==(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}

class SDDateHandler: NSObject {
    lazy var dateFormatter: DateFormatter = DateFormatter()
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

    func parseTwitterDate(_ twitterDate: String) -> Date? {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = kTwitterDateFormat
        return dateFormatter.date(from: twitterDate)
    }

    func parseServerDate(_ dateString: NSString) -> Date? {
        dateFormatter.dateFormat = kResponseDateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString as String)
    }

    func parseScheduleDate(_ dateString: NSString) -> Date? {
        dateFormatter.dateFormat = kScheduleDateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString as String)
    }
    
    func formatScheduleDetailDate(_ date: Date) -> String? {
        
        
        dateFormatter.dateFormat = kScheduleOutputWeekDay
        let weekDay = dateFormatter.string(from: date)
        dateFormatter.dateFormat = kScheduleOutputMonthDay
        let monthDayNumber = dateFormatter.string(from: date)
        dateFormatter.dateFormat = kScheduleOutputMonthName
        let monthName = dateFormatter.string(from: date)
        dateFormatter.dateFormat = kScheduleOutputHours
        let hours = dateFormatter.string(from: date)
        dateFormatter.dateFormat = kScheduleOutputMinutes
        let minutes = dateFormatter.string(from: date)
        
        if let monNumber = Int(monthDayNumber){
            return "\(weekDay) (\(monNumber)\(SDDateHandler.ordinalSuffixFromDayNumber(monNumber)) \(monthName).) \(hours):\(minutes)"
        } else {
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale.current
            
            return dateFormatter.string(from: date)
        }
    }

    
    func hoursAndMinutesFromDate(_ date: Date) -> String? {
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    
    class func ordinalSuffixFromDayNumber(_ day: Int) -> String {
        let suffixes = ["th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th"]
        var suffix = "th"
        
        let value = abs(day % 100)
        if (value < 10) || (value > 19) {
            suffix = suffixes[value % 10]
        }
        return suffix
    }
    
    class func convertDateToLocalTime(_ date: Date, timeZoneName: String) -> Date? {
        if let tz = TimeZone(identifier: timeZoneName) {
            let seconds : TimeInterval = TimeInterval(tz.secondsFromGMT(for: date))
            return Date(timeInterval: seconds, since: date)
        }
        return nil
    }
    
    class func isSafeToVoteForConferenceWithDate(_ confDate: Date, fromReferenceDate refDate: Date) -> Bool {
        let calendar = Calendar.current
        let confDateDay = (calendar as NSCalendar).component(NSCalendar.Unit.day, from: confDate)
        let refDateDay = (calendar as NSCalendar).component(NSCalendar.Unit.day, from: refDate)
        return confDate.compare(refDate) == ComparisonResult.orderedAscending && confDateDay == refDateDay
    }
    
    func isCurrentDateActive(_ startTime: NSString , endTime: NSString) -> (Bool) {
        var result = false
        let currentDate = Date()
        if let timeZoneName = DataManager.sharedInstance.conferences?.conferences[DataManager.sharedInstance.selectedConferenceIndex].info.utcTimezoneOffset,
            let startDate = SDDateHandler.sharedInstance.parseScheduleDate(startTime),
            let localStartDate = SDDateHandler.convertDateToLocalTime(startDate, timeZoneName: timeZoneName),
            let endDate = SDDateHandler.sharedInstance.parseScheduleDate(endTime),
            let localEndDate = SDDateHandler.convertDateToLocalTime(endDate, timeZoneName: timeZoneName),
            let localCurrentDate = SDDateHandler.convertDateToLocalTime(currentDate, timeZoneName: timeZoneName) {
                if (localCurrentDate.timeIntervalSince1970 < localEndDate.timeIntervalSince1970) && localCurrentDate >= localStartDate{
                    result = true
                    return result
                }
        }
        return result
    }
   
}
