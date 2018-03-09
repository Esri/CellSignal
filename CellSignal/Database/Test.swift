//
//  Test.swift
//  CellSignal
//
//  Created by Al Pascual on 2/2/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

import UIKit
import CoreLocation

class Test: NSObject {

//    func test() {
//        
//        let databaseManager = SqliteManager()
//        
//        if let databaseObservations = databaseManager.fetchUnsentObservations() {
//            
//            for obs in databaseObservations {
//                
//                if let signalObs = databaseManager.convertToSignalObservation(observation: obs) {
//                    MemoryObservationManager.shared.addObservation(newObservation: signalObs)
//                }
//            }
//            
//            databaseManager.deleteAll()
//        }
//        
//        for num in [1,2,3,4,5,6,7] {
//            let signal = SignalObservation(coordinates: CLLocationCoordinate2D(latitude: 20, longitude: 30), signalStrength: num, altitude: 2)
//            _ = MemoryObservationManager.shared.addObservation(newObservation: signal)
//        }
//        
//        print( MemoryObservationManager.shared.fetchUnsentObservations()?.count)
//        
//        if let first = MemoryObservationManager.shared.fetchUnsentObservations()?.first {
//            MemoryObservationManager.shared.updateObservation(databaseObservation: first)
//            MemoryObservationManager.shared.deleteAllSent()
//            print( MemoryObservationManager.shared.fetchUnsentObservations()?.count)
//            
//            
//            
//        }
//        
//        if let observationsMemory = MemoryObservationManager.shared.fetchUnsentObservations() {
//            for obs in observationsMemory {
//
//                let coordinates = CLLocationCoordinate2D(latitude: obs.latitude, longitude: obs.longitude)
//                let singalObservation = SignalObservation(coordinates: coordinates, signalStrength: obs.signalStrength, altitude: obs.altitude)
//                databaseManager.addObservation(newObservation: singalObservation)
//            }
//        }
//        
//        print("end test \(databaseManager.fetchUnsentObservations()?.count)")
//    }
}
