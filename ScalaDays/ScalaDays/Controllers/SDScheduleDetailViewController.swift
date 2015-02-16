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

class SDScheduleDetailViewController: UIViewController {


    @IBOutlet weak var titleSection: UILabel!
    @IBOutlet weak var lblDateSection: UILabel!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

    @IBOutlet weak var lblSpeakers: UILabel!
    @IBOutlet weak var viewSpeaker: UIView!

    var event: Event?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let eventCurrent = event {

            if let arraySpeaker = eventCurrent.speakers? {
                if (arraySpeaker.count < 1) {
                    viewSpeaker.hidden = true
                }
            }
            titleSection.text = eventCurrent.title
            lblDateSection.text = eventCurrent.date
            lblRoom.text = ""
            lblDescription.text = eventCurrent.apiDescription
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
