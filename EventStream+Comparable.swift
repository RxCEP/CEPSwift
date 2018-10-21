//
//  EventStream+Comparable.swift
//  CEPSwift
//
//  Created by Filipe Jordão on 21/10/18.
//

import Foundation
import RxSwift

extension EventStream where T: Comparable {
    public func max() -> EventStream<T> {
        return EventStream<T>(withObservable:
            self.observable
                .scan([]) { lastSlice, newValue in
                    return Array(lastSlice + [newValue])
                }
                .map { $0.max() }
                .filter { $0 != nil}
                .map { $0! })
            .dropDuplicates()
    }
    
    
    public func min() -> EventStream<T> {
        return EventStream<T>(withObservable:
            self.observable
                .scan([]) { lastSlice, newValue in
                    return Array(lastSlice + [newValue])
                }
                .map { $0.min() }
                .filter { $0 != nil}
                .map { $0! })
            .dropDuplicates()
    }
    
    /**
     Creates a new **EventStream** of previously occurred events **ordered by** a comparison function.
     
     - parameter by: Comparison function.
     */
    public func ordered(by comparison: @escaping (T,T) -> Bool) -> EventStream<[T]> {
        return self.accumulated().map { events -> [T] in
            return events.sorted(by: comparison)
        }
    }
    
    /**
     Creates a new **EventStream** that emits only unique events.
     */
    public func dropDuplicates() -> EventStream<T> {
        let newObservable = self.observable
            .withLatestFrom(self.accumulated().observable) { (event, acc) -> (T,[T]) in
                return (event, acc)
            }
            .filter { (event, acc) -> Bool in
                return acc.filter { $0 == event }.count == 1
            }
            .map { $0.0 }
        
        return EventStream<T>(withObservable: newObservable)
    }
    
    /**
     Creates a new **EventStream** that emits the **unique events** of both parent streams.
     
     - parameter stream: The **EventStream** which will be performed the union with.
     */
    public func union(with stream: EventStream<T>) -> EventStream<T> {
        let newObservable = Observable.merge([self.observable, stream.observable])
        
        return EventStream<T>(withObservable: newObservable).dropDuplicates()
    }
    
    /**
     Creates a **EventStream** that emits events that are not present on the received stream.
     
     - parameter stream: The **EventStream** which emit events that are ignored by the new **EventStream**
     */
    public func not(in stream: EventStream<T>) -> EventStream<T> {
        let streamAcc = EventStream<[T]>(withObservable: stream.accumulated().observable.startWith([]))
        
        let newObservable = self.observable.withLatestFrom(streamAcc.observable) { (event, acc) -> (T, [T]) in
            return (event,acc)
            }.filter { (event, acc) -> Bool in
                return acc.filter { $0 == event }.count == 0
            }
            .map { $0.0 }
        
        return EventStream<T>(withObservable: newObservable)
    }
    
    /**
     Creates a **EventStream** that emits events present in both **parent EventStreams**
     
     - parameter stream: One of the parent **EventStreams**
     */
    public func intersect(with stream: EventStream<T>) -> EventStream<T> {
        let selfAcc = self.accumulated()
        let streamAcc = stream.accumulated()
        
        let selfInStream = self.observable.withLatestFrom(streamAcc.observable, resultSelector: self.isElem).filter { $0 != nil }
        
        let streamInSelf = stream.observable.withLatestFrom(selfAcc.observable, resultSelector: self.isElem).filter { $0 != nil }
        
        let newObservable = Observable.merge([selfInStream, streamInSelf])
            .map { $0! }
        return EventStream<T>(withObservable: newObservable).dropDuplicates()
    }
    
    private func isElem(_ elem: T, in array: [T]) throws -> T? {
        return array.contains(elem) ? elem : nil
    }
}
