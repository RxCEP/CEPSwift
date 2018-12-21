//
//  NumericEvent.swift
//  CEPSwift
//
//  Created by Hélmiton Júnior on 6/21/18.
//  Copyright © 2018 CEPSwift. All rights reserved.
//

public protocol NumericEvent: Numeric, Event {
    static func / (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    var numericValue: Int { get set }
}