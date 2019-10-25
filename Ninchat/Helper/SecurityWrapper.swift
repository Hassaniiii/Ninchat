//
//  SecurityWrapper.swift
//  Ninchat
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import Foundation
import Cryptor

extension String {
    static var randomNumberGenerator: String {
        return "\(arc4random())"
    }
    
    private var hexData: Data? {
        var data = Data(capacity: self.count / 2)

        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        guard data.count > 0 else { return nil }

        return data
    }

    var base64: String? {
        return self.hexData?.base64EncodedString(options: [])
    }
    
    var sha256_generator: [UInt8]? {
        return Digest(using: .sha256).update(string: self)?.final()
    }
}

extension Data {
    var hexString: String {
        return map { String(format: "%02x", $0) }.joined()
    }
}
