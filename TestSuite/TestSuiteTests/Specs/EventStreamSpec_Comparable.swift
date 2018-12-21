// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import CEPSwift

class EventStreamSpecComparable: QuickSpec {
    override func spec() {
        describe("EventStream Comparable") {
            intersectTest()
            unionTest()
            maxTest()
            minTest()
            notInTest()
            orderedTest()
            dropDuplicatesTest()
        }
    }
    
    private func orderedTest() {
        context("When ordering a EventStream") {
            let input = [
                (time: 1, event: IntEvent(value: 210)),
                (time: 3, event: IntEvent(value: 251)),
                (time: 3, event: IntEvent(value: 10)),
                (time: 3, event: IntEvent(value: 5)),
                (time: 4, event: IntEvent(value: 15)),
                (time: 5, event: IntEvent(value: 10)),
                (time: 7, event: IntEvent(value: 500))
            ]
            
            let expectedOutput = [
                (time: 1, event: [IntEvent(value: 210)]),
                (time: 3, event: [IntEvent(value: 210),
                                  IntEvent(value: 251)]),
                (time: 3, event: [IntEvent(value: 10),
                                  IntEvent(value: 210),
                                  IntEvent(value: 251)]),
                (time: 3, event: [IntEvent(value: 5),
                                  IntEvent(value: 10),
                                  IntEvent(value: 210),
                                  IntEvent(value: 251)]),
                (time: 4, event: [IntEvent(value: 5),
                                  IntEvent(value: 10),
                                  IntEvent(value: 15),
                                  IntEvent(value: 210),
                                  IntEvent(value: 251)]),
                (time: 5, event: [IntEvent(value: 5),
                                  IntEvent(value: 10),
                                  IntEvent(value: 10),
                                  IntEvent(value: 15),
                                  IntEvent(value: 210),
                                  IntEvent(value: 251)]),
                (time: 7, event: [IntEvent(value: 5),
                                  IntEvent(value: 10),
                                  IntEvent(value: 10),
                                  IntEvent(value: 15),
                                  IntEvent(value: 210),
                                  IntEvent(value: 251),
                                  IntEvent(value: 500)])
            ]
            
            func max(_ stream: EventStream<IntEvent>) -> EventStream<[IntEvent]> {
                return stream.ordered { $0.value <= $1.value}
            }
            
            let output = EventStreamSimulator().simulate(with: input, handler: max)
            
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
    
    private func unionTest() {
        context("When filtering common elements of two EventStreams") {
            let input1 = [
                (time: 2, event: IntEvent(value: 1)),
                (time: 2, event: IntEvent(value: 2)),
                (time: 3, event: IntEvent(value: 4)),
                (time: 4, event: IntEvent(value: 8)),
                (time: 5, event: IntEvent(value: 16)),
                (time: 6, event: IntEvent(value: 32)),
            ]
            
            let input2 = [
                (time: 1, event: IntEvent(value: 1)),
                (time: 1, event: IntEvent(value: 2)),
                (time: 3, event: IntEvent(value: 16)),
                (time: 5, event: IntEvent(value: 32)),
                (time: 7, event: IntEvent(value: 64))
            ]
            
            let expectedOutput = [
                (time: 1, event: IntEvent(value: 1)),
                (time: 1, event: IntEvent(value: 2)),
                (time: 3, event: IntEvent(value: 4)),
                (time: 3, event: IntEvent(value: 16)),
                (time: 4, event: IntEvent(value: 8)),
                (time: 5, event: IntEvent(value: 32)),
                (time: 7, event: IntEvent(value: 64))
            ]
            
            func union(_ stream1: EventStream<IntEvent>,
                       _ stream2: EventStream<IntEvent>) -> EventStream<IntEvent> {
                return stream1.union(with: stream2)
            }
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input1,
                                            with: input2,
                                            handler: union)
            
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
    
    private func dropDuplicatesTest() {
        context("When filtering unique elements of a stream") {
            let input = [
                (time: 1, event: IntEvent(value: 210)),
                (time: 3, event: IntEvent(value: 251)),
                (time: 3, event: IntEvent(value: 10)),
                (time: 4, event: IntEvent(value: 5)),
                (time: 4, event: IntEvent(value: 15)),
                (time: 4, event: IntEvent(value: 10)),
                (time: 6, event: IntEvent(value: 251))
            ]
            
            let expectedOutput = [
                (time: 1, event: IntEvent(value: 210)),
                (time: 3, event: IntEvent(value: 251)),
                (time: 3, event: IntEvent(value: 10)),
                (time: 4, event: IntEvent(value: 5)),
                (time: 4, event: IntEvent(value: 15)),
            ]
            
            let output = EventStreamSimulator().simulate(with: input) { (stream: EventStream<IntEvent>) in
                return stream.dropDuplicates()
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
    
    private func minTest() {
        context("When fetching the smallest events of a stream") {
            let input = [
                (time: 1, event: IntEvent(value: 50)),
                (time: 1, event: IntEvent(value: 10)),
                (time: 1, event: IntEvent(value: 30)),
                (time: 2, event: IntEvent(value: 30)),
                (time: 3, event: IntEvent(value: 5)),
            ]
            
            let expectedOutput = [
                (time: 1, event: IntEvent(value: 50)),
                (time: 1, event: IntEvent(value: 10)),
                (time: 3, event: IntEvent(value: 5)),
            ]
            
            func min(_ stream: EventStream<IntEvent>) -> EventStream<IntEvent> {
                return stream.min()
            }
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input, handler: min)
            
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

    private func maxTest() {
        context("When fetching the biggest events of a stream") {
            let input = [
                (time: 1, event: IntEvent(value: 210)),
                (time: 3, event: IntEvent(value: 251)),
                (time: 3, event: IntEvent(value: 10)),
                (time: 3, event: IntEvent(value: 5)),
                (time: 4, event: IntEvent(value: 15)),
                (time: 5, event: IntEvent(value: 10)),
                (time: 7, event: IntEvent(value: 500))
            ]
            
            let expectedOutput = [
                (time: 1, event: IntEvent(value: 210)),
                (time: 3, event: IntEvent(value: 251)),
                (time: 7, event: IntEvent(value: 500))
            ]
            
            func max(_ stream: EventStream<IntEvent>) -> EventStream<IntEvent> {
                return stream.max()
            }
            
            let output = EventStreamSimulator().simulate(with: input, handler: max)
            
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
    
    private func notInTest() {
        context("When subtracting two EventStreams") {
            let input1 = [
                (time: 2, event: IntEvent(value: 1)),
                (time: 2, event: IntEvent(value: 2)),
                (time: 3, event: IntEvent(value: 4)),
                (time: 4, event: IntEvent(value: 8)),
                (time: 5, event: IntEvent(value: 16)),
                (time: 6, event: IntEvent(value: 32)),
                (time: 7, event: IntEvent(value: 64))
            ]
            let input2 = [
                (time: 1, event: IntEvent(value: 1)),
                (time: 1, event: IntEvent(value: 2)),
                (time: 3, event: IntEvent(value: 16)),
                (time: 5, event: IntEvent(value: 32)),
                ]
            
            let expectedOutput = [
                (time: 3, event: IntEvent(value: 4)),
                (time: 4, event: IntEvent(value: 8)),
                (time: 7, event: IntEvent(value: 64))
            ]
            
            func notIn(_ stream1: EventStream<IntEvent>,
                       _ stream2: EventStream<IntEvent>) -> EventStream<IntEvent> {
                return stream1.not(in: stream2)
            }
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input1, with: input2, handler: notIn)
            
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
    
    private func intersectTest() {
        context ("When intersecting two EventStreams") {
            let input1 = [
                (time: 1, event: IntEvent(value: 1)),
                (time: 2, event: IntEvent(value: 2)),
                (time: 3, event: IntEvent(value: 4)),
                (time: 4, event: IntEvent(value: 8)),
                (time: 5, event: IntEvent(value: 16)),
                (time: 6, event: IntEvent(value: 32)),
                (time: 7, event: IntEvent(value: 64))
            ]
            
            let input2 = [
                (time: 1, event: IntEvent(value: 0)),
                (time: 1, event: IntEvent(value: 32)),
                (time: 3, event: IntEvent(value: 99)),
                (time: 4, event: IntEvent(value: 8)),
                (time: 5, event: IntEvent(value: 1)),
                (time: 5, event: IntEvent(value: 100))
                ]
            
            let expectedOutput = [
                (time: 4, event: IntEvent(value: 8)),
                (time: 5, event: IntEvent(value: 1)),
                (time: 6, event: IntEvent(value: 32))
                ]
            
            func intersect(_ stream1: EventStream<IntEvent>,
                           _ stream2: EventStream<IntEvent>) -> EventStream<IntEvent> {
                return stream1.intersect(with: stream2)
            }
            
            let simulator = EventStreamSimulator<IntEvent>()
            let output = simulator.simulate(with: input1,
                                             with: input2,
                                             handler: intersect)
            
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

