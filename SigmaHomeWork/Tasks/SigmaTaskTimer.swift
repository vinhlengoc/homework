//
//  SigmaTaskTimer.swift
//  SigmaHomeWork
//
//  Created by Le Ngoc Vinh on 5/23/20.
//  Copyright © 2020 vinhln. All rights reserved.
//

import Foundation
class SigmaTaskTimer {
    
    private var timeInterval: TimeInterval
    private var queue: DispatchQueue
    private var handleEvent: (()->())?
    private var state: State = .suspended

    
    init(timeInterval: TimeInterval, handleEvent: @escaping () -> ()) {
        self.queue = DispatchQueue(label: "com.sigma.concurrency", attributes: .concurrent)
        self.timeInterval = timeInterval
        self.handleEvent = handleEvent
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(queue: self.queue)
        timer.schedule(deadline: .now(), repeating: self.timeInterval)
        timer.setEventHandler(handler: { [weak self] in
            self?.handleEvent?()
        })
        return timer
    }()
    
    func start() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func stop() {
        if state == .suspended {
            return
        }
        timer.suspend()
        state = .suspended
    }
    
    deinit {
        print("Task has been deinit")
        timer.setEventHandler {}
        timer.cancel()
       /*
        If the timer is suspended, calling cancel without resuming
        triggers a crash. This is documented here
        https://forums.developer.apple.com/thread/15902
        */
        start()
        handleEvent = nil
    }
    
    
}

