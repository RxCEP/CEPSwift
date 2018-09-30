//
//  TimeoutEvent.swift
//  thesis
//
//  Created by Hélmiton Júnior on 6/20/18.
//  Copyright © 2018 Hélmiton Júnior. All rights reserved.
//

import CEPSwift
import Foundation

final class TimeoutEvent: NumericEvent, Comparable {
    var magnitude = Int()
    typealias Magnitude = Int
    typealias IntegerLiteralType = Int
    
    var timestamp: Date
    var numericValue: Int
    
    init(date: Date, data: Int) {
        self.timestamp = date
        self.numericValue = data
    }
    
    required convenience init(integerLiteral value: Int) {
        self.init(date: Date(), data: value)
    }
    required convenience init?<T>(exactly source: T) where T : BinaryInteger {
        self.init(date: Date(), data: Int(source))
    }
    static func - (lhs: TimeoutEvent, rhs: TimeoutEvent) -> TimeoutEvent {
        return TimeoutEvent(date: lhs.timestamp, data: lhs.numericValue-rhs.numericValue)
    }
    static func + (lhs: TimeoutEvent, rhs: TimeoutEvent) -> TimeoutEvent {
        return TimeoutEvent(date: lhs.timestamp, data: lhs.numericValue+rhs.numericValue)
    }
    static func * (lhs: TimeoutEvent, rhs: TimeoutEvent) -> TimeoutEvent {
        return TimeoutEvent(date: lhs.timestamp, data: lhs.numericValue*rhs.numericValue)
    }
    static func *= (lhs: inout TimeoutEvent, rhs: TimeoutEvent) {
        lhs.numericValue = lhs.numericValue * rhs.numericValue
    }
    static func -= (lhs: inout TimeoutEvent, rhs: TimeoutEvent) {
        lhs.numericValue -= rhs.numericValue
    }
    static func += (lhs: inout TimeoutEvent, rhs: TimeoutEvent) {
        lhs.numericValue += rhs.numericValue
    }
    static func ==(lhs: TimeoutEvent, rhs: TimeoutEvent) -> Bool {
        return lhs.numericValue == rhs.numericValue
    }
    static func <(lhs: TimeoutEvent, rhs: TimeoutEvent) -> Bool {
        return lhs.numericValue < rhs.numericValue
    }
    static func / (lhs: TimeoutEvent, rhs: TimeoutEvent) -> TimeoutEvent {
        return TimeoutEvent(date: lhs.timestamp, data: lhs.numericValue/rhs.numericValue)
    }
    
}
