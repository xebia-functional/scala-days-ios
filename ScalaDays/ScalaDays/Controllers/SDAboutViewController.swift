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

import UIKit

class SDAboutViewController: UIViewController {

    @IBOutlet weak var cnsLeftLabel: NSLayoutConstraint!
    @IBOutlet weak var cnsRightLabel: NSLayoutConstraint!
    @IBOutlet weak var lblCodeConduct: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    lazy var selectedConference : Conference? = DataManager.sharedInstance.currentlySelectedConference
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("about", comment: "About")
        self.lblCodeConduct.setCustomFont(UIFont.fontHelveticaNeueMedium(17), colorFont: UIColor.appRedColor())
        self.lblDescription.setCustomFont(UIFont.fontHelveticaNeueLight(15), colorFont: UIColor.appColor())
        loadCodeOfConductText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.lblDescription.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width
            - self.cnsLeftLabel.constant
            - self.cnsRightLabel.constant
        self.view.layoutIfNeeded()
    }

    func loadCodeOfConductText() {
        if let conference = selectedConference {
            self.lblDescription.text = conference.codeOfConduct
        }
    }

    @IBAction func didTapOn47Logo(sender: AnyObject) {
        launchSafariToUrl(NSURL(string: url47Website)!)
    }
}
