//
//  EventStreamSimulator.swift
//  CEPSwift
//
//  Created by Filipe Jordão on 20/05/18.
//

import Foundation
import RxSwift
import RxTest

public class EventStreamSimulator<T> {
    private var scheduler: TestScheduler
    
    public init() {
        self.scheduler = TestScheduler(initialClock: 0)
    }
    
    public func simulate<K>(with events: [EventEntry<T>],
                            handler: @escaping StreamToStream<T,K>) -> [EventEntry<K>] {
        
        let input = events.map(self.recorded)
        let xs = self.scheduler.createHotObservable(input)
        
        let results = self.scheduler.start(created: 0,
                                           subscribed: 0,
                                           disposed: 1000) { () -> Observable<K> in
                                        
            handler(EventStream<T>(withObservable: xs.asObservable())).observable
        }
        
        return results.events.map (self.entry)
    }
    
    public func simulate<K>(with events1: [EventEntry<T>],
                         with events2: [EventEntry<T>],
                         handler: @escaping StreamsToStream<T,K>) -> [EventEntry<K>] {
        
        let input1 = events1.map(self.recorded)
        let input2 = events2.map(self.recorded)
        
        let xs1 = self.scheduler.createHotObservable(input1)
        let xs2 = self.scheduler.createHotObservable(input2)
        
        let results = self.scheduler.start(created: 0,
                                           subscribed: 0,
                                           disposed: 1000) { () -> Observable<K> in
                                            
            handler(EventStream<T>(withObservable: xs1.asObservable()),
                    EventStream<T>(withObservable: xs2.asObservable())
            ).observable
        }
        
        return results.events.map (self.entry)
    }
    
    private func recorded<K>(from entry: EventEntry<K>) -> Recorded<RxSwift.Event<K>> {
        return next(entry.time, entry.event)
    }
    
    private func entry<K>(from recorded: Recorded<RxSwift.Event<K>>) -> EventEntry<K> {
        return (time: recorded.time, event: recorded.value.element!)
    }
}
