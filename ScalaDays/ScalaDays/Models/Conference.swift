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

class Conferences: NSObject, NSCoding{

    let conferences: Array<Conference>
    
    init(conferences : Array<Conference>) {
        self.conferences = conferences
    }

    required init?(coder aDecoder: NSCoder) {
        self.conferences = aDecoder.decodeObject(forKey: "conferences") as! Array<Conference>
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.conferences, forKey: "conferences")
    }

}


class Conference: NSObject, NSCoding {
    
    let info: Information
    let schedule: Array<Event>
    let sponsors: Array<SponsorType>
    let speakers: Array<Speaker>
    let venues: Array<Venue>
    let codeOfConduct: String

    init(info: Information, schedule: Array<Event>, sponsors: Array<SponsorType>, speakers: Array<Speaker>, venues: Array<Venue>, codeOfConduct: String) {
        self.info = info
        self.schedule = schedule
        self.sponsors = sponsors
        self.speakers = speakers
        self.venues = venues
        self.codeOfConduct = codeOfConduct
    }

    required init?(coder aDecoder: NSCoder) {
        self.info = aDecoder.decodeObject(forKey: "info") as! Information
        self.schedule = aDecoder.decodeObject(forKey: "schedule") as! Array<Event>
        self.sponsors = aDecoder.decodeObject(forKey: "sponsors") as! Array<SponsorType>
        self.speakers = aDecoder.decodeObject(forKey: "speakers") as! Array<Speaker>
        self.venues = aDecoder.decodeObject(forKey: "venues") as! Array<Venue>
        self.codeOfConduct = aDecoder.decodeObject(forKey: "codeOfConduct") as! String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.info, forKey: "info")
        aCoder.encode(self.schedule, forKey: "schedule")
        aCoder.encode(self.sponsors, forKey: "sponsors")
        aCoder.encode(self.speakers, forKey: "speakers")
        aCoder.encode(self.venues, forKey: "venues")
        aCoder.encode(self.codeOfConduct, forKey: "codeOfConduct")
    }
}

// MARK: - Model object classes

class Information: NSObject, NSCoding {
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


    init(id: Int, name: String, longName: String, nameAndLocation: String, firstDay: String, lastDay: String, normalSite: String, registrationSite: String, utcTimezoneOffset: String, utcTimezoneOffsetMillis: Float, hashtag: String, query: String?, pictures: Array<Picture>) {
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
    }

    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.longName = aDecoder.decodeObject(forKey: "longName") as! String
        self.nameAndLocation = aDecoder.decodeObject(forKey: "nameAndLocation") as! String
        self.firstDay = aDecoder.decodeObject(forKey: "firstDay") as! String
        self.lastDay = aDecoder.decodeObject(forKey: "lastDay") as! String
        self.normalSite = aDecoder.decodeObject(forKey: "normalSite") as! String
        self.registrationSite = aDecoder.decodeObject(forKey: "registrationSite") as! String
        self.utcTimezoneOffset = aDecoder.decodeObject(forKey: "utcTimezoneOffset") as! String
        self.utcTimezoneOffsetMillis = aDecoder.decodeFloat(forKey: "utcTimezoneOffsetMillis")
        self.hashtag = aDecoder.decodeObject(forKey: "hashtag") as! String
        self.query = aDecoder.decodeObject(forKey: "query") as? String
        self.pictures = aDecoder.decodeObject(forKey: "pictures") as! Array<Picture>
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.longName, forKey: "longName")
        aCoder.encode(self.nameAndLocation, forKey: "nameAndLocation")
        aCoder.encode(self.firstDay, forKey: "firstDay")
        aCoder.encode(self.lastDay, forKey: "lastDay")
        aCoder.encode(self.normalSite, forKey: "normalSite")
        aCoder.encode(self.registrationSite, forKey: "registrationSite")
        aCoder.encode(self.utcTimezoneOffset, forKey: "utcTimezoneOffset")
        aCoder.encode(self.utcTimezoneOffsetMillis, forKey: "utcTimezoneOffsetMillis")
        aCoder.encode(self.hashtag, forKey: "hashtag")
        aCoder.encode(self.query, forKey: "query")
        aCoder.encode(self.pictures, forKey: "pictures")
    }
}

class Picture: NSObject,  NSCoding {
    let width: Int
    let height: Int
    let url: String

    init(width: Int, height: Int, url: String) {
        self.width = width
        self.height = height
        self.url = url
    }

    required init?(coder aDecoder: NSCoder) {
        self.width = aDecoder.decodeInteger(forKey: "width")
        self.height = aDecoder.decodeInteger(forKey: "height")
        self.url = aDecoder.decodeObject(forKey: "url") as! String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.width, forKey: "width")
        aCoder.encode(self.height, forKey: "height")
        aCoder.encode(self.url, forKey: "url")
    }
}

class Event: NSObject,  NSCoding {
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

    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.apiDescription = aDecoder.decodeObject(forKey: "apiDescription") as! String
        self.type = aDecoder.decodeInteger(forKey: "type")
        self.startTime = aDecoder.decodeObject(forKey: "startTime") as! String
        self.endTime = aDecoder.decodeObject(forKey: "endTime") as! String
        self.date = aDecoder.decodeObject(forKey: "date") as! String
        self.track = aDecoder.decodeObject(forKey: "track") as! Track?
        self.location = aDecoder.decodeObject(forKey: "location") as! Location?
        self.speakers = aDecoder.decodeObject(forKey: "speakers") as! Array<Speaker>?
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.apiDescription, forKey: "apiDescription")
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.startTime, forKey: "startTime")
        aCoder.encode(self.endTime, forKey: "endTime")
        aCoder.encode(self.date, forKey: "date")
        aCoder.encode(self.track, forKey: "track")
        aCoder.encode(self.location, forKey: "location")
        aCoder.encode(self.speakers, forKey: "speakers")
    }
}

class Speaker: NSObject, NSCoding {
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

    required init?(coder aDecoder: NSCoder) {
        self.bio = aDecoder.decodeObject(forKey: "bio") as! String
        self.company = aDecoder.decodeObject(forKey: "company") as! String
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.picture = aDecoder.decodeObject(forKey: "picture") as! String?
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.twitter = aDecoder.decodeObject(forKey: "twitter") as! String?
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.bio, forKey: "bio")
        aCoder.encode(self.company, forKey: "company")
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.picture, forKey: "picture")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.twitter, forKey: "twitter")
    }
}

class Venue: NSObject,  NSCoding {
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

    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.address = aDecoder.decodeObject(forKey: "address") as! String
        self.website = aDecoder.decodeObject(forKey: "website") as! String
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as! Double?
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as! Double?
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.address, forKey: "address")
        aCoder.encode(self.website, forKey: "website")
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
    }
}

class SponsorType: NSObject,  NSCoding {
    let type: String
    let items: Array<Sponsor>

    init(type: String, items: Array<Sponsor>) {
        self.type = type
        self.items = items
    }

    required init?(coder aDecoder: NSCoder) {
        self.type = aDecoder.decodeObject(forKey: "type") as! String
        self.items = aDecoder.decodeObject(forKey: "items") as! Array<Sponsor>
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.items, forKey: "items")
    }
}

// MARK: - Model object components classes

class Track: NSObject,  NSCoding {
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

    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.host = aDecoder.decodeObject(forKey: "host") as! String
        self.shortdescription = aDecoder.decodeObject(forKey: "shortdescription") as! String
        self.apiDescription = aDecoder.decodeObject(forKey: "apiDescription") as! String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.host, forKey: "host")
        aCoder.encode(self.shortdescription, forKey: "shortdescription")
        aCoder.encode(self.apiDescription, forKey: "apiDescription")
    }
}

class Location: NSObject, NSCoding {
    let id: Int
    let name: String
    let mapUrl: String

    init(id: Int, name: String, mapUrl: String) {
        self.id = id
        self.name = name
        self.mapUrl = mapUrl
    }

    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.mapUrl = aDecoder.decodeObject(forKey: "mapUrl") as! String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.mapUrl, forKey: "mapUrl")
    }
}

class Sponsor: NSObject, NSCoding {
    let logo: String
    let url: String

    init(logo: String, url: String) {
        self.logo = logo
        self.url = url
    }

    required init?(coder aDecoder: NSCoder) {
        self.logo = aDecoder.decodeObject(forKey: "logo") as! String
        self.url = aDecoder.decodeObject(forKey: "url") as! String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.logo, forKey: "logo")
        aCoder.encode(self.url, forKey: "url")
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

func checkEqualityForArrays<T:Equatable>(_ lhs: Array<T>, rhs: Array<T>) -> Bool {
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
