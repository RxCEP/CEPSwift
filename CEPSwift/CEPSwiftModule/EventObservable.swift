//
//  EventObservable.swift
//  CEPSwift
//
//  Created by George Guedes on 18/09/17.
//  Copyright © 2017 CEPSwift. All rights reserved.
//

import Foundation
import RxSwift

class EventObservable<T> {
    fileprivate let eventObservable: Observable<T>
    
    init(withObservable: Observable<T>) {
        self.eventObservable = withObservable
    }
    
    public func subscribe(onNext: ((T) -> Void)?) {
        _ = self.eventObservable.subscribe(onNext: onNext)
    }
    
    public func filter(predicate: @escaping (T) -> Bool) -> EventObservable<T> {
        return EventObservable(withObservable: self.eventObservable.filter(predicate))
    }
    
    public func followedBy(predicate: @escaping(T, T) -> Bool) -> EventObservable<(T,T)> {
        return self.pairwise().filter(predicate: predicate)
    }
    
    public func map<R>(transform: @escaping (T) -> R) -> EventObservable<R> {
        let observable = self.eventObservable.map(transform)
        return EventObservable<R>(withObservable: observable)
    }
    
    public func merge<R>(anotherObservable: EventObservable<R>) -> CEObservable {
        let merged = Observable.merge(self.eventObservable.map({ (element) -> (Any, Int) in
            (element as Any, 1)
        }), anotherObservable.eventObservable.map({ (element) -> (Any, Int) in
            (element as Any, 2)
        }))
        
        return CEObservable(source: merged, count: 2)
    }
    
    public func window(ofTime: Int, max: Int, repeats: Bool = true) -> EventObservable<[T]> {
        var observable = self.eventObservable.buffer(timeSpan: RxTimeInterval(ofTime), count: max, scheduler: MainScheduler.instance)
        
        if(!repeats) {
            observable = observable.take(1)
        }
        
        return EventObservable<[T]>(withObservable: observable)
    }
    
    private func pairwise() -> EventObservable<(T,T)> {
        var previous:T? = nil
        let observable = self.eventObservable
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
        
        return EventObservable<(T,T)>(withObservable: observable)
    }
}

extension EventObservable where T: Comparable {
    func max(onNext: @escaping((_ max: T?) -> Void)) {
        _ = self.eventObservable.scan([]) { lastSlice, newValue in
            return Array(lastSlice + [newValue])
            }.subscribe { (value) in
                onNext(value.element?.max())
        }
    }
    
    func min(onNext: @escaping((_ min: T?) -> Void)) {
        _ = self.eventObservable.scan([]) { lastSlice, newValue in
            return Array(lastSlice + [newValue])
            }.subscribe { (value) in
                onNext(value.element?.min())
        }
    }
}
