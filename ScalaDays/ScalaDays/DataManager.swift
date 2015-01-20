//
//  DataManager.swift
//  ScalaDays
//
//  Created by Ana on 19/1/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import Foundation
import Alamofire

let JsonURL = "http://scala-days-2015.s3.amazonaws.com/conferences.json"

class DataManager {
    
    func startConnection(){
        
        Alamofire.request(.GET, JsonURL).responseJSON() {
            (_, _, data, _) in
            println(data)
        
        }
    }
    
}