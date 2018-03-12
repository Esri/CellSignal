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

class UnsentFeaturesManager: NSObject {

    lazy var databaseManager = {
        return SqliteManager()
    }()
    
    var viewController: UIViewController?
    var bLoaded = false
    
    override init() {
    }
    
    public func LoadOfflineFeatures() {
        
        if bLoaded {
            return
        }
        bLoaded = true
        
        MemoryObservationManager.shared.deleteAll()
        
        if let databaseObservations = databaseManager.fetchUnsentObservations() {
            
            for obs in databaseObservations {
                
                if let signalObs = databaseManager.convertToSignalObservation(observation: obs) {
                    _ = MemoryObservationManager.shared.addObservation(newObservation: signalObs)
                }
            }
            
            databaseManager.deleteAll()
        }
    }
    
    public func SaveOfflineFeatures() {
        
        bLoaded = false
        
        // Delete everything so we don't have duplicates
        if let count = databaseManager.fetchUnsentObservations()?.count {
            if count > 0 {
                databaseManager.deleteAll()
            }
        }
        
        if let observationsMemory = MemoryObservationManager.shared.fetchUnsentObservations() {
            for obs in observationsMemory {
                
                if let signalObservation = databaseManager.convertToSignalObservation(observation: MemoryObservationManager.shared.convertMemoryObservationToObservation(memoryObservation: obs, databaseManager: databaseManager)) {
                    
                    _ = databaseManager.addObservation(newObservation: signalObservation)
                }
            }
        }
        
        MemoryObservationManager.shared.deleteAll()
    }
    
    
    // databaseManager functions
    //
    public func fetchUnsentObservations() -> [MemoryObservation]? {
        let memoryObservations = MemoryObservationManager.shared.fetchUnsentObservations()
        return memoryObservations
    }
    
    public func convertToSignalObservation(observation: Any) -> SignalObservation? {
        
        if let observation = observation as? Observation {
            return databaseManager.convertToSignalObservation(observation: observation)
        } else if let observation = observation as? MemoryObservation {
            return MemoryObservationManager.shared.convertMemoryToSignalObservation(observation: observation)
        }
        
        return nil
    }
    
    public func deleteAllSent() {
        MemoryObservationManager.shared.deleteAllSent()
    }
    
    public func updateObservation(databaseObservation: Any) {
        
        if let databaseObservation = databaseObservation as? Observation {
            
            if let memoryObservation = MemoryObservationManager.shared.findObservation(altitude: databaseObservation.altitude, latitude: databaseObservation.latitude, longitude: databaseObservation.longitude, signalStrength: databaseObservation.signal, when: databaseObservation.observationDate!, status: databaseObservation.status!) {
                
                MemoryObservationManager.shared.updateObservation(databaseObservation: memoryObservation)
            }
        } else if let memoryObservation = databaseObservation as? MemoryObservation {
            MemoryObservationManager.shared.updateObservation(databaseObservation: memoryObservation)
        }
    }
    
    public func addObservation(newObservation: SignalObservation) -> Observation? {
        _ = MemoryObservationManager.shared.addObservation(newObservation: newObservation)
        // Don't need the return
        return nil
    }
}
