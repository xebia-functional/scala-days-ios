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

#import "SDContactCreationHelper.h"
#import <AddressBook/AddressBook.h>

@implementation SDContactCreationHelper

+ (void)createContactInAddressBookFromVCardString:(NSString *)vCardString completion:(SDContactCreationHelperCompletionHandler)completion {
    CFDataRef vCardData = (__bridge CFDataRef)[vCardString dataUsingEncoding:NSUTF8StringEncoding];
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
    CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
    if (vCardPeople != nil && CFArrayGetCount(vCardPeople) > 0) {
        ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, 0);
        if (ABAddressBookAddRecord(book, person, NULL) && ABAddressBookSave(book, NULL)) {
            completion(SDContactCreationHelperErrorNoError);
            return;
        } else {
            completion(SDContactCreationHelperErrorUnknown);
            return;
        }
    } else {
        completion(SDContactCreationHelperErrorInvalidVCardData);
        return;
    }
}

+ (NSString *)contactNameFromABRecord:(ABRecordRef)person {
    NSString *name = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *nameToReturn = nil;
    if(name != nil && lastName != nil) {
        nameToReturn = [NSString stringWithFormat:@"%@ %@", name, lastName];
    } else if(name != nil) {
        nameToReturn = name;
    } else if(lastName != nil){
        nameToReturn = lastName;
    }
    return nameToReturn;
}

+ (NSString *)contactNameFromVCardString:(NSString *)vCardString {
    CFDataRef vCardData = (__bridge CFDataRef)[vCardString dataUsingEncoding:NSUTF8StringEncoding];
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
    CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
    if (vCardPeople != nil && CFArrayGetCount(vCardPeople) > 0) {
        ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, 0);
        return [SDContactCreationHelper contactNameFromABRecord:person];
    }
    return nil;
}

@end
