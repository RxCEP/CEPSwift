// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import CEPSwift
import RxSwift
import RxTest

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("Operators tests") {
            it("Filters") {
                
                let testData = [
                    (time: 201, event: IntEvent(value: 210)),
                    (time: 215, event: IntEvent(value: 251)),
                    (time: 218, event: IntEvent(value: 10)),
                    (time: 220, event: IntEvent(value: 5)),
                    (time: 230, event: IntEvent(value: 15)),
                    (time: 500, event: IntEvent(value: 10)),
                    (time: 600, event: IntEvent(value: 500))
                ]
                
                let expectedData = [
                    (time: 201, event: IntEvent(value: 210)),
                    (time: 218, event: IntEvent(value: 10)),
                    (time: 500, event: IntEvent(value: 10)),
                    (time: 600, event: IntEvent(value: 500))
                ]
                
                let simulator = EventStreamSimulator<IntEvent>()
                let results = simulator.simulate(with: testData, handler: { (stream) -> EventStream<IntEvent> in
                    return stream.filter(predicate: { (event) -> Bool in
                        return event.value % 2 == 0
                    })
                })
                
                for (index, result) in results.enumerated() {
                    expect(result.time).to(equal(expectedData[index].time))
                    expect(result.event).to(equal(expectedData[index].event))
                }
            }
            
            it("Intersects") {
                let testData1 = [
                    (time: 201, event: IntEvent(value: 1)),
                    (time: 202, event: IntEvent(value: 2)),
                    (time: 203, event: IntEvent(value: 4)),
                    (time: 204, event: IntEvent(value: 8)),
                    (time: 205, event: IntEvent(value: 16)),
                    (time: 206, event: IntEvent(value: 32)),
                    (time: 207, event: IntEvent(value: 64))
                ]
                
                let testData2 = [
                    (time: 299, event: IntEvent(value: 0)),
                    (time: 300, event: IntEvent(value: 32)),
                    (time: 300, event: IntEvent(value: 99)),
                    (time: 301, event: IntEvent(value: 8)),
                    (time: 302, event: IntEvent(value: 1)),
                    (time: 302, event: IntEvent(value: 100)),
                    ]
                
                let expectedData = [
                    (time: 300, event: IntEvent(value: 32)),
                    (time: 301, event: IntEvent(value: 8)),
                    (time: 302, event: IntEvent(value: 1)),
                    ]
                
                let simulator = EventStreamSimulator<IntEvent>()
                let results = simulator.simulate(with: testData1,
                                                 with: testData2,
                                                 handler: { (stream1, stream2) -> EventStream<IntEvent> in
                                                    return stream1.intersect(with: stream2)
                                                    
                })
                
                for (index, result) in results.enumerated() {
                    expect(result.time).to(equal(expectedData[index].time))
                    expect(result.event).to(equal(expectedData[index].event))
                }
            }
            
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
            
            it("Can map") {
                let manager = EventManager<IntEvent>()
                let originalEvents = [0, 1, 2, 3, 4, 5]
                var events = [Int]()
                
                manager.stream.map(transform: {$0.value * 10}).subscribe(onNext: { (value) in
                    events.append(value)
                })
                
                for i in originalEvents {
                    manager.addEvent(event: IntEvent(value: i))
                }
                
                expect(events).toEventually(equal(originalEvents.map({$0 * 10})))
            }
            
            it("Can merge") {
                let intManager = EventManager<IntEvent>()
                let stringManager = EventManager<StringEvent>()
                var counter = 0
                
                intManager.stream.merge(with: stringManager.stream).subscribe {
                    counter += 1
                }
                
                intManager.addEvent(event: IntEvent(value: 1))
                stringManager.addEvent(event: StringEvent(value: "Nice"))
                
                expect(counter).toEventually(equal(1))
            }
        }
    }
}

