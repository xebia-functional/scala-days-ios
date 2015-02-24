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
    
    let kFilenameForCompleteJsonSF = "scala_days_complete_sf"
    let kFilenameForWrongJson = "scala_days_wrong"
    
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
        
        if let conferences = createConferenceDataFromJSONFile(kFilenameForCompleteJsonSF) {
            StoringHelper.sharedInstance.storeConferenceData(conferences)
            let loadedData = StoringHelper.sharedInstance.loadConferenceData()
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
        XCTAssertNil(createConferenceDataFromJSONFile(kFilenameForWrongJson), "Parsing of invalid JSONs should return nil")
    }
    
    func testParsingValidJsonWithNoConferences() {
        
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
                    DataManager.sharedInstance.parseJSON(jsonFormat)
                    return DataManager.sharedInstance.conferences
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
}
