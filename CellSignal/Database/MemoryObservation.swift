//
//  MemoryObservation.swift
//  CellSignal
//
//  Created by Al Pascual on 2/2/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

import UIKit
import CoreLocation

public class MemoryObservation: NSObject {
    
    enum statusMemory: String {
        case new = "new"
        case sent = "sent"
        case sending = "sending"
    }
    
    var uniqueID: String
    var latitude: Double
    var longitude: Double
    var signalStrength: Int
    var when: Date
    var altitude: Double
    var status: String
    
    init(latitude: Double, longitude: Double, signalStrength: Int, when: Date, altitude: Double, status: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.signalStrength = signalStrength
        self.when = when
        self.altitude = altitude
        self.status = status
        self.uniqueID = UUID().uuidString
    }
}

private let sharedMemoryObservationManager = MemoryObservationManager()
public class MemoryObservationManager {
    
    public static var shared: MemoryObservationManager {
        return sharedMemoryObservationManager
    }
    private var memoryObservations = [MemoryObservation]()
    
    // DatabaseManagerProtocol
    func addObservation(newObservation: SignalObservation) -> MemoryObservation? {
        let memoryObs = MemoryObservation(latitude: newObservation.coordinates.latitude, longitude: newObservation.coordinates.longitude, signalStrength: newObservation.signalStrength, when: newObservation.when, altitude: newObservation.altitude, status: MemoryObservation.statusMemory.new.rawValue)
        
        // Check for duplicates
        let repeated = memoryObservations.filter {  $0.altitude == memoryObs.altitude &&
                                                    $0.latitude == memoryObs.latitude &&
                                                    $0.longitude == memoryObs.longitude &&
                                                    $0.signalStrength == memoryObs.signalStrength
        }
        
        // Unique
        if repeated.count == 0 {
            memoryObservations.append(memoryObs)
        }
        return memoryObs
    }
    
    func findObservation(altitude: Double, latitude: String?, longitude: String?, signalStrength: Double, when: Date, status: String ) -> MemoryObservation? {
        
        if let latitude = latitude, let longitude = longitude {
            if let latitude = Double(latitude), let longitude = Double(longitude) {
                let memory = memoryObservations.filter { $0.altitude == altitude &&
                    $0.latitude == latitude &&
                    $0.longitude == longitude &&
                    $0.signalStrength == Int(signalStrength) &&
                    $0.when == when  }
                
                if let first = memory.first {
                    var statusEnum = MemoryObservation.statusMemory.new
                    switch status {
                    case "sent":
                        statusEnum = MemoryObservation.statusMemory.sent
                        break
                        
                    default:
                        statusEnum = MemoryObservation.statusMemory.sending
                        break
                    }
                    first.status = statusEnum.rawValue
                    return first
                }
            }
        }
        
        return nil
    }
    
    func updateObservation(databaseObservation: MemoryObservation) {
        let toUpdate = memoryObservations.filter { $0.uniqueID == databaseObservation.uniqueID }
        
        if let first = toUpdate.first {
            first.status = databaseObservation.status
        }
    }
    
    func fetchUnsentObservations() -> [MemoryObservation]? {
        
        return memoryObservations.filter { $0.status == MemoryObservation.statusMemory.new.rawValue }
    }
    
    func deleteAllSent() {
        memoryObservations = memoryObservations.filter { $0.status != MemoryObservation.statusMemory.sent.rawValue }
    }
    
    func deleteAll() {
        memoryObservations = [MemoryObservation]()
    }
    
    func convertMemoryObservationToObservation(memoryObservation: MemoryObservation, databaseManager: SqliteManager) -> Observation {
        let observation = databaseManager.createNewObservation()
        observation.altitude = memoryObservation.altitude
        observation.latitude = "\(memoryObservation.latitude)"
        observation.longitude = "\(memoryObservation.longitude)"
        observation.observationDate = memoryObservation.when
        observation.signal = Double(memoryObservation.signalStrength)
        observation.status = memoryObservation.status
        return observation
    }
    
    func convertMemoryToSignalObservation(observation: MemoryObservation) -> SignalObservation? {
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: observation.latitude, longitude: observation.longitude)
        let altitude = observation.altitude
        
        return SignalObservation(coordinates: locationCoordinate, signalStrength: observation.signalStrength, altitude: altitude)
    }
}

