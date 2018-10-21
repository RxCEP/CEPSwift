//
//  IntEvent.swift
//  CEPSwift_Tests
//
//  Created by George Guedes on 30/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import CEPSwift

class IntEvent: Event, Comparable, Equatable, CustomStringConvertible {
    var timestamp: Date
    var value: Int
    
    var description: String {
        get {
            return "IntEvent -> \(value)"
        }
    }
    
    init(value: Int) {
        self.timestamp = Date()
        self.value = value
    }
    
    static func <(lhs: IntEvent, rhs: IntEvent) -> Bool {
        return lhs.value < rhs.value
    }
    
    static func ==(lhs: IntEvent, rhs: IntEvent) -> Bool {
        return lhs.value == rhs.value
    }
}
