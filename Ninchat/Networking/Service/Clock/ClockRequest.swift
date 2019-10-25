//
//  ClockRequest.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation

struct ClockRequest: Request {
    var path: String = "/501/clock"
    var headers: [String : String]? = RequestHeaderImpl().headers
    var bodyJSON: RequestBody?
    
    init(act: String, nonce: String) {
        bodyJSON = RequestBody(act: act, nonce: nonce, signature: RequestBody.generateSignature(path, act, nonce), timeout: 0, offset: 0)
    }
}
