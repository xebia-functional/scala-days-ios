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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
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
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testStoringAndLoadingConference() {
        
//        var information = Information(
//            id: 111,
//            name: "scaladays-sanfran-2015",
//            longName: "Scala Days San Francisco",
//            nameAndLocation: "Scala Days San Francisco, March 16-18, San Francisco, California",
//            firstDay: "2015-03-16",
//            lastDay: "2015-03-20",
//            normalSite: "http://gotocon.com/scaladays-sanfran-2015",
//            registrationSite: "https://secure.trifork.com/scaladays-sanfran-2015/registration/",
//            utcTimezoneOffset: "America/Los_Angeles",
//            utcTimezoneOffsetMillis: -25200000,
//            pictures: [Picture(
//                width: 298,
//                height: 188,
//                url: "http://scala-days-2015.s3.amazonaws.com/san_francisco.png")])
//        
//        var speaker = Speaker(
//            bio: "Speaker 1 biography\nhttp://event.scaladays.org",
//            company: "Company",
//            id: 1111,
//            name: "Nice Guy 1",
//            picture: "",
//            title: "",
//            twitter: "@speaker")
//        
//        var venue = Venue(
//            name: "Lodging & Training",
//            address: "Hyatt Fisherman's Wharf 555 North Pont Street San Francisco, CA 94133",
//            website: "http://fishermanswharf.hyatt.com/en/hotel/home.html",
//            map: "https://www.google.com/maps/place/Hyatt+Fisherman's+Wharf/@37.805954,-122.416108,17z/data=!3m1!4b1!4m2!3m1!1s0x808580e4799a55a5:0x6d7309ae49b784bb")
//        
//        var event = Event(
//            id: 6520,
//            title: "Registration Open",
//            apiDescription: "",
//            type: 3,
//            startTime: "2015-03-16T23:00:00Z",
//            endTime: "2015-03-16T23:00:00Z",
//            date: "MONDAY MARCH 16",
//            track: Track(
//                id: 1051,
//                name: "Keynote",
//                host: "",
//                shortdescription: "",
//                apiDescription: ""),
//            location: Location(
//                id: 589,
//                name: "Herbst Pavilion",
//                mapUrl: ""),
//            speakers: [speaker])
//        
//        var conference = Conference(
//            info: information,
//            schedule: [event],
//            sponsors: [SponsorType(
//                type: "Hosted by",
//                items: [Sponsor(
//                    logo: "http://event.scaladays.org/dl/photos/sponsors/sponsor1.png",
//                    url: "http://www.scala-days-sponsor1.com")]
//                )],
//            speakers: [speaker],
//            venues: [venue],
//            codeOfConduct: "Our Code of Conduct is inspired by the kind folks at NE Scala, who adopted theirs from PNW Scala.")
//        
//        StoringHelper.sharedInstance.storeConferenceData(conferences)
//        let loadedData = StoringHelper.sharedInstance.loadConferenceData()
//        if let loadedConference = loadedData {
//            // MARK: Testing equality of both conference instances...
//            XCTAssert(conference == loadedConference, "Conference data should be the same after being stored")
//        } else {
//            XCTFail("Couldn't load valid conference data from disk")
//        }
    }
}
