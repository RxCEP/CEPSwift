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
}

extension EventStream where T: NumericEvent {
    public func sum() -> Observable<Int> {
        return self.observable
            .map({$0.numericValue})
            .scan(0) { (lastSlice, newValue) in
                return lastSlice + newValue
            }
    }
    
    public func count() -> Observable<Int> {
        return self.observable
            .map({$0.numericValue})
            .scan(0) { (lastSlice, _) in
                return lastSlice + 1
            }
    }

    public func average(timeWindow: Double, currentDate: Date) -> Observable<Int> {
        let doubled = Observable
            .combineLatest(self
            .filter(predicate:
                    {currentDate.timeIntervalSince($0.timestamp) < timeWindow})
                .sum(),
                self.filter(predicate:
                    {currentDate.timeIntervalSince($0.timestamp) < timeWindow})
                    .count())
            {return $0/$1}
        return doubled.skip(1)
    }

    public func probability(val: Int) -> Observable<Double> {
        let matchesCount = self.observable
        .map({$0.numericValue})
        .filter({$0 == val})
            .scan(0) { (lastSlice, _) in
                return lastSlice + 1
        }
        
        let doubled = Observable
            .combineLatest(
                matchesCount
                    .map({Double($0)}),
                self.count().map({Double($0)})) {
                    return Double($0/$1)}
        
        return doubled.skip(1)
    }

        public func expected(val: Int) -> Observable<Double> {
        let probability = self.probability(val: val, trials: trials)
        let doubled = Observable
            .combineLatest(probability, self.count()) { return $0*Double($1)}
        return doubled.skip(1)
    }
}
