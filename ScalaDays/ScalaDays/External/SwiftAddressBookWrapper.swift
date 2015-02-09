//SwiftAddressBook - A strong-typed Swift Wrapper for ABAddressBook
//Copyright (C) 2014  Socialbit GmbH
//
//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//    
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see http://www.gnu.org/licenses/ .
//If you would to like license this software for non-free commercial use,
//please write us at kontakt@socialbit.de .

import UIKit
import AddressBook

//MARK: global address book variable

var swiftAddressBook : SwiftAddressBook? {
    get {
        if let instance = swiftAddressBookInstance {
            return instance
        }
        else {
            swiftAddressBookInstance = SwiftAddressBook(0)
            return swiftAddressBookInstance
        }
    }
}


//MARK: private address book store

private var swiftAddressBookInstance : SwiftAddressBook?


//MARK: Address Book

class SwiftAddressBook {
    
    var internalAddressBook : ABAddressBook!
    
    private init?(_ dummy : Int) {
        var err : Unmanaged<CFError>? = nil
        let ab = ABAddressBookCreateWithOptions(nil, &err)
        if err == nil {
            internalAddressBook = ab.takeRetainedValue()
        }
        else {
            return nil
        }
    }
    
    class func authorizationStatus() -> ABAuthorizationStatus {
        return ABAddressBookGetAuthorizationStatus()
    }
    
    func requestAccessWithCompletion( completion : (Bool, CFError?) -> Void ) {
        ABAddressBookRequestAccessWithCompletion(internalAddressBook) {(let b : Bool, c : CFError!) -> Void in completion(b,c)}
    }
    
    func hasUnsavedChanges() -> Bool {
        return ABAddressBookHasUnsavedChanges(internalAddressBook)
    }
    
    func save() -> CFError? {
        return errorIfNoSuccess { ABAddressBookSave(self.internalAddressBook, $0)}
    }
    
    func revert() {
        ABAddressBookRevert(internalAddressBook)
    }
    
    func addRecord(record : SwiftAddressBookRecord) -> CFError? {
        return errorIfNoSuccess { ABAddressBookAddRecord(self.internalAddressBook, record.internalRecord, $0) }
    }
    
    func removeRecord(record : SwiftAddressBookRecord) -> CFError? {
        return errorIfNoSuccess { ABAddressBookRemoveRecord(self.internalAddressBook, record.internalRecord, $0) }
    }
    
//    //This function does not yet work
//    func registerExternalChangeCallback(callback: (AnyObject) -> Void) {
//        //call some objective C function (c function pointer does not work in swift)
//    }
//    
//    //This function does not yet work
//    func unregisterExternalChangeCallback(callback: (AnyObject) -> Void) {
//        //call some objective C function (c function pointer does not work in swift)
//    }
    
    
    //MARK: person records
    
    var personCount : Int {
        get {
            return ABAddressBookGetPersonCount(internalAddressBook)
        }
    }
    
    func personWithRecordId(recordId : Int32) -> SwiftAddressBookPerson? {
        return SwiftAddressBookRecord(record: ABAddressBookGetPersonWithRecordID(internalAddressBook, recordId).takeUnretainedValue()).convertToPerson()
    }
    
    var allPeople : [SwiftAddressBookPerson]? {
        get {
            return convertRecordsToPersons(ABAddressBookCopyArrayOfAllPeople(internalAddressBook).takeRetainedValue())
        }
    }
    
    func allPeopleInSource(source : SwiftAddressBookSource) -> [SwiftAddressBookPerson]? {
        return convertRecordsToPersons(ABAddressBookCopyArrayOfAllPeopleInSource(internalAddressBook, source.internalRecord).takeRetainedValue())
    }
    
    func allPeopleInSourceWithSortOrdering(source : SwiftAddressBookSource, ordering : SwiftAddressBookOrdering) -> [SwiftAddressBookPerson]? {
        return convertRecordsToPersons(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(internalAddressBook, source.internalRecord, ordering.abPersonSortOrderingValue).takeRetainedValue())
    }
    
    func peopleWithName(name : String) -> [SwiftAddressBookPerson]? {
        let string : CFString = name as CFString
        return convertRecordsToPersons(ABAddressBookCopyPeopleWithName(internalAddressBook, string).takeRetainedValue())
    }
    
    
    //MARK: group records
    
    func groupWithRecordId(recordId : Int32) -> SwiftAddressBookGroup? {
        return SwiftAddressBookRecord(record: ABAddressBookGetGroupWithRecordID(internalAddressBook, recordId).takeUnretainedValue()).convertToGroup()
    }
    
    var groupCount : Int {
        get {
            return ABAddressBookGetGroupCount(internalAddressBook)
        }
    }
    
    var arrayOfAllGroups : [SwiftAddressBookGroup]? {
        get {
            return convertRecordsToGroups(ABAddressBookCopyArrayOfAllGroups(internalAddressBook).takeRetainedValue())
        }
    }
    
    func allGroupsInSource(source : SwiftAddressBookSource) -> [SwiftAddressBookGroup]? {
        return convertRecordsToGroups(ABAddressBookCopyArrayOfAllGroupsInSource(internalAddressBook, source.internalRecord).takeRetainedValue())
    }
    
    
    //MARK: sources
    
    var defaultSource : SwiftAddressBookSource? {
        get {
            return SwiftAddressBookSource(record: ABAddressBookCopyDefaultSource(internalAddressBook).takeRetainedValue())
        }
    }
    
    func sourceWithRecordId(sourceId : Int32) -> SwiftAddressBookSource? {
        return SwiftAddressBookSource(record: ABAddressBookGetSourceWithRecordID(internalAddressBook, sourceId).takeUnretainedValue())
    }
    
    var allSources : [SwiftAddressBookSource]? {
        get {
            return convertRecordsToSources(ABAddressBookCopyArrayOfAllSources(internalAddressBook).takeRetainedValue())
        }
    }
    
}


//MARK: Wrapper for ABAddressBookRecord

class SwiftAddressBookRecord {
    
    var internalRecord : ABRecord
    
    init(record : ABRecord) {
        internalRecord = record
    }
    
    func convertToSource() -> SwiftAddressBookSource? {
        if ABRecordGetRecordType(internalRecord) == UInt32(kABSourceType) {
            let source = SwiftAddressBookSource(record: internalRecord)
            return source
        }
        else {
            return nil
        }
    }
    
    func convertToGroup() -> SwiftAddressBookGroup? {
        if ABRecordGetRecordType(internalRecord) == UInt32(kABGroupType) {
            let group = SwiftAddressBookGroup(record: internalRecord)
            return group
        }
        else {
            return nil
        }
    }
    
    func convertToPerson() -> SwiftAddressBookPerson? {
        if ABRecordGetRecordType(internalRecord) == UInt32(kABPersonType) {
            let person = SwiftAddressBookPerson(record: internalRecord)
            return person
        }
        else {
            return nil
        }
    }
}


//MARK: Wrapper for ABAddressBookRecord of type ABSource

class SwiftAddressBookSource : SwiftAddressBookRecord {
    
    var sourceType : SwiftAddressBookSourceType {
        get {
            let sourceType : CFNumber = ABRecordCopyValue(internalRecord, kABSourceTypeProperty).takeRetainedValue() as CFNumber
            var rawSourceType : Int32? = nil
            CFNumberGetValue(sourceType, CFNumberGetType(sourceType), &rawSourceType)
            return SwiftAddressBookSourceType(abSourceType: rawSourceType!)
        }
    }
    
    var searchable : Bool {
        get {
            let sourceType : CFNumber = ABRecordCopyValue(internalRecord, kABSourceTypeProperty).takeRetainedValue() as CFNumber
            var rawSourceType : Int32? = nil
            CFNumberGetValue(sourceType, CFNumberGetType(sourceType), &rawSourceType)
            let andResult = kABSourceTypeSearchableMask & rawSourceType!
            return andResult != 0
        }
    }
    
    var sourceName : String {
        return ABRecordCopyValue(internalRecord, kABSourceNameProperty).takeRetainedValue() as CFString
    }
}



//MARK: Wrapper for ABAddressBookRecord of type ABGroup

class SwiftAddressBookGroup : SwiftAddressBookRecord {
    
    var name : String {
        get {
            return ABRecordCopyValue(internalRecord, kABGroupNameProperty).takeRetainedValue() as CFString
        }
    }
    
    class func create() -> SwiftAddressBookGroup {
        return SwiftAddressBookGroup(record: ABGroupCreate().takeRetainedValue())
    }
    
    class func createInSource(source : SwiftAddressBookSource) -> SwiftAddressBookGroup {
        return SwiftAddressBookGroup(record: ABGroupCreateInSource(source.internalRecord).takeRetainedValue())
    }
    
    var allMembers : [SwiftAddressBookPerson]? {
        get {
            return convertRecordsToPersons(ABGroupCopyArrayOfAllMembers(internalRecord).takeRetainedValue())
        }
    }
    
    func allMembersWithSortOrdering(ordering : SwiftAddressBookOrdering) -> [SwiftAddressBookPerson]? {
        return convertRecordsToPersons(ABGroupCopyArrayOfAllMembersWithSortOrdering(internalRecord, ordering.abPersonSortOrderingValue).takeRetainedValue())
    }
    
    func addMember(person : SwiftAddressBookPerson) -> CFError? {
        return errorIfNoSuccess { ABGroupAddMember(self.internalRecord, person.internalRecord, $0) }
    }
    
    func removeMember(person : SwiftAddressBookPerson) -> CFError? {
        return errorIfNoSuccess { ABGroupRemoveMember(self.internalRecord, person.internalRecord, $0) }
    }
    
    var source : SwiftAddressBookSource {
        get {
            return SwiftAddressBookSource(record: ABGroupCopySource(internalRecord).takeRetainedValue())
        }
    }
}


//MARK: Wrapper for ABAddressBookRecord of type ABPerson

class SwiftAddressBookPerson : SwiftAddressBookRecord {
    
    class func create() -> SwiftAddressBookPerson {
        return SwiftAddressBookPerson(record: ABPersonCreate().takeRetainedValue())
    }
    
    class func createInSource(source : SwiftAddressBookSource) -> SwiftAddressBookPerson {
        return SwiftAddressBookPerson(record: ABPersonCreateInSource(source.internalRecord).takeRetainedValue())
    }
    
    class func createInSourceWithVCard(source : SwiftAddressBookSource, vCard : String) -> [SwiftAddressBookPerson]? {
        let data : NSData? = vCard.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let abPersons : NSArray? = ABPersonCreatePeopleInSourceWithVCardRepresentation(source.internalRecord, data).takeRetainedValue()
        var swiftPersons = [SwiftAddressBookPerson]()
        if let persons = abPersons {
            for person : ABRecord in persons {
                let swiftPerson = SwiftAddressBookPerson(record: person)
                swiftPersons.append(swiftPerson)
            }
        }
        if swiftPersons.count != 0 {
            return swiftPersons
        }
        else {
            return nil
        }
    }
    
    class func createVCard(people : [SwiftAddressBookPerson]) -> String {
        let peopleArray : NSArray = people.map{$0.internalRecord}
        let data : NSData = ABPersonCreateVCardRepresentationWithPeople(peopleArray).takeRetainedValue()
        return NSString(data: data, encoding: NSUTF8StringEncoding)!
    }
    
    class func ordering() -> SwiftAddressBookOrdering {
        return SwiftAddressBookOrdering(ordering: ABPersonGetSortOrdering())
    }
    
    class func comparePeopleByName(person1 : SwiftAddressBookPerson, person2 : SwiftAddressBookPerson, ordering : SwiftAddressBookOrdering) -> CFComparisonResult {
        return ABPersonComparePeopleByName(person1, person2, ordering.abPersonSortOrderingValue)
    }
    
    
    
    
    //MARK: Personal Information
    
    
    func setImage(image : UIImage) -> CFError? {
        let imageData : NSData = UIImagePNGRepresentation(image)
        return errorIfNoSuccess { ABPersonSetImageData(self.internalRecord,  CFDataCreate(nil, UnsafePointer(imageData.bytes), imageData.length), $0) }
    }
    
    var image : UIImage? {
        get {
            return UIImage(data: ABPersonCopyImageData(internalRecord).takeRetainedValue())
        }
    }
    
    func imageDataWithFormat(format : SwiftAddressBookPersonImageFormat) -> UIImage? {
        return UIImage(data: ABPersonCopyImageDataWithFormat(internalRecord, format.abPersonImageFormat).takeRetainedValue())
    }
    
    func hasImageData() -> Bool {
        return ABPersonHasImageData(internalRecord)
    }
    
    func removeImage() -> CFError? {
        return errorIfNoSuccess { ABPersonRemoveImageData(self.internalRecord, $0) }
    }
    
    var allLinkedPeople : [SwiftAddressBookPerson]? {
        get {
            return convertRecordsToPersons(ABPersonCopyArrayOfAllLinkedPeople(internalRecord).takeRetainedValue() as CFArray)
        }
    }
    
    var source : SwiftAddressBookSource {
        get {
            return SwiftAddressBookSource(record: ABPersonCopySource(internalRecord).takeRetainedValue())
        }
    }
    
    var compositeNameDelimiterForRecord : String {
        get {
            return ABPersonCopyCompositeNameDelimiterForRecord(internalRecord).takeRetainedValue()
        }
    }
    
    var compositeNameFormat : SwiftAddressBookCompositeNameFormat {
        get {
            return SwiftAddressBookCompositeNameFormat(format: ABPersonGetCompositeNameFormatForRecord(internalRecord))
        }
    }
    
    var firstName : String? {
        get {
            return extractProperty(kABPersonFirstNameProperty)
        }
        set {
            setSingleValueProperty(kABPersonFirstNameProperty, NSString(string: newValue))
        }
    }
    
    var lastName : String? {
        get {
            return extractProperty(kABPersonLastNameProperty)
        }
        set {
            setSingleValueProperty(kABPersonLastNameProperty, NSString(string: newValue))
        }
    }
    
    var middleName : String? {
        get {
            return extractProperty(kABPersonMiddleNameProperty)
        }
        set {
            setSingleValueProperty(kABPersonMiddleNameProperty, NSString(string: newValue))
        }
    }
    
    var prefix : String? {
        get {
            return extractProperty(kABPersonPrefixProperty)
        }
        set {
            setSingleValueProperty(kABPersonPrefixProperty, NSString(string: newValue))
        }
    }
    
    var suffix : String? {
        get {
            return extractProperty(kABPersonSuffixProperty)
        }
        set {
            setSingleValueProperty(kABPersonSuffixProperty, NSString(string: newValue))
        }
    }
    
    var nickname : String? {
        get {
            return extractProperty(kABPersonNicknameProperty)
        }
        set {
            setSingleValueProperty(kABPersonNicknameProperty, NSString(string: newValue))
        }
    }
    
    var firstNamePhonetic : String? {
        get {
            return extractProperty(kABPersonFirstNamePhoneticProperty)
        }
        set {
            setSingleValueProperty(kABPersonFirstNamePhoneticProperty, NSString(string: newValue))
        }
    }
    
    var lastNamePhonetic : String? {
        get {
            return extractProperty(kABPersonLastNamePhoneticProperty)
        }
        set {
            setSingleValueProperty(kABPersonLastNamePhoneticProperty, NSString(string: newValue))
        }
    }
    
    var middleNamePhonetic : String? {
        get {
            return extractProperty(kABPersonMiddleNamePhoneticProperty)
        }
        set {
            setSingleValueProperty(kABPersonMiddleNamePhoneticProperty, NSString(string: newValue))
        }
    }
    
    var organization : String? {
        get {
            return extractProperty(kABPersonOrganizationProperty)
        }
        set {
            setSingleValueProperty(kABPersonOrganizationProperty, NSString(string: newValue))
        }
    }
    
    var jobTitle : String? {
        get {
            return extractProperty(kABPersonJobTitleProperty)
        }
        set {
            setSingleValueProperty(kABPersonJobTitleProperty, NSString(string: newValue))
        }
    }
    
    var department : String? {
        get {
            return extractProperty(kABPersonDepartmentProperty)
        }
        set {
            setSingleValueProperty(kABPersonDepartmentProperty, NSString(string: newValue))
        }
    }
    
    var emails : Array<MultivalueEntry<String>>? {
        get {
            return extractMultivalueProperty(kABPersonEmailProperty)
        }
        set {
            setMultivalueProperty(kABPersonEmailProperty, convertMultivalueEntries(newValue, converter: { NSString(string : $0) }))
        }
    }
    
    var birthday : NSDate? {
        get {
            return extractProperty(kABPersonBirthdayProperty)
        }
        set {
            setSingleValueProperty(kABPersonBirthdayProperty, newValue)
        }
    }
    
    var note : String? {
        get {
            return extractProperty(kABPersonNoteProperty)
        }
        set {
            setSingleValueProperty(kABPersonNoteProperty, NSString(string: newValue))
        }
    }
    
    var creationDate : NSDate? {
        get {
            return extractProperty(kABPersonCreationDateProperty)
        }
        set {
            setSingleValueProperty(kABPersonCreationDateProperty, newValue)
        }
    }
    
    var modificationDate : NSDate? {
        get {
            return extractProperty(kABPersonModificationDateProperty)
        }
        set {
            setSingleValueProperty(kABPersonModificationDateProperty, newValue)
        }
    }
    
    var addresses : Array<MultivalueEntry<Dictionary<SwiftAddressBookAddressProperty,AnyObject>>>? {
        get {
            return extractMultivalueProperty(kABPersonAddressProperty)
        }
        set {
            setMultivalueDictionaryProperty(kABPersonAddressProperty, newValue, { NSString(string: $0.abAddressProperty) }, {$0} )
        }
    }
    
    var dates : Array<MultivalueEntry<NSDate>>? {
        get {
            return extractMultivalueProperty(kABPersonDateProperty)
        }
        set {
            setMultivalueProperty(kABPersonDateProperty, newValue)
        }
    }
    
    var type : SwiftAddressBookPersonType? {
        get {
            return SwiftAddressBookPersonType(type : extractProperty(kABPersonMiddleNameProperty))
        }
        set {
            setSingleValueProperty(kABPersonMiddleNameProperty, newValue?.abPersonType)
        }
    }
    
    var phoneNumbers : Array<MultivalueEntry<String>>? {
        get {
            return extractMultivalueProperty(kABPersonPhoneProperty)
        }
        set {
            setMultivalueProperty(kABPersonPhoneProperty, convertMultivalueEntries(newValue, converter: {NSString(string: $0)}))
        }
    }
    
    var instantMessage : Array<MultivalueEntry<Dictionary<SwiftAddressBookInstantMessagingProperty,String>>>? {
        get {
            return extractMultivalueProperty(kABPersonInstantMessageProperty)
        }
        set {
            setMultivalueDictionaryProperty(kABPersonInstantMessageProperty, newValue, keyConverter: { NSString(string: $0.abInstantMessageProperty) }, valueConverter: { NSString(string: $0) })
        }
    }
    
    var socialProfiles : Array<MultivalueEntry<Dictionary<SwiftAddressBookSocialProfileProperty,String>>>? {
        get {
            return extractMultivalueProperty(kABPersonSocialProfileProperty)
        }
        set {
            setMultivalueDictionaryProperty(kABPersonSocialProfileProperty, newValue, keyConverter: { NSString(string: $0.abSocialProfileProperty) }, valueConverter:  { NSString(string : $0) } )
        }
    }
    
    
    var urls : Array<MultivalueEntry<String>>? {
        get {
            return extractMultivalueProperty(kABPersonURLProperty)
        }
        set {
            setMultivalueProperty(kABPersonURLProperty, convertMultivalueEntries(newValue, converter: { NSString(string : $0) }))
        }
    }
    
    var relatedNames : Array<MultivalueEntry<String>>? {
        get {
            return extractMultivalueProperty(kABPersonRelatedNamesProperty)
        }
        set {
            setMultivalueProperty(kABPersonRelatedNamesProperty, convertMultivalueEntries(newValue, converter: { NSString(string : $0) }))
        }
    }
    
    var alternateBirthday : Dictionary<String, AnyObject>? {
        get {
            return extractProperty(kABPersonAlternateBirthdayProperty)
        }
        set {
            let dict : NSDictionary? = newValue
            setSingleValueProperty(kABPersonAlternateBirthdayProperty, dict)
        }
    }
    
    
    //MARK: generic methods to set and get person properties
    
    private func extractProperty<T>(propertyName : ABPropertyID) -> T? {
        return ABRecordCopyValue(self.internalRecord, propertyName).takeRetainedValue() as? T
    }
    
    private func setSingleValueProperty<T : AnyObject>(key : ABPropertyID,_ value : T?) {
        ABRecordSetValue(self.internalRecord, key, value, nil)
    }
    
    private func extractMultivalueProperty<T>(propertyName : ABPropertyID) -> Array<MultivalueEntry<T>>? {
        var array = Array<MultivalueEntry<T>>()
        let multivalue : ABMultiValue? = extractProperty(propertyName)
        for i : Int in 0..<(ABMultiValueGetCount(multivalue)) {
            let value : T? = ABMultiValueCopyValueAtIndex(multivalue, i).takeRetainedValue() as? T
            if let v : T = value {
                let id : Int = Int(ABMultiValueGetIdentifierAtIndex(multivalue, i))
                let label : String = ABMultiValueCopyLabelAtIndex(multivalue, i).takeRetainedValue()
                array.append(MultivalueEntry(value: v, label: label, id: id))
            }
        }
        if array.count > 0 {
            return array
        }
        else {
            return nil
        }
    }
    
    private func convertDictionary<T,U, V : AnyObject, W : AnyObject where V : Hashable>(d : Dictionary<T,U>?, keyConverter : (T) -> V, valueConverter : (U) -> W ) -> NSDictionary? {
        if let d2 = d {
            var dict = Dictionary<V,W>()
            for key in d2.keys {
                dict[keyConverter(key)] = valueConverter(d2[key]!)
            }
            return dict
        }
        else {
            return nil
        }
    }
    
    private func convertMultivalueEntries<T,U : AnyObject>(multivalue : Array<MultivalueEntry<T>>?, converter : (T) -> U) -> Array<MultivalueEntry<U>>? {
        return multivalue?.map { m -> MultivalueEntry<U> in
            return MultivalueEntry(value: converter(m.value), label: m.label, id: m.id)
        }
    }
    
    private func setMultivalueProperty<T : AnyObject>(key : ABPropertyID,_ multivalue : Array<MultivalueEntry<T>>?) {
        if(multivalue == nil) {
            ABRecordSetValue(internalRecord, key, ABMultiValueCreateMutable(ABMultiValueGetPropertyType(extractProperty(key))).takeRetainedValue(), nil)
        }
        
        let abMultivalue: ABMutableMultiValue = ABMultiValueCreateMutableCopy(extractProperty(key)).takeRetainedValue()
        
        var identifiers = Array<Int>()
        
        for i : Int in 0..<(ABMultiValueGetCount(abMultivalue)) {
            identifiers.append(Int(ABMultiValueGetIdentifierAtIndex(abMultivalue, i)))
        }
        
        for m : MultivalueEntry in multivalue! {
            if contains(identifiers, m.id) {
                let index = ABMultiValueGetIndexForIdentifier(abMultivalue, Int32(m.id))
                ABMultiValueReplaceValueAtIndex(abMultivalue, m.value, index)
                ABMultiValueReplaceLabelAtIndex(abMultivalue, m.label, index)
                identifiers.removeAtIndex(find(identifiers,m.id)!)
            }
            else {
                ABMultiValueAddValueAndLabel(abMultivalue, m.value, m.label, nil)
            }
        }
        
        for i in identifiers {
            ABMultiValueRemoveValueAndLabelAtIndex(abMultivalue, ABMultiValueGetIndexForIdentifier(abMultivalue,Int32(i)))
        }
        
        ABRecordSetValue(internalRecord, key, abMultivalue, nil)
    }
    
    private func setMultivalueDictionaryProperty<T,U, V : AnyObject,W : AnyObject where V : Hashable >(key : ABPropertyID,_ multivalue : Array<MultivalueEntry<Dictionary<T,U>>>?,keyConverter : (T) -> V , valueConverter : (U)-> W) {
        
        let array = convertMultivalueEntries(multivalue, converter: { d -> NSDictionary in
            return self.convertDictionary(d, keyConverter: keyConverter, valueConverter: valueConverter)!
        })
        
        setMultivalueProperty(key, array)
    }
}
//MARK: swift structs for convenience

enum SwiftAddressBookOrdering {
    
    case lastName, firstName
    
    init(ordering : ABPersonSortOrdering) {
        switch Int(ordering) {
        case kABPersonSortByLastName :
            self = .lastName
        case kABPersonSortByFirstName :
            self = .firstName
        default :
            self = .firstName
        }
    }
    
    var abPersonSortOrderingValue : UInt32 {
        get {
            switch self {
            case .lastName :
                return UInt32(kABPersonSortByLastName)
            case .firstName :
                return UInt32(kABPersonSortByFirstName)
            }
        }
    }
}

enum SwiftAddressBookCompositeNameFormat {
    case firstNameFirst, lastNameFirst
    
    init(format : ABPersonCompositeNameFormat) {
        switch Int(format) {
        case kABPersonCompositeNameFormatFirstNameFirst :
            self = .firstNameFirst
        case kABPersonCompositeNameFormatLastNameFirst :
            self = .lastNameFirst
        default :
            self = .firstNameFirst
        }
    }
}

enum SwiftAddressBookSourceType {
    case local, exchange, exchangeGAL, mobileMe, LDAP, cardDAV, cardDAVSearch
    
    init(abSourceType : ABSourceType) {
        switch Int(abSourceType) {
        case kABSourceTypeLocal :
            self = .local
        case kABSourceTypeExchange :
            self = .exchange
        case kABSourceTypeExchangeGAL :
            self = .exchangeGAL
        case kABSourceTypeMobileMe :
            self = .mobileMe
        case kABSourceTypeLDAP :
            self = .LDAP
        case kABSourceTypeCardDAV :
            self = .cardDAV
        case kABSourceTypeCardDAVSearch :
            self = .cardDAVSearch
        default :
            self = .local
        }
    }
}

enum SwiftAddressBookPersonImageFormat {
    case thumbnail
    case originalSize
    
    var abPersonImageFormat : ABPersonImageFormat {
        switch self {
        case .thumbnail :
            return kABPersonImageFormatThumbnail
        case .originalSize :
            return kABPersonImageFormatOriginalSize
        }
    }
}


enum SwiftAddressBookSocialProfileProperty {
    case url, service, username, userIdentifier
    
    init(property : String) {
        switch property {
        case kABPersonSocialProfileURLKey :
            self = .url
        case kABPersonSocialProfileServiceKey :
            self = .service
        case kABPersonSocialProfileUsernameKey :
            self = .username
        case kABPersonSocialProfileUserIdentifierKey :
            self = .userIdentifier
        default :
            self = .url
        }
    }
    
    var abSocialProfileProperty : String {
        switch self {
        case .url :
            return kABPersonSocialProfileURLKey
        case .service :
            return kABPersonSocialProfileServiceKey
        case .username :
            return kABPersonSocialProfileUsernameKey
        case .userIdentifier :
            return kABPersonSocialProfileUserIdentifierKey
        }
    }
}

enum SwiftAddressBookInstantMessagingProperty {
    case service, username
    
    init(property : String) {
        switch property {
        case kABPersonInstantMessageServiceKey :
            self = .service
        case kABPersonInstantMessageUsernameKey :
            self = .username
        default :
            self = .service
        }
    }
    
    var abInstantMessageProperty : String {
        switch self {
        case .service :
            return kABPersonInstantMessageServiceKey
        case .username :
            return kABPersonInstantMessageUsernameKey
        }
    }
}

enum SwiftAddressBookPersonType {
    
    case person, organization
    
    init(type : CFNumber?) {
        if CFNumberCompare(type, kABPersonKindPerson, nil) == CFComparisonResult.CompareEqualTo  {
            self = .person
        }
        else if CFNumberCompare(type, kABPersonKindOrganization, nil) == CFComparisonResult.CompareEqualTo{
            self = .organization
        }
        else {
            self = .person
        }
    }
    
    var abPersonType : CFNumber {
        get {
            switch self {
            case .person :
                return kABPersonKindPerson
            case .organization :
                return kABPersonKindOrganization
            }
        }
    }
}

enum SwiftAddressBookAddressProperty {
    case street, city, state, zip, country, countryCode
    
    init(property : String) {
        switch property {
        case kABPersonAddressStreetKey:
            self = .street
        case kABPersonAddressCityKey:
            self = .city
        case kABPersonAddressStateKey:
            self = .state
        case kABPersonAddressZIPKey:
            self = .zip
        case kABPersonAddressCountryKey:
            self = .country
        case kABPersonAddressCountryCodeKey:
            self = .countryCode
        default:
            self = .street
        }
    }
    
    var abAddressProperty : String {
        get {
            switch self {
            case .street :
                return kABPersonAddressStreetKey
            case .city :
                return kABPersonAddressCityKey
            case .state :
                return kABPersonAddressStateKey
            case .zip :
                return kABPersonAddressZIPKey
            case .country :
                return kABPersonAddressCountryKey
            case .countryCode :
                return kABPersonAddressCountryCodeKey
            default:
                return kABPersonAddressStreetKey
            }
        }
    }
}

struct MultivalueEntry<T> {
    var value : T
    var label : String
    let id : Int
}


//MARK: methods to convert arrays of ABRecords

private func convertRecordsToSources(records : [ABRecord]?) -> [SwiftAddressBookSource]? {
    let swiftRecords = records?.map {(record : ABRecord) -> SwiftAddressBookSource in return SwiftAddressBookRecord(record: record).convertToSource()!}
    return swiftRecords
}

private func convertRecordsToGroups(records : [ABRecord]?) -> [SwiftAddressBookGroup]? {
    let swiftRecords = records?.map {(record : ABRecord) -> SwiftAddressBookGroup in return SwiftAddressBookRecord(record: record).convertToGroup()!}
    return swiftRecords
}

private func convertRecordsToPersons(records : [ABRecord]?) -> [SwiftAddressBookPerson]? {
    let swiftRecords = records?.map {(record : ABRecord) -> SwiftAddressBookPerson in return SwiftAddressBookRecord(record: record).convertToPerson()!}
    return swiftRecords
}



//MARK: some more handy methods

extension NSString {
    convenience init?(string : String?) {
        if string == nil {
            self.init()
            return nil
        }
        self.init(string: string!)
    }
}

func errorIfNoSuccess(call : (UnsafeMutablePointer<Unmanaged<CFError>?>) -> Bool) -> CFError? {
    var err : Unmanaged<CFError>? = nil
    let success : Bool = call(&err)
    if success {
        return nil
    }
    else {
        return err?.takeRetainedValue()
    }
}
