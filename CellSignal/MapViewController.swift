//
//  MapViewController.swift
//  CellSignal
//
//  Created by Al Pascual on 2/7/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

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
