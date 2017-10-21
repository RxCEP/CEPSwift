//
//  EventManager.swift
//  CEPSwift
//
//  Created by George Guedes on 28/08/17.
//  Copyright © 2017 CEPSwift. All rights reserved.
//

import Foundation
import RxSwift

class EventManager<T: Event> {
    private let events = PublishSubject<T>()
    
    public func addEvent(event: T) {
        self.events.onNext(event)
    }
    
    public func asObservable() -> EventObservable<T> {
        return EventObservable(withObservable: self.events)
    }
}
