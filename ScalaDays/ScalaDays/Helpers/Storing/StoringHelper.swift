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
    let kMainConferenceStoringFilename = "sdConference.data"
    
    class var sharedInstance: StoringHelper {
        struct Static {
            static let instance: StoringHelper = StoringHelper()
        }
        return Static.instance
    }
    
    func storeConferenceData(conference : Conference) {
        let conferenceDataPath = StoringHelper.documentsFolderPath().stringByAppendingPathComponent(kMainConferenceStoringFilename)
        NSKeyedArchiver.archiveRootObject(conference, toFile: conferenceDataPath)
    }
    
    func loadConferenceData() -> Conference? {
        let fileManager = NSFileManager.defaultManager()
        let conferenceDataPath = StoringHelper.documentsFolderPath().stringByAppendingPathComponent(kMainConferenceStoringFilename)
        
        if(fileManager.fileExistsAtPath(conferenceDataPath)) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(conferenceDataPath) as? Conference
        }
        return nil
    }
    
    class func documentsFolderPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    }
}