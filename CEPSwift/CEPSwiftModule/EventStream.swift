//
//  EventStream.swift
//  CEPSwift
//
//  Created by George Guedes on 18/09/17.
//  Copyright © 2017 CEPSwift. All rights reserved.
//

import Foundation
import RxSwift

class EventStream<T> {
    fileprivate let observable: Observable<T>
    
    init(withObservable: Observable<T>) {
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
    
    public func merge<R>(anotherObservable: EventStream<R>) -> ComplexEvent {
        let merged = Observable.merge(self.observable.map({ (element) -> (Any, Int) in
            (element as Any, 1)
        }), anotherObservable.observable.map({ (element) -> (Any, Int) in
            (element as Any, 2)
        }))
        
        return ComplexEvent(source: merged, count: 2)
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
}

extension EventStream where T: Comparable {
    func max(onNext: @escaping((_ max: T?) -> Void)) {
        _ = self.observable.scan([]) { lastSlice, newValue in
            return Array(lastSlice + [newValue])
            }.subscribe { (value) in
                onNext(value.element?.max())
        }
    }
    
    func min(onNext: @escaping((_ min: T?) -> Void)) {
        _ = self.observable.scan([]) { lastSlice, newValue in
            return Array(lastSlice + [newValue])
            }.subscribe { (value) in
                onNext(value.element?.min())
        }
    }
}
