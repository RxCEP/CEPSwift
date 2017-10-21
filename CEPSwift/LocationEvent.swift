//
//  LocationEvent.swift
//  CEPSwift
//
//  Created by George Guedes on 10/10/17.
//  Copyright © 2017 CEPSwift. All rights reserved.
//

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
