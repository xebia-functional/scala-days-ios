/*
* Copyright (C) 2016 47 Degrees, LLC http://47deg.com hello@47deg.com
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

enum VoteType: Int {
    case unlike = 0
    case neutral = 1
    case like = 2
    
    func iconNameForVoteType() -> String {
        switch self {
        case .unlike: return "list_icon_vote_unlike.png"
        case .neutral: return "list_icon_vote_neutral.png"
        case .like: return "list_icon_vote_like.png"
        }
    }
}

class Vote: NSObject, Codable {
    let voteValue: Int
    let talkId: Int
    let conferenceId: Int
    let comments: String?
    
    init(_voteValue: Int, _talkId: Int, _conferenceId: Int, _comments: String?) {
        voteValue = _voteValue
        talkId = _talkId
        conferenceId = _conferenceId
        comments = _comments
    }
}
