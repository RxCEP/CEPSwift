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
            context("When merging two EventStreams") {
                let input1 = [(time: 205, event: IntEvent(value: 10)),
                              (time: 210, event: IntEvent(value: 20)),
                              (time: 225, event: IntEvent(value: 30)),
                              (time: 227, event: IntEvent(value: 30)),
                              (time: 228, event: IntEvent(value: 30))]
                let input2 = [(time: 206, event: StringEvent(value: "10")),
                              (time: 213, event: StringEvent(value: "20")),
                              (time: 220, event: StringEvent(value: "30")),
                              (time: 230, event: StringEvent(value: "40"))]
                
                let expectedOutput = [206, 213, 225, 230]
                
                func merge<T, K>(_ stream1: EventStream<T>,
                                 _ stream2: EventStream<K>) -> ComplexEvent {
                    return stream1.merge(with: stream2)
                }
                
                
                let simulator = ComplexEventSimulator()
                let output = simulator.simulate(with: input1,
                                                with: input2,
                                                handler: merge)
                
                it("Should output \(expectedOutput.count) elements") {
                    expect(output.count).to(equal(expectedOutput.count))
                }
                
                if output.count == expectedOutput.count {
                    it("Should output the expected events") {
                        zip(output, expectedOutput).forEach {
                            expect($0.0).to(equal($0.1))
                        }
                    }
                }
            }
        }
    }
}


