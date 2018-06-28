//
//  NumericalEvent.swift
//  thesis
//
//  Created by dev on 6/21/18.
//  Copyright © 2018 Dev. All rights reserved.
//

public protocol NumericEvent: Numeric, Event {
    static func / (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    var numericValue: Int { get set }
}
