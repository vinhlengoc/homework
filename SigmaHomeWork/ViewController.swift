//
//  ViewController.swift
//  SigmaHomeWork
//
//  Created by Le Ngoc Vinh on 5/23/20.
//  Copyright © 2020 vinhln. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setStateUI()
        addTaskObserver()
        
    }

    @IBAction func startAction(_ sender: Any) {
        SigmaTask.shared.start()
    }
    
    @IBAction func stopAction(_ sender: Any) {
        SigmaTask.shared.stop()
    }
    
    private func setStateUI() {
        switch SigmaTask.shared.state {
        case .resumed:
            self.startBtn.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            self.stopBtn.setTitleColor(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), for: .normal)
            
        case .suspended:
            self.stopBtn.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
            self.startBtn.setTitleColor(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), for: .normal)
        }
    }
    
    private func showAlertError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func addTaskObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.OnTaskStartError), name: NSNotification.Name.SigmaTask.StartFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.OnTaskStarted), name: NSNotification.Name.SigmaTask.DidStart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.OnTaskStopped), name: NSNotification.Name.SigmaTask.DidStop, object: nil)
    }
    
    private func removeTaskObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func OnTaskStartError(notification: Notification) {
        guard let mess = notification.object as? String else {
            return
        }
        showAlertError(message: mess)
        
    }
    
    @objc func OnTaskStarted() {
        setStateUI()
    }
    
    @objc func OnTaskStopped() {
        setStateUI()
    }
    
    deinit {
        removeTaskObserver()
    }
    
}

