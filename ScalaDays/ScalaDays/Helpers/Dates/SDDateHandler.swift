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
    lazy var dateFormatter: NSDateFormatter = NSDateFormatter()
    let kTwitterDateFormat = "EEE MMM d HH:mm:ss Z y"
    let kResponseDateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
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
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kResponseDateFormat
        return dateFormatter.dateFromString(dateString)
    }
}
