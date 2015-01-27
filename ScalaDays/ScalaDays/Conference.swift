//
//  Conference.swift
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

// MARK: - Model root object class

class Conference : NSObject, NSCoding {
    let info : Information
    let schedule : Array<Event>
    let sponsors : Array<SponsorType>
    let speakers : Array<Speaker>
    
    init(info : Information, schedule : Array<Event>, sponsors : Array<SponsorType>, speakers: Array<Speaker>) {
        self.info = info
        self.schedule = schedule
        self.sponsors = sponsors
        self.speakers = speakers
    }
    
    required init(coder aDecoder: NSCoder) {
        self.info = aDecoder.decodeObjectForKey("info") as Information
        self.schedule = aDecoder.decodeObjectForKey("schedule") as Array<Event>
        self.sponsors = aDecoder.decodeObjectForKey("sponsors") as Array<SponsorType>
        self.speakers = aDecoder.decodeObjectForKey("speakers") as Array<Speaker>
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.info, forKey: "info")
        aCoder.encodeObject(self.schedule, forKey: "schedule")
        aCoder.encodeObject(self.sponsors, forKey: "sponsors")
        aCoder.encodeObject(self.speakers, forKey: "speakers")
    }
}

// MARK: - Model object classes

class Information : NSObject, NSCoding {
    let id: Int
    let name: String
    let longName: String
    let nameAndLocation: String
    let firstDay: String
    let lastDay: String
    let normalSite: String
    let registrationSite: String
    let utcTimezoneOffset: String
    let utcTimezoneOffsetMillis: Float
    
    init(id : Int, name : String, longName : String, nameAndLocation : String, firstDay : String, lastDay : String, normalSite : String, registrationSite : String, utcTimezoneOffset : String, utcTimezoneOffsetMillis : Float) {
        self.id = id
        self.name = name
        self.longName = longName
        self.nameAndLocation = nameAndLocation
        self.firstDay = firstDay
        self.lastDay = lastDay
        self.normalSite = normalSite
        self.registrationSite = registrationSite
        self.utcTimezoneOffset = utcTimezoneOffset
        self.utcTimezoneOffsetMillis = utcTimezoneOffsetMillis
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("id")
        self.name = aDecoder.decodeObjectForKey("name") as String
        self.longName = aDecoder.decodeObjectForKey("longName") as String
        self.nameAndLocation = aDecoder.decodeObjectForKey("nameAndLocation") as String
        self.firstDay = aDecoder.decodeObjectForKey("firstDay") as String
        self.lastDay = aDecoder.decodeObjectForKey("lastDay") as String
        self.normalSite = aDecoder.decodeObjectForKey("normalSite") as String
        self.registrationSite = aDecoder.decodeObjectForKey("registrationSite") as String
        self.utcTimezoneOffset = aDecoder.decodeObjectForKey("utcTimezoneOffset") as String
        self.utcTimezoneOffsetMillis = aDecoder.decodeFloatForKey("utcTimezoneOffsetMillis")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.longName, forKey: "longName")
        aCoder.encodeObject(self.nameAndLocation, forKey: "nameAndLocation")
        aCoder.encodeObject(self.firstDay, forKey: "firstDay")
        aCoder.encodeObject(self.lastDay, forKey: "lastDay")
        aCoder.encodeObject(self.normalSite, forKey: "normalSite")
        aCoder.encodeObject(self.registrationSite, forKey: "registrationSite")
        aCoder.encodeObject(self.utcTimezoneOffset, forKey: "utcTimezoneOffset")
        aCoder.encodeFloat(self.utcTimezoneOffsetMillis, forKey: "utcTimezoneOffsetMillis")
    }
}

class Event {
    let id : Int
    let title: String
    let description: String
    let type: Int
    let startTime: String
    let endTime: String
    let date: String
    let track: Track?
    let location: Location?
    let speakers: Array<Speaker>?
    
    init(id : Int, title: String, description : String, type : Int, startTime : String, endTime : String, date : String, track : Track?, location : Location?, speakers : Array<Speaker>?) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.date = date
        self.track = track
        self.location = location
        self.speakers = speakers
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("id")
        self.title = aDecoder.decodeObjectForKey("title") as String
        self.description = aDecoder.decodeObjectForKey("description") as String
        self.type = aDecoder.decodeIntegerForKey("type")
        self.startTime = aDecoder.decodeObjectForKey("startTime") as String
        self.endTime = aDecoder.decodeObjectForKey("endTime") as String
        self.date = aDecoder.decodeObjectForKey("date") as String
        self.track = aDecoder.decodeObjectForKey("track") as Track?
        self.location = aDecoder.decodeObjectForKey("location") as Location?
        self.speakers = aDecoder.decodeObjectForKey("speakers") as Array<Speaker>?
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.description, forKey: "description")
        aCoder.encodeInteger(self.type, forKey: "type")
        aCoder.encodeObject(self.startTime, forKey: "startTime")
        aCoder.encodeObject(self.endTime, forKey: "endTime")
        aCoder.encodeObject(self.date, forKey: "date")
        aCoder.encodeObject(self.track, forKey: "track")
        aCoder.encodeObject(self.location, forKey: "location")
        aCoder.encodeObject(self.speakers, forKey: "speakers")
    }
}

class Speaker {
    let bio : String
    let company : String
    let id: Int
    let name: String
    let picture: String?
    let title : String
    let twitter : String?
    
    init(bio : String, company : String, id: Int, name: String, picture: String?, title : String, twitter : String?) {
        self.bio = bio
        self.company = company
        self.id = id
        self.name = name
        self.picture = picture
        self.title = title
        self.twitter = twitter
    }
    
    required init(coder aDecoder: NSCoder) {
        self.bio = aDecoder.decodeObjectForKey("bio") as String
        self.company = aDecoder.decodeObjectForKey("company") as String
        self.id = aDecoder.decodeIntegerForKey("id")
        self.name = aDecoder.decodeObjectForKey("name") as String
        self.picture = aDecoder.decodeObjectForKey("picture") as String?
        self.title = aDecoder.decodeObjectForKey("title") as String
        self.twitter = aDecoder.decodeObjectForKey("twitter") as String?
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.bio, forKey: "bio")
        aCoder.encodeObject(self.company, forKey: "company")
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.picture, forKey: "picture")
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.twitter, forKey: "twitter")
    }
}

class SponsorType {
    let type : String
    let items : Array<Sponsor>
    
    init(type : String, items : Array<Sponsor>) {
        self.type = type
        self.items = items
    }
    
    required init(coder aDecoder: NSCoder) {
        self.type = aDecoder.decodeObjectForKey("type") as String
        self.items = aDecoder.decodeObjectForKey("items") as Array<Sponsor>
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.type, forKey: "type")
        aCoder.encodeObject(self.items, forKey: "items")
    }
}

// MARK: - Model object components classes

class Track {
    let id: Int
    let name: String
    let host: String
    let shortdescription: String
    let description: String
    
    init(id: Int, name: String, host: String, shortdescription: String, description: String) {
        self.id = id
        self.name = name
        self.host = host
        self.shortdescription = shortdescription
        self.description = description
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("id")
        self.name = aDecoder.decodeObjectForKey("name") as String
        self.host = aDecoder.decodeObjectForKey("host") as String
        self.shortdescription = aDecoder.decodeObjectForKey("shortdescription") as String
        self.description = aDecoder.decodeObjectForKey("description") as String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.host, forKey: "host")
        aCoder.encodeObject(self.shortdescription, forKey: "shortdescription")
        aCoder.encodeObject(self.description, forKey: "description")
    }
}

class Location {
    let id: Int
    let name: String
    let mapUrl: String
    
    init(id: Int, let name: String, mapUrl: String) {
        self.id = id
        self.name = name
        self.mapUrl = mapUrl
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("id")
        self.name = aDecoder.decodeObjectForKey("name") as String
        self.mapUrl = aDecoder.decodeObjectForKey("mapUrl") as String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.mapUrl, forKey: "mapUrl")
    }
}

class Sponsor {
    let logo : String
    let url : String
    
    init(logo : String, url : String) {
        self.logo = logo
        self.url = url
    }
    
    required init(coder aDecoder: NSCoder) {
        self.logo = aDecoder.decodeObjectForKey("logo") as String
        self.url = aDecoder.decodeObjectForKey("url") as String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.logo, forKey: "logo")
        aCoder.encodeObject(self.url, forKey: "url")
    }
}