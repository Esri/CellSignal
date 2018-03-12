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
