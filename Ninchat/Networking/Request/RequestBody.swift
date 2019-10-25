//
//  RequestBody.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation

struct RequestBody: Encodable {
    let act, nonce, signature: String
    let timeout, offset: Int
}

extension RequestBody {
    static var signatureRawString: ((String, String, String) -> String) = { path, act, nonce in
        return String(format: "%@\r\n%@\r\n%@\r\n%@", path, act, nonce, secret)
    }
    
    static var generateSignature: ((String, String, String) -> String) = { path, act, nonce in
        guard
            let signature = RequestBody.signatureRawString(path, act, nonce).sha256_generator,
            let signatureBase64 = Data(signature).hexString.base64
            
            else {
                fatalError("ERROR! Signature generation failed")
        }
        
        return signatureBase64
    }
}
