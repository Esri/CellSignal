// Copyright 2018 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ArcGIS

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let portal = AGSPortal(url: URL(string: UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.Portal)!)!, loginRequired: false)

        portal.credential = AGSCredential(user: UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.Username)!, password: UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.Password)!)
        let portalItem = AGSPortalItem(portal: portal, itemID: UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.WebMap)!)
        mapView.map = AGSMap(item: portalItem)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
