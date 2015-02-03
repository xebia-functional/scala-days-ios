//
//  ScalaDaysTests.swift
//  ScalaDaysTests
//
//  Copyright (c) 2015 Scala Days. All rights reserved.
//
//  Developed by:
//
//  47 Degrees
//  http://47deg.com
//  hello@47deg.com
//

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
        var information = Information(
            id: 111,
            name: "scaladays-sanfran-2015",
            longName: "Scala Days San Francisco",
            nameAndLocation: "Scala Days San Francisco, March 16-18, San Francisco, California",
            firstDay: "2015-03-16",
            lastDay: "2015-03-20",
            normalSite: "http://gotocon.com/scaladays-sanfran-2015",
            registrationSite: "https://secure.trifork.com/scaladays-sanfran-2015/registration/",
            utcTimezoneOffset: "America/Los_Angeles",
            utcTimezoneOffsetMillis: -25200000)
        
        var speaker = Speaker(
            bio: "Speaker 1 biography\nhttp://event.scaladays.org",
            company: "Company",
            id: 1111,
            name: "Nice Guy 1",
            picture: "",
            title: "",
            twitter: "@speaker")
        
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
                    logo: "http://event.scaladays.org/dl/photos/sponsors/sponsor1.png",
                    url: "http://www.scala-days-sponsor1.com")]
                )],
            speakers: [speaker],
            codeOfConduct: "Our Code of Conduct is inspired by the kind folks at NE Scala, who adopted theirs from PNW Scala.")
        
        StoringHelper.sharedInstance.storeConferenceData(conference)
        let loadedData = StoringHelper.sharedInstance.loadConferenceData()
        if let loadedConference = loadedData {
            // MARK: Testing equality of both conference instances...
            XCTAssert(conference == loadedConference, "Conference data should be the same after being stored")
        } else {
            XCTFail("Couldn't load valid conference data from disk")
        }
    }
}
