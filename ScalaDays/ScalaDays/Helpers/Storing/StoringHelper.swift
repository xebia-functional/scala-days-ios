//
//  StoringHelper.swift
//  ScalaDays
//
//  Copyright (c) 2015 Scala Days. All rights reserved.
//
//  Developed by:
//
//  47 Degrees
//  http://47deg.com
//  hello@47deg.com
//

import Foundation

class StoringHelper {
    let kMainConferenceStoringFilename = "sdConferences.data"
    
    class var sharedInstance: StoringHelper {
        struct Static {
            static let instance: StoringHelper = StoringHelper()
        }
        return Static.instance
    }
    
    func storeConferenceData(conferences : Conferences) {
        let conferenceDataPath = StoringHelper.documentsFolderPath().stringByAppendingPathComponent(kMainConferenceStoringFilename)
        NSKeyedArchiver.archiveRootObject(conferences, toFile: conferenceDataPath)
    }
    
    func loadConferenceData() -> Conferences? {
        let fileManager = NSFileManager.defaultManager()
        let conferenceDataPath = StoringHelper.documentsFolderPath().stringByAppendingPathComponent(kMainConferenceStoringFilename)
        
        if(fileManager.fileExistsAtPath(conferenceDataPath)) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(conferenceDataPath) as? Conferences
        }
        return nil
    }
    
    class func documentsFolderPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    }
}