//
//  EventManager.swift
//  CEPSwift
//
//  Created by George Guedes on 28/08/17.
//  Copyright © 2017 CEPSwift. All rights reserved.
//

import Foundation
import RxSwift

public class EventManager<T: Event> {
    private let events = PublishSubject<T>()
    public private(set) var stream: EventStream<T>
    
    public init() {
        self.stream = EventStream(withObservable: self.events.asObservable())
    }
    
    public func addEvent(event: T) {
        self.events.onNext(event)
    }
}
