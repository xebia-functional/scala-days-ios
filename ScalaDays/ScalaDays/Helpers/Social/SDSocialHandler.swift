//
//  SDSocialHandler.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 04/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import Foundation
import Social
import Accounts

// MARK: Tweet dictionary keys

let kTweetDKText = "text"
let kTweetDKUser = "user"
let kTweetDKName = "name"
let kTweetDKScreenName = "screen_name"
let kTweetDKProfileImage = "profile_image_url"
let kTweetDKStatuses = "statuses"
let kTweetDKCreatedAt = "created_at"

let kTwitterDateFormat = "EEE MMM d HH:mm:ss Z y"

enum SDSocialErrors : Int {
    case NoError
    case AccountAccessNotGranted
    case NoTwitterAccountAvailable
    case NoValidDataFromAPI
    case InvalidRequest
}

class SDSocialHandler: NSObject {
    typealias SDGetTweetsHandler = (Array<AnyObject>?, NSError?) -> Void
    
    let errorDomain = "SDSocialHandler.scala-days"
    let accountStore = ACAccountStore()
    lazy var dateFormatter = NSDateFormatter()
    
    // MARK: - Composing tweets
    
    func showTweetComposerWithTweetText(tweetText: String!, onViewController: UIViewController!) -> SDSocialErrors {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let twitterSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText(tweetText)
            onViewController.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            return .NoTwitterAccountAvailable
        }
        return .NoError
    }
    
    // MARK: - Retrieving tweets
    
    private func defaultTwitterAccount() -> ACAccount? {
        let accounts = accountStore.accountsWithAccountType(accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter))
        if(accounts.count > 0) {
            return accounts[0] as? ACAccount
        }
        return nil
    }
    
    func requestTweetListWithHashtag(hashtag: String, count: Int, completionHandler: SDGetTweetsHandler!) {
        let encodedHashtag = hashtag.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        if let hashtag = encodedHashtag {
            let urlString = "https://api.twitter.com/1.1/search/tweets.json?q=\(hashtag)&count=\(count)"
            let queryUrl = NSURL(string: urlString)
            let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            
            accountStore.requestAccessToAccountsWithType(accountType, options: nil) { granted, error in
                if(!granted) {
                    completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.AccountAccessNotGranted.rawValue, userInfo: nil))
                    return
                }
                
                let twitterAccount = self.defaultTwitterAccount()
                switch(twitterAccount, queryUrl) {
                case let (account, url) :
                    var postRequest: SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
                    postRequest.account = account
                    postRequest.performRequestWithHandler({ (responseData, urlResponse, error) -> Void in
                        var parseError: NSError? = NSError()
                        let testString = NSString(data: responseData, encoding: NSUTF8StringEncoding)
                        let tweetsData: Dictionary<String, AnyObject>? = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as? Dictionary
                        
                        if let tweets = tweetsData {
                            let statuses = tweets[kTweetDKStatuses] as? Array<Dictionary<String, AnyObject>>
                            if let unwrappedTweets = statuses {
                                completionHandler(self.processedListOfTweets(unwrappedTweets), nil)
                            } else {
                                completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.NoValidDataFromAPI.rawValue, userInfo: nil))
                            }
                        } else {
                            completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.NoValidDataFromAPI.rawValue, userInfo: nil))
                        }
                    })                    
                case let (nil, url):
                    completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.NoTwitterAccountAvailable.rawValue, userInfo: nil))
                    
                default:
                    completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.InvalidRequest.rawValue, userInfo: nil))
                }
            }
        } else {
            completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.InvalidRequest.rawValue, userInfo: nil))
        }
    }
    
    // MARK: - Modelling tweets
    
    func processedListOfTweets(tweetData: Array<Dictionary<String, AnyObject>>) -> Array<SDTweet> {
        var results : Array<SDTweet> = []
        
        for unprocessedTweet in tweetData {
            let userData = unprocessedTweet[kTweetDKUser] as? Dictionary<String, AnyObject>
            if let user = userData {
                switch(user[kTweetDKName],
                        user[kTweetDKProfileImage],
                        user[kTweetDKScreenName],
                        unprocessedTweet[kTweetDKText],
                        unprocessedTweet[kTweetDKCreatedAt]) {
                case let(.Some(name),
                         .Some(profileImage),
                         .Some(screenName),
                         .Some(tweetText),
                         .Some(tweetDate)):
                            results.append(SDTweet(username: (screenName as String),
                                                   fullName: (name as String),
                                                   tweetText: (tweetText as String),
                                                   profileImage: (profileImage as String),
                                                   dateString: (tweetDate as String)))
                default:
                    break
                }
            }
        }
        return results
    }
    
    // MARK: Tweet date handling
    
    func parseTwitterDate(twitterDate: String) -> NSDate? {
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = kTwitterDateFormat
        return dateFormatter.dateFromString(twitterDate)
    }
}
