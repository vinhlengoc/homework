//
//  Notifications.swift
//  SigmaHomeWork
//
//  Created by Le Ngoc Vinh on 5/23/20.
//  Copyright © 2020 vinhln. All rights reserved.
//

import Foundation

extension Notification.Name {
    public struct SigmaTask {

        /// Posted when a  sigma task  is started succesful.
        public static let DidStart = Notification.Name(rawValue: "com.sigma.notification.name.task.didStart")
        
        /// Posted when a  sigma task  is stopped.
        public static let DidStop = Notification.Name(rawValue: "com.sigma.notification.name.task.didStop")
        
        /// Posted when start sigma task with error.
        public static let StartFailed = Notification.Name(rawValue: "com.sigma.notification.name.task.startFailed")
        
        
    }
}
