//
//  AccessRequest.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation

struct AccessRequest: Request {
    var path: String = "/501/access"
    var headers: [String : String]? = RequestHeaderImpl().headers
    var bodyJSON: RequestBody?
    
    init(act: String, nonce: String, timeout: Int = 250000) {
        bodyJSON = RequestBody(act: act, nonce: nonce, signature: RequestBody.generateSignature(path, act, nonce), timeout: timeout, offset: 0)
    }
}
