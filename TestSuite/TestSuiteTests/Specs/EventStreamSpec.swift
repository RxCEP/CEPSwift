//
//  EventStreamSpec.swift
//  TestSuiteTests
//
//  Created by Filipe Jordão on 21/10/18.
//  Copyright © 2018 Filipe Jordão. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import CEPSwift

class EventStreamSpec: QuickSpec {
    override func spec() {
        describe("EventStream") {
            
            mapping2()
            //mappingTest()
            //filterTest()
        }
    }
    
    private func mapping2() {
        it("Can map") {
            
            
            let manager = EventManager<IntEvent>()
            let originalEvents = [0, 1, 2, 3, 4, 5].map(IntEvent.init)
            let expectedEvents = [0, 10, 20, 30, 40, 50].map(IntEvent.init)
            var events = [IntEvent]()
            
            manager.stream
                .map(transform: { IntEvent(value: $0.value * 10) })
                .subscribe(onNext: { event in
                    events.append(event)
                })
            
            originalEvents.forEach(manager.addEvent)
            
            it("Should output \(events.count) events") {
                expect(events.count).toEventually(equal(expectedEvents.count))
            }
            
            it("Should output the expected events") {
                expect(events).toEventually(equal(expectedEvents))
            }
        }
    }
    
    private func mappingTest() {
        context("When mapping a EventStream") {
            let input = [
                (time: 1, event: IntEvent(value: 210)),
                (time: 3, event: IntEvent(value: 251)),
                (time: 5, event: IntEvent(value: 10)),
                (time: 8, event: IntEvent(value: 6)),
            ]
            
            let expectedOutput = [
                (time: 1, event: IntEvent(value: 215)),
                (time: 3, event: IntEvent(value: 256)),
                (time: 5, event: IntEvent(value: 15)),
                (time: 8, event: IntEvent(value: 11)),
            ]
            
            let output = EventStreamSimulator()
                .simulate(with: input) { (stream: EventStream<IntEvent>) in
                    return stream.map(transform: { event -> IntEvent in
                        return IntEvent(value: event.value + 5)
                    })
            }
            
            it("Should output \(expectedOutput.count) events") {
                expect(output.count).to(equal(expectedOutput.count))
            }
            
            it("Should output the expected events") {
                for (idx, elem) in expectedOutput.enumerated() {
                    let outputElem = output[idx]
                    
                    expect(outputElem.time).to(equal(elem.time))
                    expect(outputElem.event).to(equal(elem.event))
                }
            }
        }
    }
    
    private func filterTest() {
        context("When filtering a EventStream") {
            let input = [
                (time: 1, event: IntEvent(value: 210)),
                (time: 2, event: IntEvent(value: 251)),
                (time: 4, event: IntEvent(value: 10)),
                (time: 5, event: IntEvent(value: 5)),
                (time: 5, event: IntEvent(value: 15)),
                (time: 8, event: IntEvent(value: 10)),
                (time: 8, event: IntEvent(value: 500))
            ]
            
            let expectedOutput = [
                (time: 1, event: IntEvent(value: 210)),
                (time: 4, event: IntEvent(value: 10)),
                (time: 8, event: IntEvent(value: 10)),
                (time: 8, event: IntEvent(value: 500))
            ]
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input, handler: { (stream) -> EventStream<IntEvent> in
                return stream.filter(predicate: { (event) -> Bool in
                    return event.value % 2 == 0
                })
            })
            
            it("Should output \(expectedOutput.count) elements") {
                expect(output.count).to(equal(expectedOutput.count))
            }
            
            it("Should output the expected events") {
                for (idx, elem) in expectedOutput.enumerated() {
                    let outputElem = output[idx]
                    
                    expect(outputElem.time).to(equal(elem.time))
                    expect(outputElem.event).to(equal(elem.event))
                }
            }
        }
    }
}

func == <T:Equatable, K:Equatable> (tuple1:(T,K),tuple2:(T,K)) -> Bool
{
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}

