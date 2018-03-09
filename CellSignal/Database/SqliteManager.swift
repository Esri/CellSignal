//
//  SqliteManager.swift
//  CellSignal
//
//  Created by Al Pascual on 1/22/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class SqliteManager: NSObject, DatabaseManagerProtocol {
    
    public var viewController: ViewController? = nil
    let tableName = "Observation"
    
    enum status: String {
        case new = "new"
        case sent = "sent"
    }

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let modelURL = Bundle.main.url(forResource: "SignalObservation", withExtension:"momd") else {
            print("Error loading model from bundle")
            return nil
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            //fatalError("Error initializing mom from: \(modelURL)")
            if let viewController = viewController {
                CustomNotification.show(parent: viewController, title: "Sqlite Error", description: "Error initializing object from: \(modelURL)")
            }
            
            return nil
        }
        
        return NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
        do {
            if let persistentStoreCoordinator = persistentStoreCoordinator {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            }
        } catch {
            print("Error migrating store: \(error)")
        }
        
        return context
    }()
    
    override init() {
        
        super.init()
    }
    
    func createNewObservation() -> Observation {
        let entity = NSEntityDescription.insertNewObject(forEntityName: tableName, into: managedObjectContext) as! Observation
        return entity
    }
    
    public func addObservation(newObservation: SignalObservation) -> Observation? {
        
        let observation = createNewObservation()
        observation.latitude = newObservation.coordinates.latitude.description
        observation.longitude = newObservation.coordinates.longitude.description
        observation.observationDate = newObservation.when
        observation.signal = Double(newObservation.signalStrength)
        observation.status = status.new.rawValue
        observation.altitude = newObservation.altitude
        
        do {
            try managedObjectContext.save()
            return observation
        } catch {
            //fatalError("Failure to save context: \(error)")
            if let viewController = viewController {
                CustomNotification.show(parent: viewController, title: "Failed adding to Sqlite", description: "Failed adding feature  \(error.localizedDescription)")
            }
        }
        
        return nil
    }
    
    public func convertToSignalObservation(observation: Observation) -> SignalObservation? {
        
        if let latitude = observation.latitude, let longitude = observation.longitude {
            let locationCoordinate = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
            let altitude = observation.altitude
            return SignalObservation(coordinates: locationCoordinate, signalStrength: Int(observation.signal), altitude: altitude)
        }
        
        return nil
    }
    
    public func updateObservation(databaseObservation: Observation) {
        
        // Forces the update, should find a better way.
        databaseObservation.setValue(databaseObservation.status, forKey: "status")
        
        do {
            try managedObjectContext.save()
        } catch {
            //fatalError("Failure to save context: \(error)")
            print("error saving feature \(error.localizedDescription)")
            if let viewController = viewController {
                CustomNotification.show(parent: viewController, title: "Failed updating Sqlite", description: "Failed updating feature  \(error.localizedDescription)")
            }
        }
    }
    
    public func fetchObservationsCount() -> Int {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableName)
        do {
            let observations = try managedObjectContext.fetch(fetchRequest) as! [Observation]
            return observations.count
        } catch {
            return 0
        }        
    }
    
    public func fetchUnsentObservations() -> [Observation]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableName)
        let predicate = NSPredicate(format: "status == %@", argumentArray: [status.new.rawValue])
        fetchRequest.predicate = predicate
        do {
            let observations = try managedObjectContext.fetch(fetchRequest) as! [Observation]
            return observations
        } catch {
            return nil
        }
    }
    
    public func deleteAllSent() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableName)
        let predicate = NSPredicate(format: "status == %@", argumentArray: [status.sent.rawValue])
        fetchRequest.predicate = predicate
        
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            let _ = try managedObjectContext.execute(batchDelete)
        } catch {
            //fatalError("Failed to execute request: \(error)")
            
            if let viewController = viewController {
                CustomNotification.show(parent: viewController, title: "Failed deleting Sqlite", description: "Failed deleting feature  \(error.localizedDescription)")
            }
        }
    }
    
    public func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableName)
        let predicate = NSPredicate(format: "1=1")
        fetchRequest.predicate = predicate
        
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            let _ = try managedObjectContext.execute(batchDelete)
        } catch {
            //fatalError("Failed to execute request: \(error)")
            
            if let viewController = viewController {
                CustomNotification.show(parent: viewController, title: "Failed deleting Sqlite", description: "Failed deleting feature  \(error.localizedDescription)")
            }
        }
    }
}
