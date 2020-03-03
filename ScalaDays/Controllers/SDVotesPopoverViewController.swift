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

protocol SDVotesPopoverViewControllerDelegate: class {
    func didSelectVoteValue(_ voteType: VoteType)
}

class SDVotesPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var lblTalkTitle: UILabel!
    
    private let analytics: Analytics
    weak var delegate: SDVotesPopoverViewControllerDelegate?
    
    init(analytics: Analytics, delegate: SDVotesPopoverViewControllerDelegate) {
        self.analytics = analytics
        self.delegate = delegate
        super.init(nibName: String(describing: SDVotesPopoverViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.logScreenName(.votes, class: SDVotesPopoverViewController.self)
    }
    
    @IBAction func didVoteLike(_ sender: AnyObject) {
        self.sendVoteElection(VoteType.like)
    }
    
    @IBAction func didVoteNeutral(_ sender: AnyObject) {
        self.sendVoteElection(VoteType.neutral)
    }
    
    @IBAction func didVoteDontLike(_ sender: AnyObject) {
        self.sendVoteElection(VoteType.unlike)
    }
    
    func sendVoteElection(_ vote: VoteType) {
        delegate?.didSelectVoteValue(vote)
        self.dismiss(animated: true, completion: nil)
    }
}
