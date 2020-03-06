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
import TwitterKit

// MARK: Tweet dictionary keys

private let kTweetDKStatus = "status"
private let kTwitterBaseURL = "http://www.twitter.com/"
private let kTwitterBaseAppURL = "twitter://status?id="
private let kTwitterBaseAppURLUser = "twitter://user?screen_name="

enum SDGetTweetsError: Int {
    case invalidRequest
    case unknown
    case unauthorized
}

enum SDGetTweetsResult {
    case success(tweets: [SDTweet])
    case failure(error: SDGetTweetsError)
}

class SDSocialHandler {
    
    func fetchTweetList(withHashtag hashtag: String, count: Int, completion: @escaping (SDGetTweetsResult) -> Void) {
        guard let hashtag = hashtag.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            completion(.failure(error: .invalidRequest))
            return
        }

        let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID
        let apiClient = TWTRAPIClient(userID: userID)
        let searchTimelineDataSource = TWTRSearchTimelineDataSource(searchQuery: hashtag,
                                                                    apiClient: apiClient,
                                                                    languageCode: nil,
                                                                    maxTweetsPerRequest: UInt(max(count, 0)),
                                                                    resultType: nil)
        
        searchTimelineDataSource.loadPreviousTweets(beforePosition: nil) { (tweets, _, error) in
            if let tweets = tweets {
                completion(.success(tweets: tweets.map { $0.sdTweet() }))
            } else if let _ = error, let userId = userID {
                TWTRTwitter.sharedInstance().sessionStore.logOutUserID(userId)
                completion(.failure(error: .unauthorized))
            } else {
                completion(.failure(error: .unknown))
            }
        }
    }
}

// MARK: - Tweet detail URL creation

extension SDSocialHandler {
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
