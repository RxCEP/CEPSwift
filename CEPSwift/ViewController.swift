//
//  ViewController.swift
//  CEPSwift
//
//  Created by George Guedes on 28/08/17.
//  Copyright © 2017 CEPSwift. All rights reserved.
//

import CoreMotion
import CoreLocation
import UIKit
import RxSwift

class ViewController: UIViewController, CLLocationManagerDelegate {
    // UILabels just to show on the screen the speed and the number of steps
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    // Here's the first thing you have to do when using CEPSwift. Creating an
    // event manager of your custom event class. Remeber that your custom event
    // class should conform with Event protocol
    var pedometerEvents = EventManager<PedometerEvent>()
    var locationEvents = EventManager<LocationEvent>()
    
    // Here's the managers that we have to declare in order to use
    // CoreMotion and CoreLocation framework
    let pedometerManager = CMPedometer()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        // Nothing special here, just configuring some attributes on the locationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        // Here we ask to receive location updates
        locationManager.startUpdatingLocation()
        
        // Here we ask to receive pedometer updates
        pedometerManager.startUpdates(from: Date(), withHandler: pedometerHandler(_:_:))
        
        // Here we set our walk and stop rules
        setRules()
    }
    
    func setRules() {
        // This rule assure that the person is walking in a regular walk speed
        let walkingRule1 = locationEvents
            .asStream()
            .filter(predicate: {$0.data.speed > 0.2 && $0.data.speed < 1.8})
        
        // This rule assure that the number of steps is increasing
        let walkingRule2 = pedometerEvents
            .asStream()
            .followedBy { (fst, snd) -> Bool in
                Int(fst.data.numberOfSteps) < Int(snd.data.numberOfSteps)
        }
        
        // When our first and second rules happen, user is walking! Let's
        // set our backgroung to blue!
        walkingRule1.merge(anotherObservable: walkingRule2).subscribe {
            self.setWalkBackground()
        }
        
        // When the speed is to low the user probably stop walking and when
        // the speed is to high, the user is probably in car, bicycle, train or
        // maybe a horse. Never know
        let stopWalkingRule = locationEvents
            .asStream()
            .filter(predicate: {$0.data.speed < 0.2 || $0.data.speed > 1.8})
        
        /// When our stopWalkingRule occurs, the user isn't walking! Let's set
        // our background to red!
        stopWalkingRule.subscribe { (location) in
            self.setStopBackground()
        }
    }
    
    // We have to implement this method to receive location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        // Discard if horizontal accuracy is too bad
        guard location.horizontalAccuracy < 20.0 else { return }
        
        // Let's add our event on the LocationEvent!
        locationEvents.addEvent(event: LocationEvent(data: location))
        // Just for testing puporse, let's display that on our label too
        self.speedLabel.text = "Speed: " + "\(location.speed)"
    }
    
    // Just to receive pedometer updates
    func pedometerHandler(_ pedometerData: CMPedometerData?, _ error: Error?) {
        guard let data = pedometerData else { return }
        
        // Let's add our event on the PedometerEvent!
        self.pedometerEvents.addEvent(event: PedometerEvent(data: data))
        // Just for testing puporse, let's display that on our label too
        DispatchQueue.main.async {
            self.stepsLabel.text = "Steps: " + "\(data.numberOfSteps)"
        }
    }
    
    // Our functions to set the background to blue if user is walking or to red if
    // user isn't walking
    func setWalkBackground() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.blue
        }
    }
    
    func setStopBackground() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.red
        }
    }
}
