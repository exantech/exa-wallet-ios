//
//  MoneroLibraryIntegrationTest.swift
//  EXAWalletTests
//
//  Created by Igor Efremov on 19/06/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import XCTest

class MoneroLibraryIntegrationTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLibraryIntegration() {
        let wrapper = MoneroWrapper(true)
        XCTAssert(wrapper.testTrue())
        XCTAssert(!wrapper.testFalse())
    }
}
