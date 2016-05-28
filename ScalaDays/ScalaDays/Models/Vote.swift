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
    case Unlike = 0
    case Neutral = 1
    case Like = 2
    
    func iconNameForVoteType() -> String {
        switch self {
        case Unlike: return "list_icon_vote_unlike.png"
        case Neutral: return "list_icon_vote_neutral.png"
        case Like: return "list_icon_vote_like.png"
        }
    }
}

class Vote : NSObject, NSCoding {
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
    
    required init?(coder aDecoder: NSCoder) {
        self.voteValue = aDecoder.decodeObjectForKey("voteValue") as! Int
        self.talkId = aDecoder.decodeObjectForKey("talkId") as! Int
        self.conferenceId = aDecoder.decodeObjectForKey("conferenceId") as! Int
        self.comments = aDecoder.decodeObjectForKey("comments") as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.voteValue, forKey: "voteValue")
        aCoder.encodeObject(self.talkId, forKey: "talkId")
        aCoder.encodeObject(self.conferenceId, forKey: "conferenceId")
        aCoder.encodeObject(self.comments, forKey: "comments")
    }
}