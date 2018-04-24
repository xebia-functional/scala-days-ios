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
let kTwitterBaseAppURL = "twitter://status?id="
let kTwitterBaseAppURLUser = "twitter://user?screen_name="

enum SDSocialErrors: Int {
    case noError
    case accountAccessNotGranted
    case noTwitterAccountAvailable
    case noValidDataFromAPI
    case invalidRequest
}

class SDSocialHandler: NSObject {
    typealias SDGetTweetsHandler = (Array<AnyObject>?, NSError?) -> Void

    let errorDomain = "SDSocialHandler.scala-days"
    let accountStore = ACAccountStore()

    // MARK: - Composing tweets

    func showTweetComposerWithTweetText(_ tweetText: String!, onViewController: UIViewController!) -> SDSocialErrors {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let twitterSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet?.setInitialText(tweetText)
            onViewController.present(twitterSheet!, animated: true, completion: nil)
        } else {
            return .noTwitterAccountAvailable
        }
        return .noError
    }

    // MARK: - Retrieving tweets

    fileprivate func defaultTwitterAccount() -> ACAccount? {
        let accounts = accountStore.accounts(with: accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter))
        if ((accounts?.count)! > 0) {
            return accounts?[0] as? ACAccount
        }
        return nil
    }

    func requestTweetListWithHashtag(_ hashtag: String, count: Int, completionHandler: SDGetTweetsHandler!) {
        let encodedHashtag = hashtag.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        if let hashtag = encodedHashtag {
            let urlString = "https://api.twitter.com/1.1/search/tweets.json?q=\(hashtag)&count=\(count)"
            let queryUrl = URL(string: urlString)
            let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)

            accountStore.requestAccessToAccounts(with: accountType, options: nil) {
                granted, error in
                if (!granted) {
                    completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.accountAccessNotGranted.rawValue, userInfo: nil))
                    return
                }

                let twitterAccount = self.defaultTwitterAccount()
                switch (twitterAccount, queryUrl) {
                case let (account, url):
                    let postRequest: SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, url: url, parameters: nil)
                    postRequest.account = account
                    postRequest.perform(handler: {
                        (responseData, urlResponse, error) -> Void in
                        var parseError: NSError? = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: nil)
                        if let data = responseData {
                            
                            let tweetsData: Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with: responseData!, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary
                            
                            if let tweets = tweetsData {
                                let statuses = tweets[kTweetDKStatuses] as? Array<Dictionary<String, AnyObject>>
                                if let unwrappedTweets = statuses {
                                    completionHandler(self.processedListOfTweets(unwrappedTweets), nil)
                                } else {
                                    completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.noValidDataFromAPI.rawValue, userInfo: nil))
                                }
                            } else {
                                completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.noValidDataFromAPI.rawValue, userInfo: nil))
                            }
                        } else {
                            completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.noValidDataFromAPI.rawValue, userInfo: nil))
                        }
                    })
                case let (nil, _):
                    completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.noTwitterAccountAvailable.rawValue, userInfo: nil))
                default:
                    completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.invalidRequest.rawValue, userInfo: nil))
                }
            }
        } else {
            completionHandler(nil, NSError(domain: self.errorDomain, code: SDSocialErrors.invalidRequest.rawValue, userInfo: nil))
        }
    }

    // MARK: - Modelling tweets

    func processedListOfTweets(_ tweetData: Array<Dictionary<String, AnyObject>>) -> Array<SDTweet> {
        var results: Array<SDTweet> = []

        for unprocessedTweet in tweetData {
            let userData = unprocessedTweet[kTweetDKUser] as? Dictionary<String, AnyObject>
            if let user = userData {
                switch (user[kTweetDKName],
                        user[kTweetDKProfileImage],
                        user[kTweetDKScreenName],
                        unprocessedTweet[kTweetDKText],
                        unprocessedTweet[kTweetDKCreatedAt],
                        unprocessedTweet[kTweetDKID]) {
                case let (.some(name),
                          .some(profileImage),
                          .some(screenName),
                          .some(tweetText),
                          .some(tweetDate),
                          .some(tweetId)):
                    results.append(SDTweet(username: (screenName as! String),
                            fullName: (name as! String),
                            tweetText: (tweetText as! String),
                            profileImage: (profileImage as! String),
                            dateString: (tweetDate as! String),
                            id: (tweetId as! String)))
                default:
                    break
                }
            }
        }
        return results
    }

    // MARK: - Tweet detail URL creation

    class func urlForTweetDetail(_ tweet: SDTweet) -> URL? {
        return URL(string: (((kTwitterBaseURL as NSString).appendingPathComponent(tweet.username) as NSString)
        .appendingPathComponent(kTweetDKStatus) as NSString)
        .appendingPathComponent(tweet.id))
    }

    class func urlAppForTweetDetail(_ tweet: SDTweet) -> URL? {
        return URL(string: kTwitterBaseAppURL + tweet.id)
    }

    class func urlForTwitterAccount(_ twitterAccount: String) -> URL? {
        return URL(string: (kTwitterBaseURL as NSString).appendingPathComponent(twitterAccount))
    }

    class func urlAppForTwitterAccount(_ twitterAccount: String) -> URL? {
        return URL(string: (kTwitterBaseAppURLUser as NSString).appendingPathComponent(twitterAccount))
    }
}
