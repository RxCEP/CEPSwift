//
//  ComplexEvent.swift
//  CEPSwift
//
//  Created by George Guedes on 14/10/2017.
//  Copyright © 2017 CEPSwift. All rights reserved.
//

import Foundation
import RxSwift

public class ComplexEvent {
    internal var observable: Observable<(Any, Int)>
    private var numberOfEvents: Int
    private var operation: Operation
    private var maxTimeBetween: Int
    private var maxCountEvents: Int
    
    internal init(source: Observable<(Any, Int)>, count: Int, operation: Operation = .any, maxTimeBetween: Int = 5, maxCountEvents: Int = 4) {
        self.observable = source
        self.numberOfEvents = count
        self.operation = operation
        self.maxTimeBetween = maxTimeBetween
        self.maxCountEvents = maxCountEvents
    }
    
    public func merge<R>(with stream: EventStream<R>) -> ComplexEvent {
        let newNumberOfEvents = self.numberOfEvents + 1
        let streamObservable = stream.observable.map { elem in (elem as Any, newNumberOfEvents) }
        
        let newObservable = Observable.merge([self.observable, streamObservable])
        self.numberOfEvents = newNumberOfEvents
        
        return ComplexEvent(source: newObservable, count: newNumberOfEvents)
    }
    
    public func subscribe(completion: @escaping (() -> Void)) {
        let _ = startObserving()
        .subscribe(onNext: { _ in completion() })
    }
    
    func startObserving() -> Observable<()> {
        
        return self.observable.buffer(timeSpan: RxTimeInterval(maxTimeBetween), count: numberOfEvents, scheduler: MainScheduler.instance)
            .map({ events in
                var values = Set<Int>()
                
                for item in events {
                    values.insert(item.1)
                }
                
                return values.count
            })
            .filter { $0 >= self.numberOfEvents }
            .map { _ in }
    }
}

