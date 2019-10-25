//
//  RequestHeader.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation

protocol RequestHeader {
    init(_ headerSet: HeaderSet)
}

extension RequestHeader {
    init() {
        self.init(.defaultHeader)
    }
}

struct RequestHeaderImpl: RequestHeader {
    
    public var headers: [String:String]! = [:]
    
    // MARK: - Initialization
    
    init(_ headerSet: HeaderSet) {
        if headerSet == .defaultHeader {
            self.headers = self.commonHeaders
        }
    }
    
    // MARK: - Header derivation
    
    private var commonHeaders: [String:String] {
        return [HeaderType.contentType.rawValue: ContentType.applicationJSON.rawValue]
    }
}


enum HeaderSet {
    case defaultHeader
}

enum HeaderType: String {
    case contentType = "content-type"
}

enum ContentType: String {
    case applicationJSON = "application/json"
}
