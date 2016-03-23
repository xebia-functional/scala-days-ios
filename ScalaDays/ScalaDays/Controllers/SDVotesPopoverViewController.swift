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

import UIKit

protocol SDVotesPopoverViewControllerDelegate {
    func didSelectVoteValue(voteType: VoteType)
}

class SDVotesPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    var delegate: SDVotesPopoverViewControllerDelegate?
    
    convenience init(delegate d: SDVotesPopoverViewControllerDelegate) {
        self.init()
        delegate = d        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func didVoteLike(sender: AnyObject) {
        self.sendVoteElection(VoteType.Like)
    }
    
    @IBAction func didVoteNeutral(sender: AnyObject) {
        self.sendVoteElection(VoteType.Neutral)
    }
    
    @IBAction func didVoteDontLike(sender: AnyObject) {
        self.sendVoteElection(VoteType.Unlike)
    }
    
    func sendVoteElection(vote: VoteType) {
        delegate?.didSelectVoteValue(vote)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
