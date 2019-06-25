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
        ApiConnector.get(api, success: { rawData in
            print(rawData)
        })
        
        ApiConnector.get(api, returnData: { data in
            print(data)
        })
    }


}

