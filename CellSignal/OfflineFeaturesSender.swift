//
//  OfflineFeaturesSender.swift
//  CellSignal
//
//  Created by Al Pascual on 1/31/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

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
