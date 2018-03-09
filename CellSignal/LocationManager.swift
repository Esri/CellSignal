//
//  LocationManager.swift
//  CellSignal
//
//  Created by Al Pascual on 1/22/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

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
