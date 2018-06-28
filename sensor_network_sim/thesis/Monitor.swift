//
//  Monitor.swift
//  thesis
//
//  Created by Hélmiton Júnior on 6/20/18.
//  Copyright © 2018 Hélmiton Júnior. All rights reserved.
//

import Foundation

struct monitorTicket {
    // Event details
    var type: String
    var data: Int
    var date: Date
    var id: Int
    let formatter = DateFormatter()
    func toString() -> String {
        formatter.dateFormat = "HH:mm:ss.SSSS"
        return "\(type),\(id),\(data),\(formatter.string(from: date))"}
}
func printDate(string: String) {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSSS"
    print(string + formatter.string(from: date))
}

class Monitor {
    var tickets = Array<monitorTicket>()
    public func getTickets() -> Array<monitorTicket> {
        return tickets
    }
    public func append(ticket: monitorTicket) {
        tickets.append(ticket)
    }
    public func getReport() {
        let dataset = tickets.sorted(by: {$0.date < $1.date})
        let consumedDataset = dataset.filter({($0.type == "TRE") || ($0.type == "KTE")})
        let treDataset = dataset.filter({$0.type == "TRE"})
        let tcuDataset = dataset.filter({$0.type == "TCU"})
        let mcuDataset = dataset.filter({$0.type == "MCU"})
        let kteDataset = dataset.filter({$0.type == "KTE"})
        let ktuDataset = dataset.filter({$0.type == "KTU"})

        print("Total Events: \(dataset.count)\n")
        print("Events Consumed by Application: \(consumedDataset.count)")
        print("TRE: \(treDataset.count)")
        print("KTE: \(kteDataset.count)\n")
        print("Events Produced by Application: \(dataset.count - consumedDataset.count)")
        print("TCU: \(tcuDataset.count)")
        print("KTU: \(ktuDataset.count)")
        print("MCU: \(mcuDataset.count)\n")
        print("Execution Time: \(String(describing: dataset.last?.date.timeIntervalSince((dataset.first?.date)!)))")
        
        dataset.forEach({print("\($0.toString())")})
        

    }
}





