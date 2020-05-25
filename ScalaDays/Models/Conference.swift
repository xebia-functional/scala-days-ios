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

// MARK: - Model root object class

class Conferences: NSObject, Codable {
    let conferences: Array<Conference>
    
    init(conferences: Array<Conference>) {
        self.conferences = conferences
    }
}

class Conference: NSObject, Codable {
    let info: Information
    let schedule: Array<Event>
    let sponsors: Array<SponsorType>
    let speakers: Array<Speaker>
    let venues: Array<Venue>
    let codeOfConduct: String

    var localStartDate: Date? {
        SDDateHandler.sharedInstance.localStartDate(conference: self)
    }
    
    var localEndDate: Date? {
        SDDateHandler.sharedInstance.localEndDate(conference: self)
    }
    
    var localStartDateFirstEvent: Date? {
        SDDateHandler.sharedInstance.localStartDateFirstEvent(conference: self)
    }
    
    var localEndDateLastEvent: Date? {
        SDDateHandler.sharedInstance.localEndDateLastEvent(conference: self)
    }
    
    var isActive: Bool {
        SDDateHandler.sharedInstance.isConferenceActive(self)
    }
    
    var isQA: Bool {
        info.testMode
    }
    
    init(info: Information, schedule: Array<Event>, sponsors: Array<SponsorType>, speakers: Array<Speaker>, venues: Array<Venue>, codeOfConduct: String) {
        self.info = info
        self.schedule = schedule
        self.sponsors = sponsors
        self.speakers = speakers
        self.venues = venues
        self.codeOfConduct = codeOfConduct
    }
}

// MARK: - Model object classes

class Information: NSObject, Codable {
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
    let hashtag: String
    let query: String?
    let pictures: Array<Picture>
    let testMode: Bool

    init(id: Int, name: String, longName: String, nameAndLocation: String, firstDay: String, lastDay: String, normalSite: String, registrationSite: String, utcTimezoneOffset: String, utcTimezoneOffsetMillis: Float, hashtag: String, query: String?, pictures: Array<Picture>, testMode: Bool) {
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
        self.hashtag = hashtag
        self.query = query
        self.pictures = pictures
        self.testMode = testMode
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        longName = try values.decode(String.self, forKey: .longName)
        nameAndLocation = try values.decode(String.self, forKey: .nameAndLocation)
        firstDay = try values.decode(String.self, forKey: .firstDay)
        lastDay = try values.decode(String.self, forKey: .lastDay)
        normalSite = try values.decode(String.self, forKey: .normalSite)
        registrationSite = try values.decode(String.self, forKey: .registrationSite)
        utcTimezoneOffset = (try values.decode(String.self, forKey: .utcTimezoneOffset)).replacingOccurrences(of: " ", with: "_")
        utcTimezoneOffsetMillis = try values.decode(Float.self, forKey: .utcTimezoneOffsetMillis)
        hashtag = try values.decode(String.self, forKey: .hashtag)
        query = try values.decode(String?.self, forKey: .query)
        pictures = try values.decode([Picture].self, forKey: .pictures)
        testMode = try values.decode(Bool.self, forKey: .testMode)
    }
}

class Picture: NSObject, Codable {
    let width: Int
    let height: Int
    let url: String

    init(width: Int, height: Int, url: String) {
        self.width = width
        self.height = height
        self.url = url
    }
}

class Event: NSObject, Codable {
    let id: Int
    let title: String
    let apiDescription: String
    let type: Int
    let startTime: String
    let endTime: String
    let date: String
    let track: Track?
    let location: Location?
    let speakers: Array<Speaker>?
    
    var eventDescription: String {
        apiDescription.components(separatedBy: "\n").filter { !$0.isEmpty }.joined(separator: "\n\n")
    }

    init(id: Int, title: String, apiDescription: String, type: Int, startTime: String, endTime: String, date: String, track: Track?, location: Location?, speakers: Array<Speaker>?) {
        self.id = id
        self.title = title
        self.apiDescription = apiDescription
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.date = date
        self.track = track
        self.location = location
        self.speakers = speakers
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case apiDescription = "description"
        case type
        case startTime
        case endTime
        case date
        case track
        case location
        case speakers
    }
}

class Speaker: NSObject, Codable {
    let bio: String
    let company: String
    let id: Int
    let name: String
    let picture: String?
    let title: String
    let twitter: String?

    init(bio: String, company: String, id: Int, name: String, picture: String?, title: String, twitter: String?) {
        self.bio = bio
        self.company = company
        self.id = id
        self.name = name
        self.picture = picture
        self.title = title
        self.twitter = twitter
    }
}

class Venue: NSObject, Codable {
    let name: String
    let address: String
    let website: String
    let latitude: Double?
    let longitude: Double?

    init(name: String, address: String, website: String, latitude: Double?, longitude: Double?) {
        self.name = name
        self.address = address
        self.website = website
        self.latitude = latitude
        self.longitude = longitude
    }
}

class SponsorType: NSObject, Codable {
    let type: String
    let items: Array<Sponsor>

    init(type: String, items: Array<Sponsor>) {
        self.type = type
        self.items = items
    }
}

// MARK: - Model object components classes

class Track: NSObject, Codable {
    let id: Int
    let name: String
    let host: String
    let shortdescription: String
    let apiDescription: String

    init(id: Int, name: String, host: String, shortdescription: String, apiDescription: String) {
        self.id = id
        self.name = name
        self.host = host
        self.shortdescription = shortdescription
        self.apiDescription = apiDescription
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case host
        case shortdescription
        case apiDescription = "description"
    }
}

class Location: NSObject, Codable {
    let id: Int
    let name: String
    let mapUrl: String

    init(id: Int, name: String, mapUrl: String) {
        self.id = id
        self.name = name
        self.mapUrl = mapUrl
    }
}

class Sponsor: NSObject, Codable {
    let logo: String
    let url: String

    init(logo: String, url: String) {
        self.logo = logo
        self.url = url
    }
}

// MARK: - Equatable protocol methods implementation

// MARK: Equatable implementation for class Conferences

func ==(lhs: Conferences, rhs: Conferences) -> Bool {
    return checkEqualityForArrays(lhs.conferences, rhs: rhs.conferences)
}

// MARK: Equatable implementation for class Conference

func ==(lhs: Conference, rhs: Conference) -> Bool {
    // Expressions need to be split to not mess with Swift compiler
    let equalityForInfo = lhs.info == rhs.info
    let equalityForSchedule = checkEqualityForArrays(lhs.schedule, rhs: rhs.schedule)
    let equalityForSponsors = checkEqualityForArrays(lhs.sponsors, rhs: rhs.sponsors)
    let equalityForSpeakers = checkEqualityForArrays(lhs.speakers, rhs: rhs.speakers)
    let equalityForVenues = checkEqualityForArrays(lhs.venues, rhs: rhs.venues)
    let equalityForCodeOfConduct = lhs.codeOfConduct == rhs.codeOfConduct
    return equalityForInfo &&
            equalityForSchedule &&
            equalityForSponsors &&
            equalityForSpeakers &&
            equalityForVenues &&
            equalityForCodeOfConduct
}

// MARK: Equatable implementation for class Information

func ==(lhs: Information, rhs: Information) -> Bool {
    let equalityForId = lhs.id == rhs.id
    let equalityForTimezoneOffsetMillis = lhs.utcTimezoneOffsetMillis == rhs.utcTimezoneOffsetMillis
    let equalityForHashtag = lhs.hashtag == rhs.hashtag
    let equalityForQuery = lhs.query == rhs.query
    let equalityForPictures = checkEqualityForArrays(lhs.pictures, rhs: rhs.pictures)
    return equalityForId &&
        lhs.name == rhs.name &&
        lhs.longName == rhs.longName &&
        lhs.nameAndLocation == rhs.nameAndLocation &&
        lhs.firstDay == rhs.firstDay &&
        lhs.lastDay == rhs.lastDay &&
        lhs.normalSite == rhs.normalSite &&
        lhs.registrationSite == rhs.registrationSite &&
        lhs.utcTimezoneOffset == rhs.utcTimezoneOffset &&
        equalityForHashtag &&
        equalityForQuery &&
        equalityForTimezoneOffsetMillis &&
        equalityForPictures
}

// MARK: Equatable implementation for class Picture

func ==(lhs: Picture, rhs: Picture) -> Bool {
    return lhs.width == rhs.width &&
            lhs.height == rhs.height &&
            lhs.url == rhs.url
}

// MARK: Equatable implementation for class Event

func ==(lhs: Event, rhs: Event) -> Bool {
    let equalityForSimpleValues = lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.apiDescription == rhs.apiDescription &&
            lhs.type == rhs.type &&
            lhs.startTime == rhs.startTime &&
            lhs.endTime == rhs.endTime &&
            lhs.date == rhs.date &&
            lhs.track == rhs.track &&
            lhs.location == rhs.location

    // Unwrapping our two speaker arrays is easier using pattern matching:
    switch (lhs.speakers, rhs.speakers) {
    case let (.some(unwrappedLhsSpeakers), .some(unwrappedRhsSpeakers)):
        return equalityForSimpleValues && checkEqualityForArrays(unwrappedLhsSpeakers, rhs: unwrappedRhsSpeakers)
    case (nil, nil):
        return equalityForSimpleValues
    default:
        return false
    }
}

// MARK: Equatable implementation for class Speaker

func ==(lhs: Speaker, rhs: Speaker) -> Bool {
    return lhs.id == rhs.id &&
            lhs.bio == rhs.bio &&
            lhs.company == rhs.company &&
            lhs.name == rhs.name &&
            lhs.picture == rhs.picture &&
            lhs.title == rhs.title &&
            lhs.twitter == rhs.twitter
}

// MARK: Equatable implementation for class Vanue

func ==(lhs: Venue, rhs: Venue) -> Bool {
    return lhs.name == rhs.name &&
            lhs.address == rhs.address &&
            lhs.website == rhs.website &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == lhs.longitude
}

// MARK: Equatable implementation for class Sponsor

func ==(lhs: Sponsor, rhs: Sponsor) -> Bool {
    return lhs.logo == rhs.logo &&
            lhs.url == rhs.url
}

// MARK: Equatable implementation for class SponsorType

func ==(lhs: SponsorType, rhs: SponsorType) -> Bool {
    return lhs.type == rhs.type &&
            checkEqualityForArrays(lhs.items, rhs: rhs.items)
}

// MARK: Equatable implementation for class Track

func ==(lhs: Track, rhs: Track) -> Bool {
    return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.host == rhs.host &&
            lhs.shortdescription == rhs.shortdescription &&
            lhs.apiDescription == rhs.apiDescription
}

// MARK: Equatable implementation for class Location

func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.mapUrl == rhs.mapUrl
}

// MARK: Equality for arrays

func checkEqualityForArrays<T: Equatable>(_ lhs: Array<T>, rhs: Array<T>) -> Bool {
    if (lhs.count != rhs.count) {
        return false
    }

    for (index, element) in lhs.enumerated() {
        if (element != rhs[index]) {
            return false
        }
    }
    return true
}
