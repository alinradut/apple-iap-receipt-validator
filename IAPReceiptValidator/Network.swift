//
//  Network.swift
//  IAPReceiptValidator
//
//  Created by clawoo on 07/08/2019.
//  Copyright © 2019 clawoo. All rights reserved.
//

import Foundation

class Network {
    
    enum NetworkError: Error {
        case invalidResponse
        case missingStatus
    }
    
    static let shared = Network()
    
    private let urlSession: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration)
    }
    
    func validate(receipt: String, password: String, useSandbox: Bool = false, completion: @escaping (([String : Any]?, Error?) -> Void)) {
        
        let serverURL = useSandbox ? URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")! : URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
        
        var dict = ["receipt-data" : receipt]
        if !password.isEmpty {
            dict["password"] = password
        }
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.invalidResponse)
                }
                return
            }
            
            do {
                guard let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                    throw NetworkError.invalidResponse
                }

                DispatchQueue.main.async {
                    completion(response, nil)
                }
            }
            catch (let error) {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }

        task.resume()
    }
}
