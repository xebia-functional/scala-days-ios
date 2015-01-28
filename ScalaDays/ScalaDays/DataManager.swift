//
//  DataManager.swift
//  ScalaDays
//
//  Created by Ana on 19/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import Foundation


let JsonURL = "http://scala-days-2015.s3.amazonaws.com/conferences.json"

private let _DataManagerSharedInstance = DataManager()

class DataManager {

    var conference: Conference?
    var information: Information

    class var sharedInstance: DataManager {

        struct Static {
            static let instance: DataManager = DataManager()
        }

        return Static.instance
    }

    init() {
        self.information = Information()
    }
    
    func loadData(callback: (JSON?, NSError?)->()) {
        Manager.sharedInstance.request(.GET, JsonURL).responseJSON { (request, response, data, error) -> Void in
            if (error != nil) {
                NSLog("Error: \(error)")
                println(request)
                println(response)
            } else {
                NSLog("Success: \(JsonURL)")
                let jsonFormat = JSON(data!)[0]
                callback(jsonFormat, error)
            }
           
        }
    }


    func parseJSON(json: JSON) {
        
        /*Info*/
        let info = json["info"]
        self.information = Information(id: info["id"].intValue, name: info["name"].string!, longName: info["longName"].string!, nameAndLocation: info["nameAndLocation"].string!, firstDay: info["firstDay"].string!, lastDay: info["lastDay"].string!, normalSite: info["normalSite"].string!, registrationSite: info["registrationSite"].string!, utcTimezoneOffset: info["utcTimezoneOffset"].string!, utcTimezoneOffsetMillis: info["utcTimezoneOffsetMillis"].floatValue)

        println("Information: \(self.information.name)")

        /*Speaker*/
        let speakers = json["speakers"]

        /*Shedule*/
        let schedule = json["schedule"]


        /*Sponsors*/
        let sponsors = json["sponsors"]
        
        println("End parse")

    }


}

