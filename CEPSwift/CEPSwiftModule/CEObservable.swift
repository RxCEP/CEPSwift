//
//  CEObservable.swift
//  CEPSwift
//
//  Created by George Guedes on 14/10/2017.
//  Copyright © 2017 CEPSwift. All rights reserved.
//

import Foundation
import RxSwift

class CEObservable {
    private var eventObservable: Observable<(Any, Int)>
    private var numberOfEvents: Int
    private var operation: Operation
    private var maxTimeBetween: Int
    private var maxCountEvents: Int
    
    init(source: Observable<(Any, Int)>, count: Int, operation: Operation = .any, maxTimeBetween: Int = 5, maxCountEvents: Int = 4) {
        self.eventObservable = source
        self.numberOfEvents = count
        self.operation = operation
        self.maxTimeBetween = maxTimeBetween
        self.maxCountEvents = maxCountEvents
    }
    
    func subscribe(completion: @escaping (() -> Void)) {
        _ = self.eventObservable.asObservable().buffer(timeSpan: RxTimeInterval(maxTimeBetween), count: numberOfEvents, scheduler: MainScheduler.instance).subscribe { (buffer) in
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
