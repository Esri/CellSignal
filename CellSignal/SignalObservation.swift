//
//  SignalObservation.swift
//  CellSignal
//
//  Created by Al Pascual on 1/19/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

import UIKit
import CoreLocation

class SignalObservation: NSObject {

    var coordinates: CLLocationCoordinate2D
    var signalStrength: Int
    var when: Date
    var altitude: Double
    
    init(coordinates: CLLocationCoordinate2D, signalStrength: Int, altitude: Double) {
        self.coordinates = coordinates
        self.signalStrength = signalStrength
        self.when = Date()
        self.altitude = altitude
    }
}
