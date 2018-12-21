//
//  StringEvent.swift
//  CEPSwift_Example
//
//  Created by George Guedes on 30/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import CEPSwift

class StringEvent: Event, Equatable {
    var timestamp: Date
    var value: String
    
    init(value: String) {
        self.timestamp = Date()
        self.value = value
    }
    
    static func ==(lhs: StringEvent, rhs: StringEvent) -> Bool {
        return lhs.value == rhs.value
    }
}
