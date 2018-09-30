//
//  EventStream.swift
//  CEPSwift
//
//  Created by George Guedes on 18/09/17.
//  Copyright © 2017 CEPSwift. All rights reserved.
//

import Foundation
import RxSwift

public class EventStream<T> {
    internal let observable: Observable<T>
    
    internal init(withObservable: Observable<T>) {
        self.observable = withObservable
    }
    
    public func subscribe(onNext: ((T) -> Void)?) {
        _ = self.observable.subscribe(onNext: onNext)
    }
    
    public func filter(predicate: @escaping (T) -> Bool) -> EventStream<T> {
        return EventStream(withObservable: self.observable.filter(predicate))
    }
    
    public func followedBy(predicate: @escaping(T, T) -> Bool) -> EventStream<(T,T)> {
        return self.pairwise().filter(predicate: predicate)
    }
    
    public func map<R>(transform: @escaping (T) -> R) -> EventStream<R> {
        let observable = self.observable.map(transform)
        return EventStream<R>(withObservable: observable)
    }
    
    public func merge<R>(with stream: EventStream<R>) -> ComplexEvent {
        let merged = Observable.merge(self.observable.map({ (element) -> (Any, Int) in
            (element as Any, 1)
        }), stream.observable.map({ (element) -> (Any, Int) in
            (element as Any, 2)
        }))
        
        return ComplexEvent(source: merged, count: 2)
    }
    
    public func asComplexEvent() -> ComplexEvent {
        let obs = self.observable.map { element in (element as Any, 1) }
        
        return ComplexEvent(source: obs, count: 1)
    }
    
    public func window(ofTime: Int, max: Int, repeats: Bool = true) -> EventStream<[T]> {
        var observable = self.observable.buffer(timeSpan: RxTimeInterval(ofTime),
                                                count: max,
                                                scheduler: MainScheduler.instance)
        
        if(!repeats) {
            observable = observable.take(1)
        }
        
        return EventStream<[T]>(withObservable: observable)
    }
    
    private func pairwise() -> EventStream<(T,T)> {
        var previous:T? = nil
        let observable = self.observable
            .filter { element in
                if previous == nil {
                    previous = element
                    return false
                } else {
                    return true
                }
            }
            .map { (element:T) -> (T,T) in
                defer { previous = element }
                return (previous!, element)
        }
        
        return EventStream<(T,T)>(withObservable: observable)
    }
    
    /**
     Creates a **EventStream** that emit a list of events occured until the moment
    */
    public func accumulated() -> EventStream<[T]> {
        let newObservable = self.observable.scan([]) { acc, val in
            return Array(acc + [val])
        }
        
        return EventStream<[T]>(withObservable: newObservable)
    }
}

extension EventStream where T: Comparable {
    public func max(onNext: @escaping((_ max: T?) -> Void)) {
        _ = self.observable.scan([]) { lastSlice, newValue in
            return Array(lastSlice + [newValue])
            }.subscribe { (value) in
                onNext(value.element?.max())
        }
    }
    
    public func min(onNext: @escaping((_ min: T?) -> Void)) {
        _ = self.observable.scan([]) { lastSlice, newValue in
            return Array(lastSlice + [newValue])
            }.subscribe { (value) in
                onNext(value.element?.min())
        }
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
