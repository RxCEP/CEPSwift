//
//  SensorNetworkSim.swift
//  thesis
//
//  Created by Hélmiton Júnior on 6/20/18.
//  Copyright © 2018 Hélmiton Júnior. All rights reserved.
//

import RxSwift
import CEPSwift
import Foundation

class SensorNetworkSim {
    var lastDecrease = Date()
    let disposeBag = DisposeBag()
    var monitor = Monitor()
    let queueMonitor = DispatchQueue(label: "sync")
    let queueTemp = DispatchQueue.global(qos: .userInitiated)
    let queueTimeout = DispatchQueue.global(qos: .userInitiated)

    var noIterations: Int
    var temperature: Int
    var tempMargin: Int
    var tempGrowth: Int
    var sensorsDone: Int
    var status: NetStatusEvent
    var sensorReadEvents = EventManager<SensorReadEvent>()
    var timeoutEvents = EventManager<TimeoutEvent>()
    var simulationStatus = EventManager<TimeoutEvent>()
    
    init(iterations: Int, temperature: Int, tempMargin: Int, tempGrowth: Int, status: NetStatusEvent){
        self.sensorsDone = 0
        self.noIterations = iterations
        self.status = status
        self.temperature = temperature
        self.tempMargin = tempMargin
        self.tempGrowth = tempGrowth
    }
    
    private func initTemperatureStream() {
        // Const immutable parameter
        let sensors = status.noSensors
        for n in 0...sensors {
            DispatchQueue.global(qos: .default).async {
                // Avoid unwanted synchronized behaviour
                Thread.sleep(forTimeInterval: TimeInterval(n+1))
                for _ in 1...self.noIterations {
                    var newTemp: Int
                    // Wait for frequency interval
                    Thread.sleep(forTimeInterval: TimeInterval(self.status.readFreq))
                    // Randomize sensor reading
                    let newMargin = Int(arc4random_uniform(UInt32(self.tempMargin)));
                    // Calculate new temperature
                    if (self.tempMargin < self.temperature) {
                        newTemp = self.temperature - self.tempMargin + newMargin
                    } else {
                        newTemp = self.tempMargin - self.temperature + newMargin
                    }
                    // Add new event to given sensor
                    let date = Date()
                    self.queueTemp.async {
                        self.sensorReadEvents
                            .addEvent(event: SensorReadEvent(date: Date(), data: newTemp))
                    }
                    self.queueMonitor.sync {
                        self.monitor.append(ticket:
                            monitorTicket(type:"TRE",data:newTemp,date:date, id:n))
                    }
                }
                // Count sensor as finished
                self.queueMonitor.sync {
                    self.sensorsDone += 1
                }
                if (self.sensorsDone >= self.status.noSensors) {
                    //self.getTickets()
                    self.simulationStatus.addEvent(event: TimeoutEvent(date: Date(), data: 1))
                }
            }
        }
    }
    
    private func initTimeoutStream() {
        // Const immutable parameter
        let sensors = status.noSensors
        for n in 0...sensors {
            DispatchQueue.global(qos: .default).async {
                // Avoid unwanted synchronized behaviour
                Thread.sleep(forTimeInterval: TimeInterval(n))
                while (self.sensorsDone < self.status.noSensors) {
                    // Wait for keepalive timeout interval
                    Thread.sleep(forTimeInterval: TimeInterval(self.status.kpaTimeout))
                    // Simulate if the sensor responded keepalive or failed
                    let timeout = self.status.qos - Int(arc4random_uniform(UInt32(100)))
                    let date = Date()
                    // If failed, add new timeout event
                    if (timeout < 0) {
                        self.queueTimeout.async {
                            self.timeoutEvents.addEvent(
                                event: TimeoutEvent(date: date, data: (timeout * -1)))
                        }
                        self.queueMonitor.sync {
                            self.monitor.append(ticket:
                                monitorTicket(type:"KTE",data:(timeout * -1),date:date, id: n))
                        }
                    }
                }
            }
        }
    }
    
    private func simulateRoom() {
        DispatchQueue.global(qos: .default).async {
            while (self.sensorsDone < self.status.noSensors) {
                Thread.sleep(forTimeInterval: TimeInterval(5))
                self.temperature += self.tempGrowth
            }
        }
    }
    
    public func adjustTemperature(event: TemperatureUpdateEvent) {
        self.temperature -= 1
    }
    
    public func decreaseMargin() -> Void {
        if (Date().timeIntervalSince(lastDecrease) > 1500 && self.tempMargin > 2)
        {
            self.tempMargin -= 1
        }
    }
    
    public func adjustKeepAlive(event: KpaUpdateEvent) -> Void {
        self.status.kpaTimeout += 2
    }
    
    public func getMonitor() -> Monitor {
        return self.monitor
    }
    
    public func getTemperatureStreams() -> EventManager<SensorReadEvent> {
        return sensorReadEvents
    }
    
    public func getTimeoutStream() -> EventManager<TimeoutEvent> {
        return timeoutEvents
    }

    public func getStatusStream() -> EventManager<TimeoutEvent> {
        return simulationStatus
    }
    
    func start() {
        simulateRoom()
        initTemperatureStream()
        initTimeoutStream()
    }
    
}
