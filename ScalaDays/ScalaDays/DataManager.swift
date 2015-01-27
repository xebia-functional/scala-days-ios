//
//  DataManager.swift
//  ScalaDays
//
//  Created by Ana on 19/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import Foundation


let JsonURL = "http://scala-days-2015.s3.amazonaws.com/conferences.json"

class DataManager {

    func startConnection() {

        Manager.sharedInstance.request(.GET, JsonURL)
        .responseJSON {
            (req, res, json, error) in
            if (error != nil) {
                NSLog("Error: \(error)")
                println(req)
                println(res)
            } else {
                NSLog("Success: \(JsonURL)")
                let jsonFormat = JSON(json!)[0]
                let speakers = jsonFormat["speakers"]
                let schedule = jsonFormat["schedule"]
                let sponsors = jsonFormat["sponsors"]
                let info = jsonFormat["info"]
                println("Information: \(info)")
                println("Speakers : \(speakers)")
                println("Schedule : \(schedule)")
                println("Sponsors : \(sponsors)")

            }
        }
    }


}