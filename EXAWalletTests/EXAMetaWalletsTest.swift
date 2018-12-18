//
//  EXAMetaWalletsTest.swift
//  EXAWallet
//
//  Created by Igor Efremov on 20/08/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import XCTest

class EXAMetaWalletsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMetaNotYetCreated() {
        let service = EXAWalletMetaInfoStorageService()
        XCTAssertFalse(service.isMetaExists(), "Meta exists. Tests are not isolated!")
    }
    
    func testIsWalletWithSameNameAlreadyExist() {
        let service = EXAWalletMetaInfoStorageService()
        let walletName = "Test unique wallet"
        let exaWalletName = "EXA Test Shared Wallet"

        guard service.load() == true else {
            XCTAssert(false, "Meta not loaded")
            return
        }

        let result0 = service.isAlreadyExist(walletName)
        XCTAssertFalse(result0, "Wallet name '\(walletName)' already exists in meta")

        let result1 = service.isAlreadyExist(exaWalletName)
        XCTAssert(result1, "Wallet name '\(exaWalletName)' doesn't exist in meta")
    }
    
}
