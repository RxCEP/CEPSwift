//
//  TemperatureUpdateEvent.swift
//  thesis
//
//  Created by Hélmiton Júnior on 6/20/18.
//  Copyright © 2018 Hélmiton Júnior. All rights reserved.
//

import CEPSwift
import Foundation

class TemperatureUpdateEvent: Event {

    var timestamp: Date
    var temp: Int
    
    init(date: Date, temp: Int) {
        self.timestamp = date
        self.temp = temp
    }
}
