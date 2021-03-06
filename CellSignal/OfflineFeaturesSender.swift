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

class OfflineFeaturesSender: NSObject {

    let editor: Editor
    
    //let databaseManager: SqliteManager
    let databaseManager: UnsentFeaturesManager
    
    var sentCounter: Int
    var offlineTimer: Timer? = nil
    let sentLabel: UILabel
    let QueuedLabel: UILabel
    var finishHandler: (() -> Void)?
    
    init(editor: Editor, databaseManager: UnsentFeaturesManager, sentCounter: Int, sentLabel: UILabel, QueuedLabel: UILabel) {
        self.databaseManager = databaseManager
        self.editor = editor
        self.sentCounter = sentCounter
        self.sentLabel = sentLabel
        self.QueuedLabel = QueuedLabel
    }
    
    public func sendAll() {
        
        checkForOfflineFeatures()
    }
    
    @objc func checkForOfflineFeatures() {
        
        let unsent = databaseManager.fetchUnsentObservations()
        if let unsent = unsent {
            if let observation = unsent.first {
                if let signalObservation = databaseManager.convertToSignalObservation(observation: observation) {
                    
                    sendObservation(signalObservation: signalObservation, completion: { [weak self] (success) in
                        if success {
                            // Update the database only when is offline
                            
                            if let mySelf = self {
                                observation.status = "sent"
                                mySelf.databaseManager.updateObservation(databaseObservation: observation)
                                
                                // Update the counter
                                if let mySelf = self {
                                    mySelf.sentCounter = mySelf.sentCounter + 1
                                    mySelf.sentLabel.text = "\(mySelf.sentCounter) features stored online"
                                    //update the label for feature unsent
                                    mySelf.QueuedLabel.text = "\(unsent.count) features unsent"
                                }
                                
                                mySelf.databaseManager.deleteAllSent()
                                
                                mySelf.offlineTimer = Timer.scheduledTimer(timeInterval: 1, target: mySelf, selector: #selector(self?.checkForOfflineFeatures), userInfo: nil, repeats: false)
                            }
                            
                        } else {
                            
                            print("The request timed out, for offline features.")
                        }
                    })
                }
            }
         
            if unsent.count == 0 {
                stop()
            }
        } else {
            stop()
        }
    }
    
    private func stop() {
        offlineTimer?.invalidate()
        offlineTimer = nil
        finishHandler?()
    }
    
    func sendObservation(signalObservation: SignalObservation, completion: @escaping (_ success:Bool) -> Void) {
        
        editor.addObservationToFeatureService(signalObservation: signalObservation, counter: String(sentCounter), completion: { success in
            
            completion(success)
        })
    }
}
