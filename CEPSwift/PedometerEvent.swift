//
//  PedometerEvent.swift
//  CEPSwift
//
//  Created by George Guedes on 10/10/17.
//  Copyright © 2017 CEPSwift. All rights reserved.
//

import CoreMotion
import Foundation

class PedometerEvent: Event, Comparable {
    var timestamp: Date
    var data: CMPedometerData
    
    init(data: CMPedometerData) {
        self.timestamp = data.startDate
        self.data = data
    }
    
    static func <(lhs: PedometerEvent, rhs: PedometerEvent) -> Bool {
        return Int(lhs.data.numberOfSteps) < Int(rhs.data.numberOfSteps)
    }
    
    static func ==(lhs: PedometerEvent, rhs: PedometerEvent) -> Bool {
        return lhs.data.numberOfSteps == rhs.data.numberOfSteps
    }
}
