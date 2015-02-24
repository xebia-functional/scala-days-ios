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


let JsonURL = "http://scala-days-2015.s3.amazonaws.com/conferences.json"

private let _DataManagerSharedInstance = DataManager()

class DataManager {

    var conferences: Conferences?

    var lastDate: NSDate? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("date") as? NSDate
        }
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "date")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var lastConnectionAttemptDate: NSDate? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("lastConnectionAttemptDate") as? NSDate
        }
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "lastConnectionAttemptDate")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var favoritedEvents: Dictionary<Int, Array<Int>>? {
        get {
            if let data = NSUserDefaults.standardUserDefaults().objectForKey("favoritedEvents") as? NSData {
                return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Dictionary<Int, Array<Int>>
            }
            return Dictionary<Int, Array<Int>>()
        }
        set(newValue) {
            if let favoritesDict = newValue {
                NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(favoritesDict), forKey: "favoritedEvents")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    func isFavoriteEvent(event: Event?, selectedConference: Conference?) -> Bool {
        switch (selectedConference, DataManager.sharedInstance.favoritedEvents, event) {
        case let (.Some(conference), .Some(favoritesDict), .Some(currentEvent)):
            if let favoritedEvents = favoritesDict[conference.info.id] {
                return contains(favoritedEvents, currentEvent.id)
            }
            break
        default:
            break
        }
        return false
    }
    
    func storeOrRemoveFavoriteEvent(shouldRemove: Bool, event: Event?, selectedConference: Conference?) {
        switch (selectedConference, DataManager.sharedInstance.favoritedEvents, event) {
        case let (.Some(conference), .Some(favoritesDict), .Some(currentEvent)):
            if let favoritedEvents = favoritesDict[conference.info.id] {
                if contains(favoritedEvents, currentEvent.id) {
                    if shouldRemove {
                        var temp = favoritedEvents
                        temp.removeAtIndex(find(favoritedEvents, currentEvent.id)!)
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

    func loadDataJson(callback: (Bool, NSError?) -> ()) {
        var shouldReconnect = true
        if let lastConnectionDate = self.lastConnectionAttemptDate {
            if NSDate().timeIntervalSinceDate(lastConnectionDate) < kMinimumTimeToDownloadDataFromApiInSeconds {
                shouldReconnect = false
            }
        }
        
        if shouldReconnect || self.conferences == nil{
            Manager.sharedInstance.request(.GET, JsonURL).responseJSON {
                (request, response, data, error) -> Void in
                self.lastConnectionAttemptDate = NSDate()
                
                if let conferencesData = StoringHelper.sharedInstance.loadConferenceData() {
                    self.conferences = conferencesData
                    if let date = response?.allHeaderFields[lastModifiedDate] as NSString? {
                        let dateJson = SDDateHandler.sharedInstance.parseServerDate(date)
                        if (dateJson == self.lastDate) {
                            println("Json no modified")
                            callback(false, error)
                        } else {
                            if (error != nil) {
                                NSLog("Error: \(error)")
                                println(request)
                                println(response)
                                callback(false, error)
                            } else {
                                if let _data: AnyObject = data {
                                    let jsonFormat = JSON(_data)
                                    self.parseJSON(jsonFormat)
                                    callback(true, error)
                                } else {
                                    callback(true, error)
                                }                                
                            }
                        }
                    } else {
                        // We're here if we don't have a valid internet connection but we have cached data... we just relay it to the recipient:
                        callback(false, nil)
                    }
                } else {
                    if let date = response?.allHeaderFields[lastModifiedDate] as NSString? {
                        self.lastDate = SDDateHandler.sharedInstance.parseServerDate(date)
                    }
                    if (error != nil) {
                        NSLog("Error: \(error)")
                        println(request)
                        println(response)
                        callback(false, error)
                    } else {
                        let jsonFormat = JSON(data!)
                        self.parseJSON(jsonFormat)
                        callback(true, error)
                    }
                }
            }
        } else {
            callback(false, nil)
        }
    }


    func parseJSON(json: JSON) {

        let arrayConferences = json["conferences"]
        var arrayConferencesParse: [Conference] = []

        for (index, confe) in arrayConferences {

            let info = confe["info"]
            let id = info["id"].intValue
            let name = info["name"].string!
            let longName = info["longName"].string!
            let nameAndLocation = info["nameAndLocation"].string!
            let firstDay = info["firstDay"].string!
            let lastDay = info["lastDay"].string!
            let normalSite = info["normalSite"].string!
            let registrationSite = info["registrationSite"].string!
            let utcTimezoneOffset = info["utcTimezoneOffset"].string!
            let utcTimezoneOffsetMillis = info["utcTimezoneOffsetMillis"].floatValue
            let hashtag = info["hashtag"].string!
            let query = info["query"].string?
            
            let pictures = info["pictures"]
            var picturesParse: [Picture] = []
            for (index, picture) in pictures {
                let width = picture["width"].intValue
                let height = picture["height"].intValue
                let url = picture["url"].string!
                let pictureParse = Picture(width: width, height: height, url: url)
                picturesParse.append(pictureParse)
            }

            let infoParse = Information(id: id, name: name, longName: longName, nameAndLocation: nameAndLocation, firstDay: firstDay, lastDay: lastDay, normalSite: normalSite, registrationSite: registrationSite, utcTimezoneOffset: utcTimezoneOffset, utcTimezoneOffsetMillis: utcTimezoneOffsetMillis, hashtag: hashtag, query: query, pictures: picturesParse)

            let arraySpeaker = confe["speakers"]
            var arraySpeakerParse: [Speaker] = []
            for (index, speaker) in arraySpeaker {
                let bio = speaker["bio"].string!
                let company = speaker["company"].string!
                let name = speaker["name"].string!
                let title = speaker["title"].string!
                let id = speaker["id"].intValue
                let picture = speaker["picture"].string?
                let twitter = speaker["twitter"].string?
                let speakerParse = Speaker(bio: bio, company: company, id: id, name: name, picture: picture, title: title, twitter: twitter)
                arraySpeakerParse.append(speakerParse)
            }

            let arraySponsor = confe["sponsors"]
            var arraySponsorParse: [SponsorType] = []
            for (index, sponsorType) in arraySponsor {
                let type = sponsorType["type"].string!
                var arrayItemsParse: [Sponsor] = []
                let items = sponsorType["items"]
                for (index, item) in items {
                    let url = item["url"].string!
                    let logo = item["logo"].string!
                    let sponsor = Sponsor(logo: logo, url: url)
                    arrayItemsParse.append(sponsor)

                }
                let sponsorType = SponsorType(type: type, items: arrayItemsParse)
                arraySponsorParse.append(sponsorType)
            }

            let arrayVenue = confe["venues"]
            var arrayVenueParse: [Venue] = []
            for (index, venue) in arrayVenue {
                let name = venue["name"].string!
                let address = venue["address"].string!
                let website = venue["website"].string!
                let latitude = venue["latitude"].double!
                let longitude = venue["longitude"].double!
                let venueParse = Venue(name: name, address: address, website: website, latitude: latitude, longitude: longitude)
                arrayVenueParse.append(venueParse)
            }

            let codeOfConductParse = confe["codeOfConduct"].string

            let arraySchedule = confe["schedule"]
            var arrayScheduleParse: [Event] = []
            for (index, event) in arraySchedule {
                let id = event["id"].intValue
                let title = event["title"].string!
                let description = event["description"].string!
                let type = event["type"].intValue
                let startTime = event["startTime"].string!
                let endTime = event["endTime"].string!
                let date = event["date"].string!

                let track = event["track"]
                var trackParse: Track?
                if (track != nil) {
                    trackParse = Track(id: track["id"].intValue, name: track["name"].string!, host: track["host"].string!, shortdescription: track["shortdescription"].string!, apiDescription: track["description"].string!)
                }

                let location = event["location"]
                var locationParse: Location?
                if (location != nil) {
                    locationParse = Location(id: location["id"].intValue, name: location["name"].string!, mapUrl: location["mapUrl"].string!)
                }

                let arraySpeakerEvent = event["speakers"]
                var arraySpeakerParseEvent: [Speaker] = []
                for (index, speaker) in arraySpeakerEvent {
                    let bio = speaker["bio"].string!
                    let company = speaker["company"].string!
                    let name = speaker["name"].string!
                    let title = speaker["title"].string!
                    let id = speaker["id"].intValue
                    let picture = speaker["picture"].string?
                    let twitter = speaker["twitter"].string?
                    let speakerParseEvent = Speaker(bio: bio, company: company, id: id, name: name, picture: picture, title: title, twitter: twitter)
                    arraySpeakerParseEvent.append(speakerParseEvent)
                }

                let eventParse = Event(id: id, title: title, apiDescription: description, type: type, startTime: startTime, endTime: endTime, date: date, track: trackParse?, location: locationParse?, speakers: arraySpeakerParseEvent)
                arrayScheduleParse.append(eventParse)
            }
            let conferenceParse = Conference(info: infoParse, schedule: arrayScheduleParse, sponsors: arraySponsorParse, speakers: arraySpeakerParse, venues: arrayVenueParse, codeOfConduct: codeOfConductParse!)
            arrayConferencesParse.append(conferenceParse)
        }

        if arrayConferencesParse.count > 0 {
            self.conferences = Conferences(conferences: arrayConferencesParse)
            println("End parse")
            
            if let unWrapperJson = self.conferences {
                StoringHelper.sharedInstance.storeConferenceData(unWrapperJson)
                println("Save parse")
            }
        }       
        
    }


}

