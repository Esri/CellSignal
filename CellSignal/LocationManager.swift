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
import CoreLocation

class LocationManager: NSObject {

    var locationManager: CLLocationManager
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }
    
    public func setup(distanceFilter:Double) {
        
        // Start Location Manager and Motion
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.distanceFilter = distanceFilter
            locationManager.startUpdatingLocation()
        }
    }
}
