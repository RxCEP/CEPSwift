//
//  EventStream+ProbabilityOperators.swift
//  CEPSwift
//
//  Created by Filipe Jordão on 30/09/18.
//

import Foundation
import RxSwift

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
        let probability = self.probability(val: val)
        let doubled = Observable
            .combineLatest(probability, self.count()) { return $0*Double($1)}
        return doubled.skip(1)
    }

    //variance = prob(x)*trials*1-prob(x)
    public func variance(dataSize: Int) -> Observable<Double> {
        // Dataset mean
        let a = self.sum().map {$0/dataSize}
        // Square diferences
        let b = Observable.combineLatest( a, self.observable
            .map({$0.numericValue})) {return ($0 - $1)*($0 - $1)}
        // Averaged squared diferences
        let sumAll = b.scan(0) {(a,b) in return a + b}
        let countAll = b.scan(0) {(a,_) in return a + 1}
        let doubled = Observable.combineLatest(
            sumAll.map({Double($0)}),
            countAll.map({Double($0)})) {($0/$1)}
        return doubled.skip(3)
    }
}
