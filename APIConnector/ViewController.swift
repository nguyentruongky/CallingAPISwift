//
//  ViewController.swift
//  APIConnector
//
//  Created by Ky Nguyen on 6/25/19.
//  Copyright © 2019 Ky Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let api = "https://api.cryptonator.com/api/ticker/btc-usd"
        parseJson(api: api)
        decode(api: api)
    }
    
    func parseJson(api: String) {
        ApiConnector.request(api, method: .get, successJsonAction: { (json) in
            print(json)
        })
    }
    
    func decode(api: String) {
        ApiConnector.request(api, method: .get, successDataAction: { (data) in
            do {
                let result = try JSONDecoder().decode(Result.self, from: data)
                print(result.ticker.base)
            } catch let jsonErr {
                print("Fail to decode json", jsonErr)
            }
        })
    }
}

class Result: Codable {
    var error: String
    var success: Bool
    var timestamp: Double
    var ticker: Ticker
}

class Ticker: Codable {
    var base: String
    var change: String
    var target: String
    var volume: String
}

