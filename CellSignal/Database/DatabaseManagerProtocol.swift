//
//  DatabaseManagerProtocol.swift
//  CellSignal
//
//  Created by Al Pascual on 2/2/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

import UIKit

protocol DatabaseManagerProtocol {
    func addObservation(newObservation: SignalObservation) -> Observation?
    func updateObservation(databaseObservation: Observation)
    func fetchUnsentObservations() -> [Observation]?
    func deleteAllSent()
}
