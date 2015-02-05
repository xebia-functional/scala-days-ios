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

    var conferences: Conferences?

    var lastDate: [NSDate] {
        get {
            var returnValue: [NSDate]? = NSUserDefaults.standardUserDefaults().objectForKey("date") as? [NSDate]
            if returnValue == nil {
                returnValue = nil //Default value
            }
            return returnValue!
        }
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "date")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    func dateformatterDateString(dateString: NSString) -> NSDate? {
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")


        return dateFormatter.dateFromString(dateString)
    }

    class var sharedInstance: DataManager {

        struct Static {
            static let instance: DataManager = DataManager()
        }

        return Static.instance
    }

    init() {
    }

    func loadData(callback: (JSON?, NSError?) -> ()) {
        Manager.sharedInstance.request(.GET, JsonURL).responseJSON {
            (request, response, data, error) -> Void in
            if let conference = StoringHelper.sharedInstance.loadConferenceData() {
                /* File exists. Check if changed */
                //TODO:Implement logic for json when change date
                if let date = response?.allHeaderFields["Date"] as NSString? {
                    println("\(date)")
                }
            } else {
                if (error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                } else {
                    NSLog("Success: \(JsonURL)")
                    let jsonFormat = JSON(data!)
                    callback(jsonFormat, error)
                }
            }

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
            let pictures: [Picture] = []
            let infoParse = Information(id: id, name: name, longName: longName, nameAndLocation: nameAndLocation, firstDay: firstDay, lastDay: lastDay, normalSite: normalSite, registrationSite: registrationSite, utcTimezoneOffset: utcTimezoneOffset, utcTimezoneOffsetMillis: utcTimezoneOffsetMillis, hashtag: hashtag, pictures: pictures)

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
            }

            let arrayVenue = confe["venues"]
            var arrayVenueParse: [Venue] = []
            for (index, venue) in arrayVenue {
                let name = venue["name"].string!
                let address = venue["address"].string!
                let website = venue["website"].string!
                let map = venue["map"].string!
                let venueParse = Venue(name: name, address: address, website: website, map: map)
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
                if (track) {
                    trackParse = Track(id: track["id"].intValue, name: track["name"].string!, host: track["host"].string!, shortdescription: track["shortdescription"].string!, apiDescription: track["description"].string!)
                }

                let location = event["location"]
                var locationParse: Location?
                if (location) {
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

        self.conferences = Conferences(conferences: arrayConferencesParse)
        println("End parse")

        if let unWrapperJson = self.conferences {
            StoringHelper.sharedInstance.storeConferenceData(unWrapperJson)
            println("Save parse")
        }
    }


}

