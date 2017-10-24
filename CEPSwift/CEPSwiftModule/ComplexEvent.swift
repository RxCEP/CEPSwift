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
    private var observable: Observable<(Any, Int)>
    private var numberOfEvents: Int
    private var operation: Operation
    private var maxTimeBetween: Int
    private var maxCountEvents: Int
    
    public init(source: Observable<(Any, Int)>, count: Int, operation: Operation = .any, maxTimeBetween: Int = 5, maxCountEvents: Int = 4) {
        self.observable = source
        self.numberOfEvents = count
        self.operation = operation
        self.maxTimeBetween = maxTimeBetween
        self.maxCountEvents = maxCountEvents
    }
    
    public func subscribe(completion: @escaping (() -> Void)) {
        _ = self.observable.buffer(timeSpan: RxTimeInterval(maxTimeBetween), count: numberOfEvents, scheduler: MainScheduler.instance).subscribe { (buffer) in
            guard let events = buffer.element else { return }
            var values = Set<Int>()
            for item in events {
                values.insert(item.1)
            }
            if values.count == self.numberOfEvents {
                completion()
            }
        }
    }
}
