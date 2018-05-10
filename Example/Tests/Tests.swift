// https://github.com/Quick/Quick

import Quick
import Nimble
import CEPSwift

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("Operators tests") {
            
            it("Filters") {
                let manager = EventManager<IntEvent>()
                let numberOfEvents = 5
                var counter = 0
                manager.stream.filter(predicate: {$0.value%2 == 0}).subscribe(onNext: { (event) in
                    counter += 1
                })
                
                for i in 0..<numberOfEvents {
                    manager.addEvent(event: IntEvent(value: i*2))
                }
                
                manager.addEvent(event: IntEvent(value: 1))
                manager.addEvent(event: IntEvent(value: 7))
                expect(counter).toEventually(equal(numberOfEvents))
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

