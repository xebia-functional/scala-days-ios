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


class SDDateHandler: NSObject {
    
    private lazy var dateFormatter: DateFormatter = DateFormatter()
    
    private enum Formatter: String {
        case response = "EEE, dd MMM yyyy HH:mm:ss Z"
        case schedule = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        case conference = "yyyy-MM-dd"
        
        enum Component: String {
            case weekDay = "EEEE"
            case monthDay = "dd"
            case monthName = "MMM"
            case hours = "HH"
            case minutes = "mm"
        }
    }
    
    class var sharedInstance: SDDateHandler {

        struct Static {
            static let instance: SDDateHandler = SDDateHandler()
        }

        return Static.instance
    }

    func parseServerDate(_ dateString: String) -> Date? {
        dateFormatter.dateFormat = Formatter.response.rawValue
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }

    func parseScheduleDate(_ dateString: String) -> Date? {
        dateFormatter.dateFormat = Formatter.schedule.rawValue
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }
    
    func parseConferenceDate(_ dateString: String) -> Date? {
        dateFormatter.dateFormat = Formatter.conference.rawValue
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }
    
    func formatScheduleDetailDate(_ date: Date) -> String? {
        dateFormatter.dateFormat = Formatter.Component.weekDay.rawValue
        let weekDay = dateFormatter.string(from: date)
        dateFormatter.dateFormat = Formatter.Component.monthDay.rawValue
        let monthDayNumber = dateFormatter.string(from: date)
        dateFormatter.dateFormat = Formatter.Component.monthName.rawValue
        let monthName = dateFormatter.string(from: date)
        
        if let monNumber = Int(monthDayNumber){
            return "\(weekDay) (\(monNumber)\(SDDateHandler.ordinalSuffixFromDayNumber(monNumber)) \(monthName).) \(time12H(date: date))"
        } else {
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale.current
            
            return dateFormatter.string(from: date)
        }
    }
    
    private func time12H(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
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
    
    func isCurrentDateActive(_ startTime: String , endTime: String) -> (Bool) {
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
    
    func localStartDate(conference: Conference) -> Date? {
        SDDateHandler.sharedInstance
            .parseConferenceDate(conference.info.firstDay)
            .flatMap { date in SDDateHandler.convertDateToLocalTime(date, timeZoneName: conference.info.utcTimezoneOffset) }
    }
    
    func localEndDate(conference: Conference) -> Date? {
        SDDateHandler.sharedInstance
            .parseConferenceDate(conference.info.lastDay)
            .flatMap { date in SDDateHandler.convertDateToLocalTime(date, timeZoneName: conference.info.utcTimezoneOffset) }
    }
    
    func localStartDateFirstEvent(conference: Conference) -> Date? {
        conference.schedule.compactMap { schedule in SDDateHandler.sharedInstance.parseScheduleDate(schedule.startTime) }
                           .compactMap { date in SDDateHandler.convertDateToLocalTime(date, timeZoneName: conference.info.utcTimezoneOffset) }
                           .sorted(by: <).first
    }
    
    func localEndDateLastEvent(conference: Conference) -> Date? {
        conference.schedule.compactMap { schedule in SDDateHandler.sharedInstance.parseScheduleDate(schedule.endTime) }
                           .compactMap { date in SDDateHandler.convertDateToLocalTime(date, timeZoneName: conference.info.utcTimezoneOffset) }
                           .sorted(by: >).first
    }
    
    func isConferenceActive(_ conference: Conference) -> Bool {
        guard let localCurrentDate = SDDateHandler.convertDateToLocalTime(Date(), timeZoneName: conference.info.utcTimezoneOffset),
              let localEndDate = conference.localEndDate else { return false }
        
        return localCurrentDate <= localEndDate
    }
}
