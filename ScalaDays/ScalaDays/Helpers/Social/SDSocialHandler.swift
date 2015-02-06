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
let kTweetDKStatus = "status"
let kTweetDKID = "id_str"
let kTwitterBaseURL = "http://www.twitter.com/"

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
                        unprocessedTweet[kTweetDKCreatedAt],
                        unprocessedTweet[kTweetDKID]) {
                case let(.Some(name),
                         .Some(profileImage),
                         .Some(screenName),
                         .Some(tweetText),
                         .Some(tweetDate),
                         .Some(tweetId)):
                            results.append(SDTweet(username: (screenName as String),
                                                   fullName: (name as String),
                                                   tweetText: (tweetText as String),
                                                   profileImage: (profileImage as String),
                                                   dateString: (tweetDate as String),
                                                   id: (tweetId as String)))
                default:
                    break
                }
            }
        }
        return results
    }
    
    // MARK: - Tweet detail URL creation
    
    class func urlForTweetDetail(tweet: SDTweet) -> NSURL? {
        return NSURL(string: kTwitterBaseURL.stringByAppendingPathComponent(tweet.username)
                                            .stringByAppendingPathComponent(kTweetDKStatus)
                                            .stringByAppendingPathComponent(tweet.id))
    }
    
    class func urlForTwitterAccount(twitterAccount: String) -> NSURL? {
        return NSURL(string: kTwitterBaseURL.stringByAppendingPathComponent(twitterAccount))
    }
}
