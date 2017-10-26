//
//  LocationEvent.swift
//  CEPSwift_Example
//
//  Created by George Guedes on 25/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import CEPSwift
import CoreLocation
import Foundation

class LocationEvent: Event, Comparable {
    var timestamp: Date
    var data: CLLocation
    
    init(data: CLLocation) {
        self.timestamp = data.timestamp
        self.data = data
    }
    
    static func ==(lhs: LocationEvent, rhs: LocationEvent) -> Bool {
        return lhs.data.speed == rhs.data.speed
    }
    
    static func <(lhs: LocationEvent, rhs: LocationEvent) -> Bool {
        return lhs.data.speed < rhs.data.speed
    }
}
