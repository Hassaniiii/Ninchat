//
//  HelperTests.swift
//  NinchatTests
//
//  Created by Hassaniiii on 10/25/19.
//  Copyright © 2019 Hassaniiii. All rights reserved.
//

import XCTest
@testable import Ninchat

class HelperTests: XCTestCase {

    override func setUp() { }

    override func tearDown() { }

    // the test is validate by `https://www.unixtimestamp.com/index.php`
    func testTimeIntervalToDateString() {
        let timeStamp = "1571944296"
        
        XCTAssertEqual(timeStamp.toDateString, "2019-10-24 22:11:36")
    }

}
