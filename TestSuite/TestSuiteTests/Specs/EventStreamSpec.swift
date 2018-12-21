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
            windowTest()
            followedByTest()
            mappingTest()
            filterTest()
            groupedByTest()
        }
    }
    
    private func windowTest() {
        context("When applying a window over a EventStream") {
            let input = [
                (time: 1, event: IntEvent(value: 0)),
                (time: 2, event: IntEvent(value: 1)),
                (time: 5, event: IntEvent(value: 2)),
                (time: 5, event: IntEvent(value: 3)),
                (time: 5, event: IntEvent(value: 4)),
                (time: 5, event: IntEvent(value: 5)),
                (time: 6, event: IntEvent(value: 3)),
                ]
            
            let expectedOutput = [(time: 2, event: [IntEvent(value: 3),
                                                    IntEvent(value: 1)]),
                                  (time: 5, event: [IntEvent(value: 2),
                                                    IntEvent(value: 3),
                                                    IntEvent(value: 4)]),
                                  (time: 6, event: [IntEvent(value: 5),
                                                    IntEvent(value: 3)])]
            
            func window(_ stream: EventStream<IntEvent>) -> EventStream<[IntEvent]> {
                let resultStream = stream.window(ofTime: 2, max: 3)
                
                return resultStream
            }
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input,
                                            handler: window)
            
            it("Should output \(expectedOutput.count) elements") {
                expect(output.count).to(equal(expectedOutput.count))
            }
            
            it("Should output the expected events") {
                zip(output, expectedOutput).forEach {
                    expect($0.0.time).to(equal($0.1.time))
                    expect($0.0.event).to(equal($0.1.event))
                }
            }
        }
    }
    
    private func followedByTest() {
        context("When filtering tuples of increasing value") {
            let input = [
                (time: 1, event: IntEvent(value: 0)),
                (time: 2, event: IntEvent(value: 1)),
                (time: 5, event: IntEvent(value: 2)),
                (time: 5, event: IntEvent(value: 1)),
                (time: 5, event: IntEvent(value: 3)),
                (time: 5, event: IntEvent(value: 4)),
                (time: 5, event: IntEvent(value: 5)),
                (time: 6, event: IntEvent(value: 3)),
                ]
            let expectedOutput = [
                (time: 2, event: (IntEvent(value: 0), IntEvent(value: 1))),
                (time: 5, event: (IntEvent(value: 1), IntEvent(value: 2))),
                (time: 5, event: (IntEvent(value: 1), IntEvent(value: 3))),
                (time: 5, event: (IntEvent(value: 3), IntEvent(value: 4))),
                (time: 5, event: (IntEvent(value: 4),IntEvent(value: 5))),
                ]
            
            func followedBy(_ stream: EventStream<IntEvent>) -> EventStream<(IntEvent, IntEvent)> {
                return stream.followedBy { $0.value < $1.value }
            }
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input, handler: followedBy)
            
            it("Should output \(expectedOutput.count) elements") {
                expect(output.count).to(equal(expectedOutput.count))
            }
            
            it("Should output the expected events") {
                zip(output, expectedOutput).forEach {
                    expect($0.0.time).to(equal($0.1.time))
                    expect($0.0.event.0).to(equal($0.1.event.0))
                    expect($0.0.event.1).to(equal($0.1.event.1))
                }
            }
            
        }
    }
    private func mapping2() {
        context("Can map") {
            let manager = EventManager<IntEvent>()
            let originalEvents = [0, 1, 2, 3].map(IntEvent.init)
            let expectedEvents = [0, 10, 20, 30].map(IntEvent.init)
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
                (time: 1, event: IntEvent(value: 0)),
                (time: 3, event: IntEvent(value: 1)),
                (time: 5, event: IntEvent(value: 2)),
                (time: 5, event: IntEvent(value: 3)),
            ]
            
            let expectedOutput = [
                (time: 1, event: IntEvent(value: 0)),
                (time: 3, event: IntEvent(value: 10)),
                (time: 5, event: IntEvent(value: 20)),
                (time: 5, event: IntEvent(value: 30)),
            ]
            
            func mapTimesTen(_ stream: EventStream<IntEvent>) -> EventStream<IntEvent> {
                let resultStream = stream.map { IntEvent(value: $0.value * 10) }
                
                return resultStream
            }
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input,
                                            handler: mapTimesTen)
            
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
        context("When filtering even events") {
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
            
            func filterEven(_ stream: EventStream<IntEvent>) -> EventStream<IntEvent> {
                let resultStream = stream.filter { $0.value % 2 == 0 }
                
                return resultStream
            }
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input,
                                            handler: filterEven)
            
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
    
    private func groupedByTest() {
        context("When grouping even and odd events") {
            let input = [
                (time: 1, event: IntEvent(value: 0)),
                (time: 3, event: IntEvent(value: 1)),
                (time: 5, event: IntEvent(value: 2)),
                (time: 5, event: IntEvent(value: 3)),
                ]
            
            let expectedOutput = [
                (time: 1, event: [true: [IntEvent(value: 0)]]),
                (time: 3, event: [true: [IntEvent(value: 0)],
                                  false: [IntEvent(value: 1)]]),
                (time: 5, event: [true: [IntEvent(value: 0),
                                         IntEvent(value: 2)],
                                  false: [IntEvent(value: 1)]]),
                (time: 5, event: [true: [IntEvent(value: 0),
                                         IntEvent(value: 2)],
                                  false: [IntEvent(value: 1),
                                          IntEvent(value: 3)]]),
            ]
            
            func groupedByEvenOrNot(stream: EventStream<IntEvent>) -> EventStream<[Bool: [IntEvent]]> {
                return stream.group { $0.value % 2 == 0}
            }
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input,
                                            handler: groupedByEvenOrNot)
            
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
