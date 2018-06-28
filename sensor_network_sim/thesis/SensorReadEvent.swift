//
//  TimeoutEvent.swift
//  thesis
//
//  Created by Hélmiton Júnior on 6/20/18.
//  Copyright © 2018 Hélmiton Júnior. All rights reserved.
//

import CEPSwift
import Foundation

final class SensorReadEvent: NumericEvent, Comparable {
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
    static func - (lhs: SensorReadEvent, rhs: SensorReadEvent) -> SensorReadEvent {
        return SensorReadEvent(date: lhs.timestamp, data: lhs.numericValue-rhs.numericValue)
    }
    static func + (lhs: SensorReadEvent, rhs: SensorReadEvent) -> SensorReadEvent {
        return SensorReadEvent(date: lhs.timestamp, data: lhs.numericValue+rhs.numericValue)
    }
    static func * (lhs: SensorReadEvent, rhs: SensorReadEvent) -> SensorReadEvent {
        return SensorReadEvent(date: lhs.timestamp, data: lhs.numericValue*rhs.numericValue)
    }
    static func *= (lhs: inout SensorReadEvent, rhs: SensorReadEvent) {
        lhs.numericValue = lhs.numericValue * rhs.numericValue
    }
    static func -= (lhs: inout SensorReadEvent, rhs: SensorReadEvent) {
        lhs.numericValue -= rhs.numericValue
    }
    static func += (lhs: inout SensorReadEvent, rhs: SensorReadEvent) {
        lhs.numericValue += rhs.numericValue
    }
    static func ==(lhs: SensorReadEvent, rhs: SensorReadEvent) -> Bool {
        return lhs.numericValue == rhs.numericValue
    }
    static func <(lhs: SensorReadEvent, rhs: SensorReadEvent) -> Bool {
        return lhs.numericValue < rhs.numericValue
    }
    static func / (lhs: SensorReadEvent, rhs: SensorReadEvent) -> SensorReadEvent {
        return SensorReadEvent(date: lhs.timestamp, data: lhs.numericValue/rhs.numericValue)
    }
    
}
