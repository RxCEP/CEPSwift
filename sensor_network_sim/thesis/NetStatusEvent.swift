//
//  NetStatusEvent.swift
//  thesis
//
//  Created by Hélmiton Júnior on 6/20/18.
//  Copyright © 2018 Hélmiton Júnior. All rights reserved.
//

import CEPSwift
import Foundation

class NetStatusEvent: Event {
    var timestamp: Date
    var noSensors: Int
    var qos: Int
    var readFreq: Int
    var kpaTimeout: Int
    
    init(date: Date, noSensors: Int, qos: Int, readFreq: Int, kpaTimeout: Int) {
        self.timestamp = date
        self.noSensors = noSensors
        self.qos = qos
        self.readFreq = readFreq
        self.kpaTimeout = kpaTimeout
    }
}
