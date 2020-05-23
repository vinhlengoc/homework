//
//  SigmaTask.swift
//  SigmaHomeWork
//
//  Created by Le Ngoc Vinh on 5/23/20.
//  Copyright © 2020 vinhln. All rights reserved.
//

import Foundation
import MapKit

enum State {
    case suspended
    case resumed
}

class SigmaTask: NSObject {
    //location timer task
    var getLocationTask: SigmaTaskTimer?
    
    //battery timer task
    var getBatteryTask: SigmaTaskTimer?
    
    //submit data task
    lazy var submitTask: SubmitDataTask = SubmitDataTask()
    
    var locManager = CLLocationManager()
    
    // queue to update L list
    lazy var queue = DispatchQueue(label: "com.sigma.updatequeue", attributes: .concurrent)
    
    // state of current sigma task
    var state: State = .suspended
    
    // L list
    private var data: [String] = [] {
        didSet{
            // if submitData if L list exceeds 5 element
            if self.data.count > 5 {
                submitData()
            }
        }
    }
    
    //phone battery level
    var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    
    static let shared = SigmaTask()
    private override init(){
        
    }
    /// start collect location and battery information. Post `Notification.Name.SigmaTask.DidStart` when start successfull. Other wise post `Notification.Name.SigmaTask.StartFailed`
    func start() {
        if state == .resumed {
            return
        }
        
        //check location permission first. If denied, need to request permisson.
        if (checkIfLocationNotDetermine()){
            requestLocationPermission()
            return
        }else if (checkIfLocationDenied()) {
            NotificationCenter.default.post(name: Notification.Name.SigmaTask.StartFailed, object: "Location permission has been denied. Please enable in app setting.")
            return
        }
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        //init and start get userlocation task
        getLocationTask = SigmaTaskTimer.init(timeInterval: Constants.GET_LOCATION_TIME_INTERVAL, handleEvent: {
            [weak self] in
            self?.getUserLocationAndSave()
        })
        getLocationTask?.start()
        
        //init and start get getBattery task
        getBatteryTask = SigmaTaskTimer.init(timeInterval: Constants.GET_BATTERY_TIME_INTERVAL, handleEvent: {
            [weak self] in
            self?.getPhoneBatteryAndSave()
        })
        getBatteryTask?.start()
        
        state = .resumed
        NotificationCenter.default.post(name: Notification.Name.SigmaTask.DidStart, object: nil)
        
    }
    
    /// Stop task. Post `Notification.Name.SigmaTask.DidStop` when stopped
    func stop() {
        if state == .suspended {
            return
        }
        
        // delocate background currency task
        getLocationTask = nil
        getBatteryTask = nil
        submitTask.stop()
        state = .suspended
        NotificationCenter.default.post(name: Notification.Name.SigmaTask.DidStop, object: nil)
    }
    
    
    private func getUserLocationAndSave() {
//        print("getting user's location")
        guard let loc = self.getCoordinate() else {
            return
        }
        
        //because L list can be accessed from different threads, we use a concurrent queue with barrier to update L. Alternately, we can use a serial queue without barrier to update it as well (i.e: dispatchqueue.main).
        queue.async (flags: .barrier){
            self.data.append("\(loc)")
        }
        
    }
    
    private func getPhoneBatteryAndSave() {
//        print("getting phone battery")
        //because L list can be accessed from different threads, we use a concurrent queue with barrier to update L. Alternately, we can use a serial queue without barrier to update it as well (i.e: dispatchqueue.main).
        queue.async (flags: .barrier){
            self.data.append("\(self.batteryLevel)")
        }
    }
    
    private func submitData() {
        submitTask.enqueueToSubmit(data: data.description)
    }
    
    private func getCoordinate() -> (lat : CLLocationDegrees , long : CLLocationDegrees)?{
        if checkIfLocationPermitted(){
            guard let currentLocation = locManager.location else {
                return nil
            }
            
            return (currentLocation.coordinate.latitude , currentLocation.coordinate.longitude)
        }
        return nil
    }
    
    private func requestLocationPermission() {
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        
    }
    
    private func checkIfLocationPermitted() -> Bool {
        return CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse
    }
    private func checkIfLocationDenied() -> Bool {
        return CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied
    }
    private func checkIfLocationNotDetermine() -> Bool {
        return CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined
    }
    
    //call back for location permisionRequest
    private func locationStatusHasChanged() {
        // if permission granted, perform start task again.
        if self.checkIfLocationPermitted() {
            self.start()
        }else if self.checkIfLocationDenied() {
            // Sent event permission denied for displaying
            NotificationCenter.default.post(name: Notification.Name.SigmaTask.StartFailed, object: "Location permission has been denied. Please enable in app setting.")
        }
    }
    
}

extension SigmaTask : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location status = \(status.rawValue)")
        locationStatusHasChanged()
        
    }
}

