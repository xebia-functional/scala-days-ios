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
        self.conferences = aDecoder.decodeObjectForKey("conferences") as! Array<Conference>
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.conferences, forKey: "conferences")
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
        self.info = aDecoder.decodeObjectForKey("info") as! Information
        self.schedule = aDecoder.decodeObjectForKey("schedule") as! Array<Event>
        self.sponsors = aDecoder.decodeObjectForKey("sponsors") as! Array<SponsorType>
        self.speakers = aDecoder.decodeObjectForKey("speakers") as! Array<Speaker>
        self.venues = aDecoder.decodeObjectForKey("venues") as! Array<Venue>
        self.codeOfConduct = aDecoder.decodeObjectForKey("codeOfConduct") as! String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.info, forKey: "info")
        aCoder.encodeObject(self.schedule, forKey: "schedule")
        aCoder.encodeObject(self.sponsors, forKey: "sponsors")
        aCoder.encodeObject(self.speakers, forKey: "speakers")
        aCoder.encodeObject(self.venues, forKey: "venues")
        aCoder.encodeObject(self.codeOfConduct, forKey: "codeOfConduct")
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
        self.id = aDecoder.decodeIntegerForKey("id")
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.longName = aDecoder.decodeObjectForKey("longName") as! String
        self.nameAndLocation = aDecoder.decodeObjectForKey("nameAndLocation") as! String
        self.firstDay = aDecoder.decodeObjectForKey("firstDay") as! String
        self.lastDay = aDecoder.decodeObjectForKey("lastDay") as! String
        self.normalSite = aDecoder.decodeObjectForKey("normalSite") as! String
        self.registrationSite = aDecoder.decodeObjectForKey("registrationSite") as! String
        self.utcTimezoneOffset = aDecoder.decodeObjectForKey("utcTimezoneOffset") as! String
        self.utcTimezoneOffsetMillis = aDecoder.decodeFloatForKey("utcTimezoneOffsetMillis")
        self.hashtag = aDecoder.decodeObjectForKey("hashtag") as! String
        self.query = aDecoder.decodeObjectForKey("query") as? String
        self.pictures = aDecoder.decodeObjectForKey("pictures") as! Array<Picture>
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
        aCoder.encodeObject(self.hashtag, forKey: "hashtag")
        aCoder.encodeObject(self.query, forKey: "query")
        aCoder.encodeObject(self.pictures, forKey: "pictures")
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
        self.width = aDecoder.decodeIntegerForKey("width")
        self.height = aDecoder.decodeIntegerForKey("height")
        self.url = aDecoder.decodeObjectForKey("url") as! String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.width, forKey: "width")
        aCoder.encodeInteger(self.height, forKey: "height")
        aCoder.encodeObject(self.url, forKey: "url")
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
        self.id = aDecoder.decodeIntegerForKey("id")
        self.title = aDecoder.decodeObjectForKey("title") as! String
        self.apiDescription = aDecoder.decodeObjectForKey("apiDescription") as! String
        self.type = aDecoder.decodeIntegerForKey("type")
        self.startTime = aDecoder.decodeObjectForKey("startTime") as! String
        self.endTime = aDecoder.decodeObjectForKey("endTime") as! String
        self.date = aDecoder.decodeObjectForKey("date") as! String
        self.track = aDecoder.decodeObjectForKey("track") as! Track?
        self.location = aDecoder.decodeObjectForKey("location") as! Location?
        self.speakers = aDecoder.decodeObjectForKey("speakers") as! Array<Speaker>?
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.apiDescription, forKey: "apiDescription")
        aCoder.encodeInteger(self.type, forKey: "type")
        aCoder.encodeObject(self.startTime, forKey: "startTime")
        aCoder.encodeObject(self.endTime, forKey: "endTime")
        aCoder.encodeObject(self.date, forKey: "date")
        aCoder.encodeObject(self.track, forKey: "track")
        aCoder.encodeObject(self.location, forKey: "location")
        aCoder.encodeObject(self.speakers, forKey: "speakers")
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
        self.bio = aDecoder.decodeObjectForKey("bio") as! String
        self.company = aDecoder.decodeObjectForKey("company") as! String
        self.id = aDecoder.decodeIntegerForKey("id")
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.picture = aDecoder.decodeObjectForKey("picture") as! String?
        self.title = aDecoder.decodeObjectForKey("title") as! String
        self.twitter = aDecoder.decodeObjectForKey("twitter") as! String?
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

class Venue: NSObject,  NSCoding {
    let name: String
    let address: String
    let website: String
    let latitude: Double
    let longitude: Double

    init(name: String, address: String, website: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.website = website
        self.latitude = latitude
        self.longitude = longitude
    }

    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.address = aDecoder.decodeObjectForKey("address") as! String
        self.website = aDecoder.decodeObjectForKey("website") as! String
        self.latitude = aDecoder.decodeObjectForKey("latitude") as! Double
        self.longitude = aDecoder.decodeObjectForKey("longitude") as! Double
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.address, forKey: "address")
        aCoder.encodeObject(self.website, forKey: "website")
        aCoder.encodeObject(self.latitude, forKey: "latitude")
        aCoder.encodeObject(self.longitude, forKey: "longitude")
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
        self.type = aDecoder.decodeObjectForKey("type") as! String
        self.items = aDecoder.decodeObjectForKey("items") as! Array<Sponsor>
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.type, forKey: "type")
        aCoder.encodeObject(self.items, forKey: "items")
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
        self.id = aDecoder.decodeIntegerForKey("id")
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.host = aDecoder.decodeObjectForKey("host") as! String
        self.shortdescription = aDecoder.decodeObjectForKey("shortdescription") as! String
        self.apiDescription = aDecoder.decodeObjectForKey("apiDescription") as! String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.host, forKey: "host")
        aCoder.encodeObject(self.shortdescription, forKey: "shortdescription")
        aCoder.encodeObject(self.apiDescription, forKey: "apiDescription")
    }
}

class Location: NSObject, NSCoding {
    let id: Int
    let name: String
    let mapUrl: String

    init(id: Int, let name: String, mapUrl: String) {
        self.id = id
        self.name = name
        self.mapUrl = mapUrl
    }

    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("id")
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.mapUrl = aDecoder.decodeObjectForKey("mapUrl") as! String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.mapUrl, forKey: "mapUrl")
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
        self.logo = aDecoder.decodeObjectForKey("logo") as! String
        self.url = aDecoder.decodeObjectForKey("url") as! String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.logo, forKey: "logo")
        aCoder.encodeObject(self.url, forKey: "url")
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
    case let (.Some(unwrappedLhsSpeakers), .Some(unwrappedRhsSpeakers)):
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

func checkEqualityForArrays<T:Equatable>(lhs: Array<T>, rhs: Array<T>) -> Bool {
    if (lhs.count != rhs.count) {
        return false
    }

    for (index, element) in lhs.enumerate() {
        if (element != rhs[index]) {
            return false
        }
    }
    return true
}