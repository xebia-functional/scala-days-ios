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
import UIKit
import Alamofire


let JsonURL = "http://scala-days-2015.s3.amazonaws.com/conferences_2016.json"

private let _DataManagerSharedInstance = DataManager()

class DataManager {

    @objc var conferences: Conferences?

    var lastDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "date") as? Date
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "date")
            UserDefaults.standard.synchronize()
        }
    }
    
    var lastConnectionAttemptDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "lastConnectionAttemptDate") as? Date
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "lastConnectionAttemptDate")
            UserDefaults.standard.synchronize()
        }
    }
    
    var favoritedEvents: Dictionary<Int, Array<Int>>? {
        get {
            if let data = UserDefaults.standard.object(forKey: "favoritedEvents") as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? Dictionary<Int, Array<Int>>
            }
            return Dictionary<Int, Array<Int>>()
        }
        set(newValue) {
            if let favoritesDict = newValue {
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: favoritesDict), forKey: "favoritedEvents")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func isFavoriteEvent(_ event: Event?, selectedConference: Conference?) -> Bool {
        switch (selectedConference, DataManager.sharedInstance.favoritedEvents, event) {
        case let (.some(conference), .some(favoritesDict), .some(currentEvent)):
            if let favoritedEvents = favoritesDict[conference.info.id] {
                return favoritedEvents.contains(currentEvent.id)
            }
            break
        default:
            break
        }
        return false
    }
    
    func storeOrRemoveFavoriteEvent(_ shouldRemove: Bool, event: Event?, selectedConference: Conference?) {
        switch (selectedConference, DataManager.sharedInstance.favoritedEvents, event) {
        case let (.some(conference), .some(favoritesDict), .some(currentEvent)):
            if let favoritedEvents = favoritesDict[conference.info.id] {
                if favoritedEvents.contains(currentEvent.id) {
                    if shouldRemove {
                        var temp = favoritedEvents
                        temp.remove(at: favoritedEvents.index(of: currentEvent.id)!)
                        DataManager.sharedInstance.favoritedEvents![conference.info.id] = temp
                    }
                } else {
                    if !shouldRemove {
                        var temp = favoritedEvents
                        temp.append(currentEvent.id)
                        DataManager.sharedInstance.favoritedEvents![conference.info.id] = temp
                    }
                }
            } else {
                if !shouldRemove {
                    let temp = [conference.info.id : [currentEvent.id]]
                    DataManager.sharedInstance.favoritedEvents = temp
                }
            }
            break
        default:
            break
        }
    }

    var selectedConferenceIndex = 0

    var currentlySelectedConference: Conference? {
        get {
            if let listOfConferences = conferences?.conferences {
                if (listOfConferences.count > selectedConferenceIndex) {
                    return listOfConferences[selectedConferenceIndex]
                }
            }
            return nil
        }
    }

    class var sharedInstance: DataManager {

        struct Static {
            static let instance: DataManager = DataManager()
        }

        return Static.instance
    }

    init() {
        if let conferencesData = StoringHelper.sharedInstance.loadConferenceData() {
            self.conferences = conferencesData
        }
    }

    func loadDataJson(_ forceConnection: Bool = false, callback: @escaping (Bool, NSError?) -> ()) {
        var shouldReconnect = true
        if let lastConnectionDate = self.lastConnectionAttemptDate {
            if Date().timeIntervalSince(lastConnectionDate) < kMinimumTimeToDownloadDataFromApiInSeconds {
                shouldReconnect = false
            }
        }
        
        if forceConnection || shouldReconnect || self.conferences == nil {
            Alamofire.request(JsonURL).responseJSON {
                response in
                
                self.lastConnectionAttemptDate = NSDate() as Date
                
                if let conferencesData = StoringHelper.sharedInstance.loadConferenceData() {
                    self.conferences = conferencesData
                    if let date = response.response?.allHeaderFields[lastModifiedDate] as! String? {
                        let dateJson = SDDateHandler.sharedInstance.parseServerDate(date)
                        if (dateJson == self.lastDate && !forceConnection) {
                            callback(false, (response.result.error as NSError?))
                        } else {
                            if let error = response.result.error {
                                print("Error: \(error)")
                                print(response.request)
                                print(response.response)
                                callback(false, error as NSError)
                            } else {
                                if let _data = response.data {
                                    self.parseAndStoreData(_data)
                                    callback(true, response.result.error as NSError?)
                                } else {
                                    callback(true, response.result.error as NSError?)
                                }                                
                            }
                        }
                    } else {
                        // We're here if we don't have a valid internet connection but we have cached data... we just relay it to the recipient:
                        callback(false, nil)
                    }
                } else {
                    if let date = response.response?.allHeaderFields[lastModifiedDate] as! String? {
                        self.lastDate = SDDateHandler.sharedInstance.parseServerDate(date)
                    }
                    if let error = response.result.error {
                        NSLog("Error: \(error)")
                        print(response.request)
                        print(response.response)
                        callback(false, error as NSError)
                    } else {
                        let jsonData = try? JSONSerialization.data(withJSONObject: response.result.value!)
                        self.parseAndStoreData(jsonData)
                        callback(true, nil)
                    }
                }
            }
        } else {
            callback(false, nil)
        }
    }
    
    func parseAndStoreData(_ data: Data?) {
        guard let data = data else { return }
        
        self.conferences = try! JSONDecoder().decode(Conferences.self, from: data)
        
        if let _conferences = self.conferences {
            StoringHelper.sharedInstance.storeConferenceData(_conferences)
        }
    }

}

