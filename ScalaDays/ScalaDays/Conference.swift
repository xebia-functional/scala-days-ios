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

class Conference {
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
}

// MARK: - Model object classes

class Information {
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
}

class SponsorType {
    let type : String
    let items : Array<Sponsor>
    
    init(type : String, items : Array<Sponsor>) {
        self.type = type
        self.items = items
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
}

class Sponsor {
    let logo : String
    let url : String
    
    init(logo : String, url : String) {
        self.logo = logo
        self.url = url
    }
}