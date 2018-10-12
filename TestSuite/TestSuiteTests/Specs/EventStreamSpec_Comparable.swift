// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import CEPSwift
import RxSwift
import RxTest

class EventStreamSpecComparable: QuickSpec {
    override func spec() {
        describe("EventStream") {
            mappingTest()
            filterTest()
            intersectTest()
            
            
            it("Calculates max") {
                let manager = EventManager<IntEvent>()
                let numberOfEvents = 5
                var maxValue = 0
                manager.stream.max(onNext: { (event) in
                    maxValue = event!.value
                })
                
                for i in 0..<numberOfEvents {
                    manager.addEvent(event: IntEvent(value: numberOfEvents - i))
                }
                
                expect(maxValue).toEventually(equal(numberOfEvents))
            }
            
            it("Calculates min") {
                let manager = EventManager<IntEvent>()
                let numberOfEvents = 5
                var maxValue = 0
                manager.stream.min(onNext: { (event) in
                    maxValue = event!.value
                })
                
                for i in 0..<numberOfEvents {
                    manager.addEvent(event: IntEvent(value: i))
                }
                
                expect(maxValue).toEventually(equal(0))
            }
            
            it("Group by window") {
                let manager = EventManager<IntEvent>()
                let events = [0, 1, 2, 3, 4, 5]
                var eventsValues = [Int]()
                
                manager.stream.window(ofTime: 50, max: events.count).subscribe(onNext: { (events) in
                    eventsValues = events.map({$0.value})
                })
                
                for i in events {
                    manager.addEvent(event: IntEvent(value: i))
                }
                expect(eventsValues).toEventually(equal(events))
            }
            
            it("Can check followedBy") {
                let manager = EventManager<IntEvent>()
                let numberOfEvents = 5
                var counter = 0
                
                manager.stream.followedBy(predicate: { (fst, snd) -> Bool in
                    fst.value < snd.value
                }).subscribe(onNext: { (event) in
                    counter += 1
                })
                
                for i in 1...numberOfEvents {
                    manager.addEvent(event: IntEvent(value: i))
                }
                
                expect(counter).toEventually(equal(numberOfEvents - 1))
            }
        }
    }
    
    private func mappingTest() {
        context("When mapping a EventStream") {
            let input = [
                (time: 201, event: IntEvent(value: 210)),
                (time: 215, event: IntEvent(value: 251)),
                (time: 218, event: IntEvent(value: 10)),
                (time: 220, event: IntEvent(value: 5)),
                (time: 230, event: IntEvent(value: 15)),
                (time: 500, event: IntEvent(value: 10)),
                (time: 600, event: IntEvent(value: 500))
            ]
            
            let expectedOutput = [
                (time: 201, event: IntEvent(value: 215)),
                (time: 215, event: IntEvent(value: 256)),
                (time: 218, event: IntEvent(value: 15)),
                (time: 220, event: IntEvent(value: 10)),
                (time: 230, event: IntEvent(value: 20)),
                (time: 500, event: IntEvent(value: 15)),
                (time: 600, event: IntEvent(value: 505))
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
                (time: 201, event: IntEvent(value: 210)),
                (time: 215, event: IntEvent(value: 251)),
                (time: 218, event: IntEvent(value: 10)),
                (time: 220, event: IntEvent(value: 5)),
                (time: 230, event: IntEvent(value: 15)),
                (time: 500, event: IntEvent(value: 10)),
                (time: 600, event: IntEvent(value: 500))
            ]
            
            let expectedOutput = [
                (time: 201, event: IntEvent(value: 210)),
                (time: 218, event: IntEvent(value: 10)),
                (time: 500, event: IntEvent(value: 10)),
                (time: 600, event: IntEvent(value: 500))
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
            
            it("Should ouput the expected events") {
                for (idx, elem) in expectedOutput.enumerated() {
                    let outputElem = output[idx]
                    
                    expect(outputElem.time).to(equal(elem.time))
                    expect(outputElem.event).to(equal(elem.event))
                }
            }
        }
    }
    private func intersectTest() {
        context ("When intersecting two EventStreams") {
            let input1 = [
                (time: 201, event: IntEvent(value: 1)),
                (time: 202, event: IntEvent(value: 2)),
                (time: 203, event: IntEvent(value: 4)),
                (time: 204, event: IntEvent(value: 8)),
                (time: 205, event: IntEvent(value: 16)),
                (time: 206, event: IntEvent(value: 32)),
                (time: 207, event: IntEvent(value: 64))
            ]
            
            let input2 = [
                (time: 299, event: IntEvent(value: 0)),
                (time: 300, event: IntEvent(value: 32)),
                (time: 300, event: IntEvent(value: 99)),
                (time: 301, event: IntEvent(value: 8)),
                (time: 302, event: IntEvent(value: 1)),
                (time: 302, event: IntEvent(value: 100)),
                ]
            
            let expectedOutput = [
                (time: 300, event: IntEvent(value: 32)),
                (time: 301, event: IntEvent(value: 8)),
                (time: 302, event: IntEvent(value: 1)),
                ]
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input1,
                                             with: input2,
                                             handler: { (stream1, stream2) -> EventStream<IntEvent> in
                                                return stream1.intersect(with: stream2)
                                                
            })
            
            it("Should output \(expectedOutput.count) elements") {
                expect(output.count).to(equal(expectedOutput.count))
            }
            
            it("Should output the expected elements)") {
                for (index, elem) in expectedOutput.enumerated() {
                    let outputElem = output[index]
                    
                    expect(outputElem.time).to(equal(elem.time))
                    expect(outputElem.event).to(equal(elem.event))
                }
            }
        }
    }
}

