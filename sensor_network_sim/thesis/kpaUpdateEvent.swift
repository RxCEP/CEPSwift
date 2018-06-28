//
//  kpaUpdateEvent.swift
//  thesis
//
//  Created by Hélmiton Júnior on 6/20/18.
//  Copyright © 2018 Hélmiton Júnior. All rights reserved.
//

import CEPSwift
import Foundation

class KpaUpdateEvent: Event {
    var timestamp: Date
    var timeout: Int
    
    init(date: Date, timeout: Int) {
        self.timestamp = date
        self.timeout = timeout
    }
}
