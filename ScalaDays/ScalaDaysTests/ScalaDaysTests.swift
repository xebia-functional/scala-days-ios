/*
* Copyright (C) 2015 47 Degrees, LLC http:47deg.com hello@47deg.com
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License. You may obtain
* a copy of the License at
*
*     http:www.apache.org/licenses/LICENSE-2.0
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
    
    let kFilenameForCompleteJsonSF = "scala_days_complete_sf"
    
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
    
    func testStoringAndLoadingConference() {
        
        var information = Information(
            id: 111,
            name: "scaladays-sanfran-2015",
            longName: "Scala Days San Francisco",
            nameAndLocation: "Scala Days San Francisco, March 16-18, San Francisco, California",
            firstDay: "2015-03-16",
            lastDay: "2015-03-20",
            normalSite: "http:gotocon.com/scaladays-sanfran-2015",
            registrationSite: "https:secure.trifork.com/scaladays-sanfran-2015/registration/",
            utcTimezoneOffset: "America/Los_Angeles",
            utcTimezoneOffsetMillis: -25200000,
            hashtag: "#scaladays",
            query: "#scaladays",
            pictures: [Picture(
                width: 298,
                height: 188,
                url: "http:scala-days-2015.s3.amazonaws.com/san_francisco.png")])
        
        var speaker = Speaker(
            bio: "Speaker 1 biography\nhttp:event.scaladays.org",
            company: "Company",
            id: 1111,
            name: "Nice Guy 1",
            picture: "",
            title: "",
            twitter: "@speaker")
        
        var venue = Venue(
            name: "Lodging & Training",
            address: "Hyatt Fisherman's Wharf 555 North Pont Street San Francisco, CA 94133",
            website: "http:fishermanswharf.hyatt.com/en/hotel/home.html",
            latitude: 37.806657,
            longitude: -122.43104)
        
        var event = Event(
            id: 6520,
            title: "Registration Open",
            apiDescription: "",
            type: 3,
            startTime: "2015-03-16T23:00:00Z",
            endTime: "2015-03-16T23:00:00Z",
            date: "MONDAY MARCH 16",
            track: Track(
                id: 1051,
                name: "Keynote",
                host: "",
                shortdescription: "",
                apiDescription: ""),
            location: Location(
                id: 589,
                name: "Herbst Pavilion",
                mapUrl: ""),
            speakers: [speaker])
        
        var conference = Conference(
            info: information,
            schedule: [event],
            sponsors: [SponsorType(
                type: "Hosted by",
                items: [Sponsor(
                    logo: "http:event.scaladays.org/dl/photos/sponsors/sponsor1.png",
                    url: "http:www.scala-days-sponsor1.com")]
                )],
            speakers: [speaker],
            venues: [venue],
            codeOfConduct: "Our Code of Conduct is inspired by the kind folks at NE Scala, who adopted theirs from PNW Scala.")
        
        var conferences = Conferences(conferences: [conference])
        
        StoringHelper.sharedInstance.storeConferenceData(conferences)
        let loadedData = StoringHelper.sharedInstance.loadConferenceData()
        if let loadedConferences = loadedData {
             // MARK: Testing equality of both conference instances...
            XCTAssert(conferences == loadedConferences, "Conference data should be the same after being stored")
        } else {
            XCTFail("Couldn't load valid conference data from disk")
        }
    }
    
    func testParsingCompleteJson() {
        performTestParsingForJsonFile(kFilenameForCompleteJsonSF)
    }
    
    // MARK: Helper functions
    
    func performTestParsingForJsonFile(filename: String) {        
        let jsonUrl = NSBundle(forClass: ScalaDaysTests.self).pathForResource(filename, ofType: "json")
        if let _jsonUrl = jsonUrl {
            if let fileData = NSData(contentsOfFile: _jsonUrl) {
                if let jsonFormat = self.parseJSONData(fileData) {
                    DataManager.sharedInstance.parseJSON(jsonFormat)
                    if let _conferences = DataManager.sharedInstance.conferences {
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
                        XCTFail("Couldn't parse valid conferences")
                    }
                } else {
                    XCTFail("Couldn't parse JSON data")
                }
            } else {
                XCTFail("Couldn't load valid json data from disk in test case")
            }
        } else {
            XCTFail("Couldn't load valid json data from disk in test case")
        }
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
}
