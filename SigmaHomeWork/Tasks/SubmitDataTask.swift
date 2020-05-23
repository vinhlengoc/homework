//
//  SubmitDataTask.swift
//  SigmaHomeWork
//
//  Created by Le Ngoc Vinh on 5/23/20.
//  Copyright © 2020 vinhln. All rights reserved.
//

import Foundation

class SubmitDataTask {
    lazy var queue = DispatchQueue(label: "com.sigma.submitQueue", attributes: .concurrent)
    var listTask: [URLSessionDataTask] = []

    init() {
    }
    
    /// enqueue data to submit to server.
    ///
    /// - parameter data: data you want to submit
    func enqueueToSubmit(data: String) {
        queue.async {
            self.submit(data: data)
        }
    }
    
    /// stop submit data to server.
    func stop() {
        self.listTask.forEach { (task) in
            task.cancel()
        }
        self.listTask.removeAll()
        
    }
    
    /// submit data to server. We can use Alamofire for better implementation
    private func submit(data: String) {
        guard let url = URL(string: Constants.SUBMIT_DATA_API_URL) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "data": data
        ]
        request.httpBody = parameters.percentEncoded()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // should handle data here
            print("push data successfull")
        }

        task.resume()
        
        // save to list task for stop action
        DispatchQueue.main.async {
            self.listTask.append(task)
        }
    }
    
    
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
