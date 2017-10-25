//
//  PedometerEvent.swift
//  CEPSwift_Example
//
//  Created by George Guedes on 25/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import CEPSwift
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
        return lhs.data.numberOfSteps.intValue < rhs.data.numberOfSteps.intValue
    }
    
    static func ==(lhs: PedometerEvent, rhs: PedometerEvent) -> Bool {
        return lhs.data.numberOfSteps == rhs.data.numberOfSteps
    }
}
