//
//  ComplexEventSpec.swift
//  TestSuiteTests
//
//  Created by Filipe Jordão on 27/10/18.
//  Copyright © 2018 Filipe Jordão. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import CEPSwift

class ComplexEventSpec: QuickSpec {
    override func spec() {
        describe("ComplexEvent") {
            context("") {
                let simulator = ComplexEventSimulator()
                let input1 = [(time: 205, event: IntEvent(value: 10)),
                              (time: 210, event: IntEvent(value: 20)),
                              (time: 225, event: IntEvent(value: 30))]
                let input2 = [(time: 213, event: StringEvent(value: "20")),
                              (time: 220, event: StringEvent(value: "30"))]
                
                let output = simulator.simulate(with: input1, with: input2, handler: { (es1, es2) -> ComplexEvent in
                    
                    return es1.merge(with: es2)
                })
            }
        }
    }
}
