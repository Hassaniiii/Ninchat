//
//  SecurityWrapperTests.swift
//  NinchatTests
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import XCTest
@testable import Ninchat

class SecurityWrapperTests: XCTestCase {

    override func setUp() { }

    override func tearDown() { }

    func testRandomNumberGenerator() {
        let nonce1 = String.randomNumberGenerator
        let nonce2 = String.randomNumberGenerator
        
        XCTAssertNotEqual(nonce1, nonce2)
    }
    
    // The test is validated by 'https://base64.guru/converter/decode/hex'
    func testHexToBase64() {
        let signature = "8e9ed28ce3abe1ccd14e27c2a37d2ac74b19008c3d3d6faf569b1b3f4f6941a6"
        XCTAssertEqual(signature.base64, "jp7SjOOr4czRTifCo30qx0sZAIw9PW+vVpsbP09pQaY=")
    }
    
    // The test is validated by the server running on the localhost
    func testSHA256() {
        let path = "/501/audit"
        let act = "burble"
        let nonce = "nonce"
        
        let signatureRawString = RequestBody.signatureRawString(path, act, nonce)
        XCTAssertNotNil(signatureRawString.sha256_generator)

        let signatureData = try? Data(XCTUnwrap(signatureRawString.sha256_generator))
        let signatureHexString = signatureData?.hexString
        XCTAssertNotNil(signatureHexString)
        
        XCTAssertEqual("MwOaE2Yzti3YmyBZ83EkCszuux6dzMBC+5MR1z9KE3Q=".lowercased(), signatureHexString?.base64?.lowercased())
    }
}
