//
//  ComplexEventSimulator.swift
//  CEPSwift
//
//  Created by Filipe Jordão on 22/10/18.
//

import Foundation
import RxTest
import RxSwift

class ComplexEventSimulator {
    private var scheduler: TestScheduler
    
    public init() {
        self.scheduler = TestScheduler(initialClock: 0)
    }

    public func simulate<T,K>(with events1: [(time: Int, event: T)],
                              with events2: [(time: Int, event: K)],
                              handler: @escaping (EventStream<T>, EventStream<K>) -> ComplexEvent) -> [Int] {
        let input1 = events1.map(recorded)
        let input2 = events2.map(recorded)
        
        let xs1 = self.scheduler.createHotObservable(input1)
        let xs2 = self.scheduler.createHotObservable(input2)
        
        let results = self.scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            handler(EventStream<T>(withObservable: xs1.asObservable()),
                    EventStream<K>(withObservable: xs2.asObservable())
                ).startObserving()
        }
        
        return results.events.map (self.entry)
    }
    
    private func recorded<K>(from entry: (time: Int, event: K)) -> Recorded<RxSwift.Event<K>> {
        return next(entry.time, entry.event)
    }
    
    private func entry<K>(from recorded: Recorded<RxSwift.Event<K>>) -> Int {
        return recorded.time
    }
}
