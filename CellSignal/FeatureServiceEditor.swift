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

import ArcGIS
import CoreData

enum TrackingServiceSaveError: Error {
    case saveIsInProgress
}

class FeatureServiceEditor: NSObject {
    
    let tracksTable: AGSServiceFeatureTable
    private var saveOperation: SaveOperation?
    
    var isSaving: Bool {
        return saveOperation != nil
    }
    
    struct ObservationsFields {
        static let signal = "signal"
        static let datetime = "datetime"
        static let osname = "osname"
        static let osversion = "osversion"
        static let phonemodel = "phonemodel"
        static let deviceid = "deviceid"
        static let carrierid = "carrierid"
    }
    
    init(tracksUrl: URL, username: String, password: String) {
        tracksTable = AGSServiceFeatureTable(url: tracksUrl)
        tracksTable.credential = AGSCredential(user: username, password: password)
        
        let config = AGSRequestConfiguration.global()
        config.timeoutInterval = 300
        tracksTable.requestConfiguration = config
    }
    
    deinit {
        if let saveOperation = saveOperation {
            saveOperation.cancel()
        }
    }
    
    func save(observations: [SignalObservation], username: String, completion: (([AGSFeatureEditResult]?, [Error]?) -> Void)? = nil) {
        guard !isSaving else {
            completion?(nil, [TrackingServiceSaveError.saveIsInProgress])
            return
        }
        
        AGSAuthenticationManager.shared().delegate = self
        saveOperation = SaveOperation(maxSavePointCount: 500, tracksTable: tracksTable, observations: observations, username: username) { [weak self] features, errors in
            self?.saveOperation = nil
            completion?(features, errors)
        }
    }
    
    private func load(observation: SignalObservation, completion: ((AGSFeature?, Error?) -> Void)?) {
        //AGSAuthenticationManager.shared().delegate = self
        
        tracksTable.load { error in
            if error != nil {
                completion?(nil, error)
                return
            }
            
            var attributes = [String:Any]()
            attributes[ObservationsFields.carrierid] = DeviceInformation.CarrierID
            attributes[ObservationsFields.datetime] = Date()
            attributes[ObservationsFields.deviceid] = DeviceInformation.deviceID
            attributes[ObservationsFields.osname] = DeviceInformation.OSName
            attributes[ObservationsFields.osversion] = DeviceInformation.OSVersion
            attributes[ObservationsFields.phonemodel] = DeviceInformation.PhoneModel
            attributes[ObservationsFields.signal] = observation.signalStrength
            
            let feature = self.tracksTable.createFeature(attributes: attributes, geometry: AGSPoint(x: observation.coordinates.longitude, y: observation.coordinates.latitude, z: observation.altitude, spatialReference: AGSSpatialReference.wgs84()))
            self.tracksTable.add(feature) { error in
                completion?(feature, error)
            }
        }
    }
    
    func save(observation: SignalObservation, completion: ((Error?) -> Void)? = nil) {
        load(observation: observation) { feature, error in
            guard let feature = feature else {
                completion?(error)
                return
            }
            
            self.tracksTable.applyEdits { result, error in
                completion?(error)
            }
        }
    }
}

extension FeatureServiceEditor: AGSAuthenticationManagerDelegate {
    func authenticationManager(_ authenticationManager: AGSAuthenticationManager, didReceive challenge: AGSAuthenticationChallenge) {
        if challenge.type == .untrustedHost {
            challenge.trustHostAndContinue()
        } else {
            challenge.continueWithDefaultHandling()
        }
    }
}

private class SaveOperation {
    private let tracksTable: AGSServiceFeatureTable
    private let applyEditsDispatchGroup = DispatchGroup()
    private var operations = [WeakContainer<AGSCancelable>]()
    private var results = [AGSFeatureEditResult]()
    private var errors = [Error]()
    private let maxSavePointCount: Int
    private let completion: ([AGSFeatureEditResult]?, [Error]?) -> Void
    private let username: String
    private let chunksOfTrackPoints: [[SignalObservation]]
    
    init(maxSavePointCount: Int, tracksTable: AGSServiceFeatureTable, observations: [SignalObservation], username: String, completion: @escaping ([AGSFeatureEditResult]?, [Error]?) -> Void) {
        self.maxSavePointCount = maxSavePointCount
        self.tracksTable = tracksTable
        self.username = username
        self.completion = completion
        chunksOfTrackPoints = observations.chunk(maxSavePointCount)
        tracksTable.load { [weak self] error in
            if let error = error {
                completion(nil, [error])
                return
            }
            self?.save(chunkIndex: 0)
        }
    }
    
    func cancel() {
        for weakContainer in operations {
            weakContainer.value?.cancel()
        }
    }
    
    // Create features, add the feature to the table and call
    // tracksTable.applyEdits() before adding any more features.
    // saveFeatures will call the completion after applyEdits
    // is called (but does not wait for it to complete).
    // Once all chunks have called applyEdits then wait for the
    // applyEditsDispatchGroup to be notified that all requests are done
    //
    private func save(chunkIndex: Int) {
        let features = SaveOperation.createFeatures(fromTrackPoints: chunksOfTrackPoints[chunkIndex], tracksTable: tracksTable, username: username)
        let addOperation = tracksTable.add(features) { [weak self] error in
            guard let mySelf = self else {
                return
            }
            if let error = error {
                mySelf.errors.append(error)
            } else {
                mySelf.applyEdits()
            }
            let nextChunkIndex = chunkIndex + 1
            if nextChunkIndex < mySelf.chunksOfTrackPoints.count {
                mySelf.save(chunkIndex: nextChunkIndex)
            } else {
                mySelf.waitForAllApplyEdits()
            }
        }
        operations.append(WeakContainer(addOperation))
    }
    
    private func waitForAllApplyEdits() {
        applyEditsDispatchGroup.notify(queue: .main) { [weak self] in
            guard let mySelf = self else {
                return
            }
            mySelf.operations.removeAll()
            mySelf.completion(mySelf.results, mySelf.errors.isEmpty ? nil : mySelf.errors)
        }
    }
    
    private func applyEdits() {
        applyEditsDispatchGroup.enter()
        let applyEditsOperation = tracksTable.applyEdits() { [weak self] editResult, error in
            guard let mySelf = self else {
                return
            }
            if let error = error {
                mySelf.errors.append(error)
            }
            if let editResult = editResult {
                mySelf.results.append(contentsOf: editResult)
            }
            mySelf.applyEditsDispatchGroup.leave()
        }
        operations.append(WeakContainer(applyEditsOperation))
    }
    
    private static func createFeatures(fromTrackPoints trackPoints: [SignalObservation], tracksTable: AGSServiceFeatureTable, username: String) -> [AGSFeature] {
        return trackPoints.map { trackPoint in
            let point = AGSPoint(x: trackPoint.coordinates.longitude, y: trackPoint.coordinates.latitude, z: trackPoint.altitude, spatialReference: AGSSpatialReference.wgs84())
            
            var attributes = [String:Any]()
            attributes[FeatureServiceEditor.ObservationsFields.carrierid] = DeviceInformation.CarrierID
            attributes[FeatureServiceEditor.ObservationsFields.datetime] = Date()
            attributes[FeatureServiceEditor.ObservationsFields.deviceid] = DeviceInformation.deviceID
            attributes[FeatureServiceEditor.ObservationsFields.osname] = DeviceInformation.OSName
            attributes[FeatureServiceEditor.ObservationsFields.osversion] = DeviceInformation.OSVersion
            attributes[FeatureServiceEditor.ObservationsFields.phonemodel] = DeviceInformation.PhoneModel
            attributes[FeatureServiceEditor.ObservationsFields.signal] = trackPoint.signalStrength
            
            let feature = tracksTable.createFeature(attributes: attributes, geometry: point)
            return feature
        }
    }
}

// For creating collections (arrays, dictionaries) where
// the contained object must have a weak reference
//
public class WeakContainer<T: AnyObject> {
    
    weak var value: T?
    
    init (_ value: T) {
        
        self.value = value
    }
}

extension Array {
    func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key: Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
    
    func chunk(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: chunkSize).map { chunkIndex in
            let end = endIndex
            let chunkEnd = index(chunkIndex, offsetBy: chunkSize, limitedBy: end) ?? end
            return Array(self[chunkIndex..<chunkEnd])
        }
    }
}

extension ViewController {
    
    func uploadIfNecessary() {
        if isUploading {
            return
        }
        
        if let previous = lastUploadTime, Date().timeIntervalSince(previous) < uploadTimeInterval {
            return
        }
        
        lastUploadTime = Date()
        uploadLocationAndTracks()
    }
    
    func uploadLocationAndTracks(completion: ((Error?) -> Void)? = nil) {
        
        let unsent = databaseManager.fetchUnsentObservations()
        if let first = unsent?.first {
            upload(observation: first) { error in
                completion?(error)
            }
        }
    }
    
    //    private func uploadTracks(completion: ((Error?) -> Void)? = nil) {
    //
    //        guard let trackingService = trackingService, !trackingService.isSaving else {
    //            completion?(nil)
    //            return
    //        }
    //
    //        let start = Date()
    //
    //        isUploading = true
    //        trackingService.save(observations: trackPoints) { results, error in
    //            guard let results = results else {
    //                self.isUploading = false
    //                Log.shared.write("Failed to upload tracks")
    //                completion?(error?.first)
    //                return
    //            }
    //
    //            let uploaded = results.filter { !$0.completedWithErrors }
    //            Log.shared.write("Uploaded \(uploaded.count) features (\(start.elapsedTimeAsString()))")
    //
    //            var succeeded: [TrackPoint] = []
    //            for i in 0..<trackPoints.count {
    //                if !results[i].completedWithErrors {
    //                    succeeded.append(trackPoints[i])
    //                }
    //            }
    //            self.trackingStore.markAsUploaded(trackPoints: succeeded)
    //            self.isUploading = false
    //            completion?(results.first(where: { $0.completedWithErrors})?.error)
    //        }
    //    }
    
    func upload(observation: Any , completion: ((Error?) -> Void)? = nil) {
        guard let trackingService = trackingService  else {
            return
        }
        
        if let databaseObservation = observation as? Observation {
        
            isUploading = true
            if let signalObservation = databaseManager.convertToSignalObservation(observation: databaseObservation) {
                trackingService.save(observation: signalObservation) { error in
                    self.isUploading = false
                    completion?(error)
                }
            } else {
                completion?(nil)
            }
        } else if let memoryObservation = observation as? MemoryObservation {
            isUploading = true
            if let signalObservation = databaseManager.convertToSignalObservation(observation: memoryObservation) {
                trackingService.save(observation: signalObservation) { error in
                    self.isUploading = false
                    completion?(error)
                }
            } else {
                completion?(nil)
            }
        }
        
        completion?(nil)
    }
    
    // ---------------
}

