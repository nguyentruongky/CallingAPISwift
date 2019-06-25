//
//  ServiceConnector.swift
//  WorkshopFixir
//
//  Created by Ky Nguyen on 12/28/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import Foundation
import Alamofire

struct ApiConnector {
    static private var connector = AlamofireConnector()
    static private func getHeaders() -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "access_token":  "your access token or api key"
        ]
    }
    static private func getUrl(from api: String) -> URL? {
        let BASE_URL = ""
        let apiUrl = api.contains("http") ? api : BASE_URL + api
        return URL(string: apiUrl)
    }
    
    static func request(_ api: String,
                        method: HTTPMethod,
                        params: [String: Any]? = nil,
                        headers: [String: String]? = nil,
                        successJsonAction: ((_ result: AnyObject) -> Void)? = nil,
                        successDataAction: ((Data) -> Void)? = nil,
                        failAction: ((_ error: knError) -> Void)? = nil) {
        let finalHeaders = headers ?? getHeaders()
        let apiUrl = getUrl(from: api)
        connector.run(withApi: apiUrl,
                      method: method,
                      params: params,
                      headers: finalHeaders,
                      successJsonAction: successJsonAction,
                      successDataAction: successDataAction,
                      failAction: failAction)
    }
}

struct AlamofireConnector {
    fileprivate func run(withApi api: URL?,
                         method: HTTPMethod,
                         params: [String: Any]? = nil,
                         headers: [String: String]? = nil,
                         successJsonAction: ((_ result: AnyObject) -> Void)? = nil,
                         successDataAction: ((Data) -> Void)? = nil,
                         failAction: ((_ error: knError) -> Void)?) {
        guard let api = api else {
            failAction?(InvalidAPIError(api: "nil"))
            return
        }
        let encoding: ParameterEncoding = method == .get ?
            URLEncoding.queryString :
            JSONEncoding.default
        Alamofire.request(api, method: method,
                          parameters: params,
                          encoding: encoding,
                          headers: headers)
            .responseJSON { (returnData) in
                self.answer(response: returnData,
                            successJsonAction: successJsonAction,
                            successDataAction: successDataAction,
                            failAction: failAction)
        }
    }
    
    private func answer(response: DataResponse<Any>,
                        successJsonAction: ((_ result: AnyObject) -> Void)? = nil,
                        successDataAction: ((Data) -> Void)? = nil,
                        failAction fail: ((_ error: knError) -> Void)?) {
        if let statusCode = response.response?.statusCode {
            if statusCode == 500 {
                return
            }
            // handle status code here: 401 -> show logout; 500 -> show error
        }
        
        if let error = response.result.error {
            let err = knError(code: "unknown", message: error.localizedDescription)
            fail?(err)
            return
        }
        
        guard let json = response.result.value as AnyObject?, let data = response.data else {
            // handle unknown error
            return
        }
        
        // handle special error convention from server
        // ...
        
        if let successDataAction = successDataAction {
            successDataAction(data)
            return
        }
        successJsonAction?(json)
    }
}

class knError {
    var code: String = "unknown"
    var message: String?
    var rawData: AnyObject?
    var displayMessage: String {
        return message ?? code
    }
    
    init() {}
    init(code: String, message: String? = nil, rawData: AnyObject? = nil) {
        self.code = code
        self.message = message
        self.rawData = rawData
    }
}

class InvalidAPIError: knError {
    private override init() {
        super.init()
    }
    
    private override convenience init(code: String, message: String? = nil, rawData: AnyObject? = nil) {
        self.init()
    }
    convenience init(api: String) {
        self.init()
        code = "404"
        message = "Invalid API Endpoint"
        rawData = api as AnyObject
    }
}
