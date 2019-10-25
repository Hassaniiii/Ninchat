//
//  Result.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation

enum APIError: Error {
    case noData
    case detailed(Int, String?)

    var reason: Reason? {
        switch self {
        case let .detailed(statusCode, _):
            return Reason(rawValue: statusCode)
        default:
            return nil
        }
    }
    
    var errorDescription: String? {
        switch self {
        case let .detailed(_, description):
            return description
        default:
            return nil
        }
    }
}

enum Reason: Int {
    case badRequest = 400
    case forbidden = 403
    case methodNotAllowed = 405
    case conflict = 409
    case serviceUnavailable = 503
    
    var description: String {
        switch self {
        case .badRequest: return "Bad Request"
        case .forbidden: return "Forbidden"
        case .methodNotAllowed: return "Method Not Allowed"
        case .conflict: return "Conflict"
        case .serviceUnavailable: return "Service Unavailable"
        }
    }
}
