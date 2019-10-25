//
//  Request.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get, post, delete, put
}

protocol Request {
    var path: String { get }
    var headers: [String:String]? { get }
    var bodyJSON: RequestBody? { get }
}

extension Request {
    var host: String {
//        "http://0.0.0.0:8181" //for test purposes
        return "https://ji.luupi.net"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var body: Data? {
        return try? JSONEncoder().encode(bodyJSON)
    }
}
