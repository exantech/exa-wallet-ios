//
//  EXAWalletRestoreTest.swift
//  EXAWallet
//
//  Created by Igor Efremov on 16/08/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import XCTest

class EXAWalletRestoreTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRestorePersonalWallet() {
        // 1. Create Personal
        let creationExpectation = XCTestExpectation(description: "Creating EXA Personal Wallet...")

        let walletMetaInfo = WalletMetaInfo("EXA Test Restore Wallet")
        var walletInfo = WalletCreationInfo(meta: walletMetaInfo, password: MoneroCommonConstants.testDefaultPassword, remoteNodeAddress: "monero-stagenet.exan.tech:38081")
        var mnemonic: String = ""

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let result = WalletManager.shared.createWallet(walletInfo)
            XCTAssert(result.0, result.1)

            if let wallet = result.2 {
                mnemonic = wallet.mnemonic()
            } else {
                XCTAssert(false, "Wallet is nil")
            }

            creationExpectation.fulfill()
        }

        let waitResult = XCTWaiter.wait(for: [creationExpectation], timeout: 8.0, enforceOrder: true)
        switch waitResult {
        case .completed:
            break
        case .timedOut:
            XCTAssert(false, "Time out")
        default:
            XCTAssert(false, "Some issue")
        }

        // 2. Delete
        XCTAssert(EXAWalletFileManager.shared.removeWalletFile(walletMetaInfo.uuid), "Remove Wallet files error")

        // 3. Restore
        walletInfo.mnemonic = mnemonic

        let result = WalletManager.shared.restore(walletInfo)
        XCTAssert(result.0, result.1)
    }

    func testRestoreSharedWallet() {
        // 1. Create Shared
        let creationExpectation = XCTestExpectation(description: "Creating EXA Shared Wallet...")

        let walletMetaInfo = WalletMetaInfo("EXA Test Shared Wallet", type: WalletType.shared, color: WalletColor.magenta, signatures: 2, participants: 3)
        XCTAssertNotNil(walletMetaInfo, "Can't create meta with (2 of 3) params")

        if let theWalletMetaInfo = walletMetaInfo {
            var walletInfo = WalletCreationInfo(meta: theWalletMetaInfo, password: MoneroCommonConstants.testDefaultPassword, remoteNodeAddress: "monero-stagenet.exan.tech:38081")
            var mnemonic: String = ""

            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let result = WalletManager.shared.createWallet(walletInfo)
                XCTAssert(result.0, result.1)

                if let wallet = result.2 {
                    mnemonic = wallet.mnemonic()
                } else {
                    XCTAssert(false, "Wallet is nil")
                }

                creationExpectation.fulfill()
            }

            let waitResult = XCTWaiter.wait(for: [creationExpectation], timeout: 8.0, enforceOrder: true)
            switch waitResult {
            case .completed:
                break
            case .timedOut:
                XCTAssert(false, "Time out")
            default:
                XCTAssert(false, "Some issue")
            }

            // 2. Delete
            XCTAssert(EXAWalletFileManager.shared.removeWalletFile(theWalletMetaInfo.uuid), "Remove Wallet files error")

            // 3. Restore
            walletInfo.mnemonic = mnemonic

            let result = WalletManager.shared.restore(walletInfo)
            XCTAssert(result.0, result.1)
        }

    }
    
}
