/*
 * Copyright (C) 2018 47 Degrees, LLC http://47deg.com hello@47deg.com
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

import XCTest

private enum Constants {
    static let voteValue = 2
    static let talkId = 1
    static let conferenceId = 3
    static let comments = "Test"
}

class VoteTests: XCTestCase {
    private let vote = Vote(_voteValue: Constants.voteValue,
                            _talkId: Constants.talkId,
                            _conferenceId: Constants.conferenceId,
                            _comments: Constants.comments)
    
    func testStoreAndRetrieveVotes() {
        let storedVotes = ["key": vote]
        StoringHelper.sharedInstance.storeVotesData(storedVotes)
        let loadedVotes: [String: Vote] = StoringHelper.sharedInstance.loadVotesData()!
        
        XCTAssertEqual(storedVotes["key"]?.voteValue, loadedVotes["key"]?.voteValue)
        XCTAssertEqual(storedVotes["key"]?.talkId, loadedVotes["key"]?.talkId)
        XCTAssertEqual(storedVotes["key"]?.conferenceId, loadedVotes["key"]?.conferenceId)
        XCTAssertEqual(storedVotes["key"]?.comments, loadedVotes["key"]?.comments)
    }
}
