//
//  ViewController.swift
//  thesis
//

import CEPSwift
import RxSwift
import UIKit

// Parameters
let maxTimeout = 25  // Rule for max timeout value
let idealTemperature = 18 // Rule for expectancy temperature value
let maxTemperature = 20 // Rule for change temperature value
let maxMargin = 10  // Rule for Sensor adjustment
let noIterations = 50 // Number of reading to be performed by each sensor
let roomTemp = 30 // Starting room temperature
let tempGrowth = 2 // Rate at which temperature increases
let sensorErrMargin = 5 // Error margin for censor`s temperature reading
let sensorReadFreq = 2 // Frequency of sensor reading (sec)
let noSensors = 4 // Number of sensors (and threads) genereting events
let networkQoS = 50 // Rule for timeout Event
let kpaTimeout = 3 // Rule for keepAlive

let disposeBag = DisposeBag()

// Global vars
var tempDataset = Array<Int>()
var timeoutDataset = Array<Int>()
var tempCounter = 0
var kpaCounter = 0
var tempTimeWindow:Double = Double(sensorReadFreq+1)
var kpaTimeWindow:Double = Double(kpaTimeout*10)

var array = Array<Any>()

class ViewController: UIViewController {
    var monitor = Monitor()
    
    // Initialize simulation
    let simulation = SensorNetworkSim(
        iterations: noIterations, temperature: roomTemp,
        tempMargin: sensorErrMargin, tempGrowth: tempGrowth,
        status: NetStatusEvent(
            date: Date(), noSensors: noSensors, qos: networkQoS,
            readFreq: sensorReadFreq, kpaTimeout: kpaTimeout))

    override func viewDidLoad() {
        // Set rules
        setRules()
    }

    func setRules() {
       // Event Managers
        let timeoutEvents = simulation.getTimeoutStream()
        let tempEvents = simulation.getTemperatureStreams()
        let statusEvents = simulation.getStatusStream()
        
        simulation.start()
        
        // Simulation Completion Rule
        let simulationCompleted = statusEvents.stream
            .subscribe(onNext: {
                if ($0.numericValue == 1) {
                    for ticket in self.simulation.getMonitor().tickets {
                        self.monitor.append(ticket: ticket)
                    }
                    self.monitor.getReport()
                }
            })
        
        // KeepAlive Timeout Rule
        // Update kpa if timeout avager is > than maxTimeout
        let kpaUpdateRule = timeoutEvents.stream
            .average(timeWindow: kpaTimeWindow, currentDate: Date())
        kpaUpdateRule.subscribe(onNext: {
            kpaCounter+=1
            if ($0 > maxTimeout) {
                self.kpaUpdate(timeout: $0)
            }
        }).disposed(by: disposeBag)

//        let keepaliveUpdateRule2 = timeoutEvents.stream
//        keepaliveUpdateRule2.subscribe(onNext: {
//            timeoutDataset.append($0.numericValue)
//            var sum: Double = 0
//            for value in  timeoutDataset {
//                sum += Double(value)
//            }
//            let avg = Int(sum/Double(timeoutDataset.count))
//            if (Int(avg) > minimalTimeout) {
//                self.kpaUpdate(timeout: avg)
//            }
//        })
        
        // Temperature Rules
        
        // Update room temperature if average temperature is > maxTemperature
        let tempUpdateRule = tempEvents.stream
            .average(timeWindow: tempTimeWindow, currentDate: Date())
        tempUpdateRule.subscribe(onNext: {
            tempCounter+=1
            if ($0 > maxTemperature) {
                    self.tempUpdate(temp: $0)
            }
        }).disposed(by: disposeBag)
        
//        let tempUpdateRule2 = tempEvents.stream
//        tempUpdateRule2.subscribe(onNext: {
//            timeoutDataset.append($0.numericValue)
//            var sum: Double = 0
//            for value in  timeoutDataset {
//                sum += Double(value)
//            }
//            let avg = Int(sum/Double(timeoutDataset.count))
//            if (Int(avg) > maxTemperature) {
//                self.kpaUpdate(timeout: avg)
//            }
//        })
        
    // Adjust sensor reading margin
    // Update sensor margin if reading variance > 1000
    let marginUpdateRule = tempEvents
        .stream
        .variance(dataSize: noIterations*noSensors)
    marginUpdateRule.subscribe(onNext: {
        if ($0 > 1000) {
            self.marginUpdate(value: $0)
        }
    }).disposed(by: disposeBag)
    
//    let marginUpdateRule2 = tempEvents.stream
//    marginUpdateRule2.subscribe(onNext: {
//        tempDataset.append($0.numericValue)
//        var sum: Int = 0
//        for value in tempDataset {
//            sum += value
//        }
//        let dataMean = Double(sum)/Double(tempDataset.count)
//        var sumDiff: Double = 0
//        for value in tempDataset {
//            sumDiff += pow((Double(value) - dataMean), 2)
//        }
//        let variance = sumDiff/Double(tempDataset.count)
//        if ( variance > 1000) {
//            self.marginUpdate(value: variance)
//        }
//    })
}

    //Triggering Functions
    func kpaUpdate(timeout: Int) {
        self.simulation.adjustKeepAlive(event: KpaUpdateEvent(date: Date(), timeout: timeout))
        self.monitor.append(ticket: monitorTicket(type:"KTU",data:timeout,date:Date(), id: 9))
    }
    func tempUpdate(temp: Int) {
        self.simulation.adjustTemperature(event: TemperatureUpdateEvent(date: Date(), temp: temp))
        self.monitor.append(ticket: monitorTicket(type:"TCU",data:temp,date:Date(), id: 9))
    }
    func marginUpdate(value: Double) {
        self.simulation.decreaseMargin()
        self.monitor.append(ticket: monitorTicket(type:"MCU",data:Int(value),date:Date(), id: 9))
    }

}
