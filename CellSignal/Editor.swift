//
//  Editor.swift
//  CellSignal
//
//  Created by Al Pascual on 1/22/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

import UIKit
import ArcGIS

class Editor: NSObject {

    let serviceFeature: AGSServiceFeatureTable?
    var lastVersion = -1
    let username: String
    let password: String
    
    init(urlString: String, username: String, password: String) {
        
        self.username = username
        self.password = password
        
        if let url = URL(string: urlString) {
            serviceFeature = AGSServiceFeatureTable(url: url)
            serviceFeature?.credential = AGSCredential(user: username, password: password)
            
        } else {
            serviceFeature = nil
        }
    }
    
    // Only use with a feature service with X,Y,Z attributes: "text"
    public func addObservationToFeatureService(signalObservation: SignalObservation, counter: String, completion: @escaping (_ success:Bool) -> Void) {
        
        //Discart first one
        if counter == "0" {
            completion(true)
            return
        }
        
        // Discard repeats
        if lastVersion == Int(counter)! {
            completion(true)
            return
        }
        
        lastVersion = Int(counter)!
        
        if let serviceFeature = serviceFeature {
            
            serviceFeature.load(completion: { error in
                
                if let error = error {
                    print("Error loading layer: \(error.localizedDescription)")
                    completion(false)
                    return
                }
            
                let wgs84Point = AGSPoint(x: signalObservation.coordinates.longitude, y: signalObservation.coordinates.latitude, z: signalObservation.altitude, spatialReference: AGSSpatialReference.wgs84())
                
                let attributes = [
                                    "signal": signalObservation.signalStrength,
                                    "datetime": signalObservation.when,
                                    "osname": DeviceInformation.OSName,
                                    "osversion": DeviceInformation.OSVersion,
                                    "phonemodel": DeviceInformation.PhoneModel,
                                    "deviceid": DeviceInformation.deviceID,
                                    "carrierid": DeviceInformation.CarrierID
                    ] as [String : Any]
               
                let feature = serviceFeature.createFeature(attributes: attributes, geometry: wgs84Point)
                
                guard let arcgisFeature = feature as? AGSArcGISFeature else {
                    completion(false)
                    return
                }
                
                //print("Feature Adding \(counter)")
                serviceFeature.add(arcgisFeature, completion: { error in
                    if let error = error {
                        print("Error while adding feature :: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    //print("Feature Added \(counter)")                    
                    serviceFeature.applyEdits(completion: { results, error in
                        if let error = error {
                            print("Error while saving feature :: \(error.localizedDescription)")
                            completion(false)
                            return
                        }
                        
                        //print("Feature Saved!")
                        completion(true)
                    })
                })
            })
        }
    }
}
