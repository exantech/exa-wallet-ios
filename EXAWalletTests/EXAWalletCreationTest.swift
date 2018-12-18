//
//  EXAWalletCreationTest.swift
//  EXAWallet
//
//  Created by Igor Efremov on 16/08/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import XCTest

class EXAWalletCreationTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreatePersonalWallet() {
        let walletName = "EXA Test Wallet"
        let exists = EXAWalletTestUtils.isWalletWithSameNameAlreadyExist(walletName)
        guard exists == false else {
            XCTAssert(false, "Wallet name '\(walletName)' already exists in meta")
            return
        }

        let walletMetaInfo = WalletMetaInfo(walletName)
        let walletInfo = WalletCreationInfo(meta: walletMetaInfo, password: MoneroCommonConstants.testDefaultPassword, remoteNodeAddress: "monero-stagenet.exan.tech:38081")

        let result = WalletManager.shared.createWallet(walletInfo)

        XCTAssert(result.0, result.1)
        XCTAssert(EXAWalletFileManager.shared.isWalletFileExist(walletMetaInfo.uuid), "Wallet file not exist")
        XCTAssert(EXAWalletFileManager.shared.isWalletKeysFileExist(walletMetaInfo.uuid), "Wallet keys file not exist")
    }

    func testCreateSharedWallet() {
        let walletName = "EXA Test Shared Wallet"
        let exists = EXAWalletTestUtils.isWalletWithSameNameAlreadyExist(walletName)
        guard exists == false else {
            XCTAssert(false, "Wallet name '\(walletName)' already exists in meta")
            return
        }

        let correctWalletMetaInfo = WalletMetaInfo(walletName, type: WalletType.shared, color: WalletColor.magenta, signatures: 2, participants: 2)
        XCTAssertNotNil(correctWalletMetaInfo, "Can't create meta with valid (2 of 2) wallet scheme")
        guard let _ = correctWalletMetaInfo else { return }

        let invalidWalletMetaInfo = WalletMetaInfo(walletName, type: WalletType.shared, color: WalletColor.magenta, signatures: 3, participants: 2)
        XCTAssertNil(invalidWalletMetaInfo, "Created meta with invalid (3 of 2) wallet scheme")
        guard invalidWalletMetaInfo == nil else { return }

        let walletMetaInfo = WalletMetaInfo(walletName, type: WalletType.shared, color: WalletColor.magenta, signatures: 2, participants: 3)
        XCTAssertNotNil(walletMetaInfo, "Can't create meta with (2 of 3) params")

        if let theWalletMetaInfo = walletMetaInfo {
            XCTAssertEqual(theWalletMetaInfo.type, WalletType.shared, "Wallet type is not shared")
            XCTAssertEqual(theWalletMetaInfo.signatures, 2, "Wallet signatures count error")
            XCTAssertEqual(theWalletMetaInfo.participants, 3, "Wallet participants count error")

            let walletInfo = WalletCreationInfo(meta: theWalletMetaInfo, password: MoneroCommonConstants.testDefaultPassword, remoteNodeAddress: "monero-stagenet.exan.tech:38081")
            let result = WalletManager.shared.createWallet(walletInfo)

            XCTAssert(result.0, result.1)
            XCTAssertNotNil(result.2, "Wallet is nil")
            XCTAssert(EXAWalletFileManager.shared.isWalletFileExist(theWalletMetaInfo.uuid), "Wallet file not exist")
            XCTAssert(EXAWalletFileManager.shared.isWalletKeysFileExist(theWalletMetaInfo.uuid), "Wallet keys file not exist")
        }
    }
}
