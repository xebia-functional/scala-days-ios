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
        var information = Information(id: 111, name: "scaladays-sanfran-2015", longName: "Scala Days San Francisco", nameAndLocation: "Scala Days San Francisco, March 16-18, San Francisco, California", firstDay: "2015-03-16", lastDay: "2015-03-20", normalSite: "http://gotocon.com/scaladays-sanfran-2015", registrationSite: "https://secure.trifork.com/scaladays-sanfran-2015/registration/", utcTimezoneOffset: "America/Los_Angeles", utcTimezoneOffsetMillis: -25200000)
        var conference = Conference(info: information, schedule: [], sponsors: [], speakers: [])
        StoringHelper.sharedInstance.storeConferenceData(conference)
        let loadedData = StoringHelper.sharedInstance.loadConferenceData()
        if let loadedConference = loadedData {
            // MARK: Testing equality of both conference instances...
            XCTAssert(conference.info.name == loadedConference.info.name, "Conference data should be the same after being stored: field name")
            XCTAssert(conference.info.id == loadedConference.info.id, "Conference data should be the same after being stored: field id")
            XCTAssert(conference.info.nameAndLocation == loadedConference.info.nameAndLocation, "Conference data should be the same after being stored: field nameAndLocation")
            XCTAssert(conference.info.firstDay == loadedConference.info.firstDay, "Conference data should be the same after being stored: field firstDay")
            XCTAssert(conference.info.lastDay == loadedConference.info.lastDay, "Conference data should be the same after being stored: field lastDay")
            XCTAssert(conference.info.normalSite == loadedConference.info.normalSite, "Conference data should be the same after being stored: field normalSite")
            XCTAssert(conference.info.registrationSite == loadedConference.info.registrationSite, "Conference data should be the same after being stored: field registrationSite")
            XCTAssert(conference.info.utcTimezoneOffset == loadedConference.info.utcTimezoneOffset, "Conference data should be the same after being stored: field utcTimezoneOffset")
            XCTAssert(conference.info.utcTimezoneOffsetMillis == loadedConference.info.utcTimezoneOffsetMillis, "Conference data should be the same after being stored: field utcTimezoneOffsetMillis")
            
            // TODO: missing the rest of the fields...
        } else {
            XCTFail("Couldn't load valid conference data from disk")
        }
    }
}
