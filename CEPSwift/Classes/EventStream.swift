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
