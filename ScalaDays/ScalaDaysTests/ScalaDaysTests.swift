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
import XCTest

class ScalaDaysTests: XCTestCase {
    
    let kFilenameForTestConferenceData = "sdConferencesTest.data"
    let kFilenameForCompleteJsonSF = "scala_days_complete_sf"
    let kFilenameForWrongJson = "scala_days_wrong"
    let kFilenameForEmptyJson = "scala_days_empty"
    let kTestScheduleDateString = "2015-03-16T23:00:00Z"
    let kTestScheduleDateTimestamp = NSTimeInterval(1426546800)
    let kTestServerDateString = "Wed, 25 Feb 2015 08:31:06 GMT"
    let kTestServerDateTimestamp = NSTimeInterval(1424853066)
    let kTestTwitterDateString = "Wed Feb 25 09:10:13 +0000 2015"
    let kTestTwitterDateTimestamp = NSTimeInterval(1424855413)
    
    // MARK: - Setting up tests
    
    override func setUp() {
        super.setUp()
        
        let documentsFolderPath = StoringHelper.documentsFolderPath()
        let fileManager = NSFileManager.defaultManager()
        
        if(!fileManager.fileExistsAtPath(documentsFolderPath)) {
            var error : NSErrorPointer = nil
            if !fileManager.createDirectoryAtPath(documentsFolderPath, withIntermediateDirectories: true, attributes: nil, error: error) {
                XCTFail("Couldn't create fake documents directory for testing...")
            }
        }        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Data parsing, loading and storing tests
    
    func testStoringAndLoadingConference() {
        if let conferences = createConferenceDataFromJSONFile(kFilenameForCompleteJsonSF) {
            StoringHelper.sharedInstance.storeConferenceDataFromFileWithFilename(conferences, filename: kFilenameForTestConferenceData)
            let loadedData = StoringHelper.sharedInstance.loadConferenceDataFromFileWithFilename(kFilenameForTestConferenceData)
            if let loadedConferences = loadedData {
                // MARK: Testing equality of both conference instances...
                XCTAssertEqual(conferences, loadedConferences, "Conference data should be the same after being stored")
            } else {
                XCTFail("Couldn't load valid conference data from disk")
            }
        } else {
            XCTFail("Couldn't load JSON test data")
        }
    }
    
    func testParsingCompleteJson() {
        performTestParsingForJsonFile(kFilenameForCompleteJsonSF)
    }
    
    func testParsingWrongJson() {
        XCTAssertNil(createConferenceDataFromJSONFile(kFilenameForWrongJson), "Parsing of invalid JSONs should return a nil")
    }
    
    func testParsingValidJsonWithNoConferences() {
        XCTAssertNil(createConferenceDataFromJSONFile(kFilenameForWrongJson), "Parsing of empty JSONs should return a nil")
    }
    
    // MARK: Datetime conversion tests
    
    func testParsingScheduleDates() {
        if let scheduleDate = SDDateHandler.sharedInstance.parseScheduleDate(kTestScheduleDateString) {
            let timestamp = scheduleDate.timeIntervalSince1970
            XCTAssertEqual(timestamp, kTestScheduleDateTimestamp, "Parsing of test schedule date should return the correct value. Returned \(timestamp), expected \(kTestScheduleDateTimestamp)")
        } else {
            XCTFail("Parsing of schedule dates from the server should return a valid date")
        }
    }
    
    func testParsingServerDates() {
        if let serverDate = SDDateHandler.sharedInstance.parseServerDate(kTestServerDateString) {
            let timestamp = serverDate.timeIntervalSince1970
            XCTAssertEqual(timestamp, kTestServerDateTimestamp, "Parsing of test server date should return the correct value. Returned \(timestamp), expected \(kTestServerDateTimestamp)")
        } else {
            XCTFail("Parsing of server dates from the server should return a valid date")
        }
    }
    
    func testParsingTwitterDates() {
        if let twitterDate = SDDateHandler.sharedInstance.parseTwitterDate(kTestTwitterDateString) {
            let timestamp = twitterDate.timeIntervalSince1970
            XCTAssertEqual(timestamp, kTestTwitterDateTimestamp, "Parsing of test twitter date should return the correct value. Returned \(timestamp), expected \(kTestServerDateTimestamp)")
        } else {
            XCTFail("Parsing of twitter dates from the server should return a valid date")
        }
    }
    
    func testFormatScheduleDates() {
        let date = NSDate(timeIntervalSince1970: kTestScheduleDateTimestamp)
        XCTAssertNotNil(SDDateHandler.sharedInstance.formatScheduleDetailDate(date), "Format of schedule dates from the server should return a valid date string")
    }
    
    func testFormatHoursAndMinutesFromScheduleDates() {
        let date = NSDate(timeIntervalSince1970: kTestScheduleDateTimestamp)
        if let hoursAndMinutes = SDDateHandler.sharedInstance.hoursAndMinutesFromDate(date) {
            let isEnabled24h = is24hTimeSettingEnabled()
            XCTAssertTrue((hoursAndMinutes.rangeOfString(SDDateHandler.sharedInstance.dateFormatter.AMSymbol) == nil &&
                hoursAndMinutes.rangeOfString(SDDateHandler.sharedInstance.dateFormatter.PMSymbol) == nil) == isEnabled24h, "Formatted hours and minutes from schedule date should conform to the chosen 12h/24h setting")
        } else {
            XCTFail("Format of hours and minutes from schedule date should return a valid string")
        }
    }
    
    // MARK: Helper functions
    
    func performTestParsingForJsonFile(filename: String) {
        if let _conferences = createConferenceDataFromJSONFile(filename) {
            if _conferences.conferences.count > 0 {
                let _conference = _conferences.conferences[0]
                XCTAssert(_conferences.conferences.count == 1, "There should be one parsed conference, found \(_conferences.conferences.count)")
                XCTAssertNotNil(_conference.info, "Conference should have a valid Info field")
                XCTAssertNotNil(_conference.schedule, "Conference should have a valid Schedule field")
                XCTAssertNotNil(_conference.sponsors, "Conference should have a valid Sponsors field")
                XCTAssertNotNil(_conference.speakers, "Conference should have a valid Speakers field")
                XCTAssertNotNil(_conference.venues, "Conference should have a valid Venues field")
                XCTAssertNotNil(_conference.codeOfConduct, "Conference should have a valid Code of Conduct field")
                XCTAssert(_conference.info.id == 111, "Parsed data should be valid")
            } else {
                XCTFail("There wasn't any conference data parsed")
            }
        } else {
            XCTFail("Couldn't parse JSON data")
        }
    }
    
    func createConferenceDataFromJSONFile(filename: String) -> Conferences? {
        let jsonUrl = NSBundle(forClass: ScalaDaysTests.self).pathForResource(filename, ofType: "json")
        if let _jsonUrl = jsonUrl {
            if let fileData = NSData(contentsOfFile: _jsonUrl) {
                if let jsonFormat = self.parseJSONData(fileData) {
                    return DataManager.sharedInstance.parseJSON(jsonFormat)
                }
            }
        }
        return nil
    }
    
    func parseJSONData(data: NSData) -> JSON? {
        var serializationError: NSError?
        if let jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &serializationError) {
            if let error = serializationError {
                return nil
            } else {
                return JSON(jsonObject)
            }
        }
        return nil
    }
    
    func is24hTimeSettingEnabled() -> Bool {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        let dateString = dateFormatter.stringFromDate(NSDate())
        return dateString.rangeOfString(dateFormatter.AMSymbol) == nil && dateString.rangeOfString(dateFormatter.PMSymbol) == nil
    }
    
}
