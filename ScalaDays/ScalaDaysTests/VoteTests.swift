//
//  VoteTests.swift
//  ScalaDaysTests
//
//  Created by Juan Cazalla Estrella on 16/05/2018.
//  Copyright © 2018 47 Degrees. All rights reserved.
//

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
