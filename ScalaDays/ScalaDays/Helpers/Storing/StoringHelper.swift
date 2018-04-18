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

import Foundation

class StoringHelper {
    
    let kMainConferenceStoringFilename = "sdConferences.data"
    let kVotesFilename = "sdVotes.data"
    
    class var sharedInstance: StoringHelper {
        struct Static {
            static let instance: StoringHelper = StoringHelper()
        }
        return Static.instance
    }
    
    // MARK: - Conference storing
    
    func storeConferenceData(_ conferences: Conferences) {
        storeDataFromFileWithFilename(conferences, filename: kMainConferenceStoringFilename)
    }
    
    func loadConferenceData() -> Conferences? {
        return loadDataFromFileWithFilename(kMainConferenceStoringFilename) as? Conferences
    }
    
    // MARK: - Votes storing
    
    func storeVotesData(_ votes: [String: Vote]) {
        storeDataFromFileWithFilename(votes as NSCoding, filename: kVotesFilename)
    }
    
    func loadVotesData() -> [String: Vote]? {
        return loadDataFromFileWithFilename(kVotesFilename) as? [String: Vote]
    }
    
    func storedVoteForConferenceId(_ conferenceId: Int, talkId: Int) -> Vote? {
        if let votes = loadVotesData() {
            let key = "\(conferenceId)\(talkId)"
            return votes[key]
        }
        return nil
    }
    
    // MARK: - Utility functions
    
    class func documentsFolderPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
    }
    
    func loadDataFromFileWithFilename(_ filename: String) -> AnyObject? {
        let fileManager = FileManager.default
        let dataPath = (StoringHelper.documentsFolderPath() as NSString).appendingPathComponent(filename)
        
        if(fileManager.fileExists(atPath: dataPath)) {
            return NSKeyedUnarchiver.unarchiveObject(withFile: dataPath) as AnyObject
        }
        return nil
    }
    
    func storeDataFromFileWithFilename(_ conferences: NSCoding, filename: String) {
        let conferenceDataPath = (StoringHelper.documentsFolderPath() as NSString).appendingPathComponent(filename)
        NSKeyedArchiver.archiveRootObject(conferences, toFile: conferenceDataPath)
    }
}
