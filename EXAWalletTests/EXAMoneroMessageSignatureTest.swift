//
//  EXAMoneroMessageSignatureTest.swift
//  EXAWalletTests
//
//  Created by Igor Efremov on 16/08/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import XCTest

class EXAMoneroMessageSignatureTest: XCTestCase {

    private func createSharedWallet() -> MoneroWallet? {
        let creationExpectation = XCTestExpectation(description: "Creating EXA Shared Wallet...")

        let walletMetaInfo = WalletMetaInfo("EXA Test Shared Wallet", type: WalletType.shared, color: WalletColor.magenta, signatures: 2, participants: 3)
        XCTAssertNotNil(walletMetaInfo, "Can't create meta with (2 of 3) params")

        var wallet: MoneroWallet? = nil
        if let theWalletMetaInfo = walletMetaInfo {
            let walletInfo = WalletCreationInfo(meta: theWalletMetaInfo, password: MoneroCommonConstants.testDefaultPassword, remoteNodeAddress: "monero-stagenet.exan.tech:38081")

            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let result = WalletManager.shared.createWallet(walletInfo)
                XCTAssert(result.0, result.1)

                wallet = result.2
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
        }

        return wallet
    }
    
    override func setUp() {
        super.setUp()

        // wallet = WalletManager.
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCheckMessageSignature() {
        let signPrefix = "SigV1"

        let wallet = createSharedWallet()
        XCTAssertNotNil(wallet, "Wallet is nil")

        let msg = "Test message for signature"
        guard let theWallet = wallet else { return }

        let signer: MessageSignerProtocol = EXAMessageSignatureBuilder(theWallet)
        let signWithPrefix = signer.sign(message: msg)

        XCTAssertNotNil(signWithPrefix, "Signature is nil")
        guard let theSignWithPrefix = signWithPrefix else { return }

        XCTAssert(theSignWithPrefix.hasPrefix(signPrefix), "Unknown signature prefix")

        let signature = theSignWithPrefix.substring(from: signPrefix.count)
        let hexRepresentation = theWallet.decodeBase58(signature)
        XCTAssertNotNil(hexRepresentation, "Hex sign representation is nil")
        guard let hexSign = hexRepresentation else { return }

        XCTAssertEqual(hexSign.count % 2, 0, "Invalid signature length")
        XCTAssertEqual(hexSign.count / 2, 64, "Invalid signature length")

        let result = theWallet.verifySignedMessage(message: msg, publicKey: theWallet.publicAddress(), signature: theSignWithPrefix)
        XCTAssert(result, "Signature mismatch")
    }

    func testSignaturesForSameMessage() {
        let wallet = createSharedWallet()

        guard let theWallet = wallet else {
            XCTAssert(false, "Wallet is nil")
            return
        }

        let msg = "Test message for signature"
        let signer: MessageSignerProtocol = EXAMessageSignatureBuilder(theWallet)

        let sign = signer.sign(message: msg)
        let anotherSignForSameMsg = signer.sign(message: msg)

        guard let theSign = sign else {
            XCTAssert(false, "Signature is nil")
            return
        }
        guard let theAnotherSignForSameMsg = anotherSignForSameMsg else {
            XCTAssert(false, "Signature is nil")
            return
        }

        XCTAssertNotEqual(theSign, theAnotherSignForSameMsg, "Signatures must be different")

        let result1 = theWallet.verifySignedMessage(message: msg, publicKey: theWallet.publicAddress(), signature: theSign)
        let result2 = theWallet.verifySignedMessage(message: msg, publicKey: theWallet.publicAddress(), signature: theAnotherSignForSameMsg)

        XCTAssert(result1, "Signature mismatch")
        XCTAssert(result2, "Another signature mismatch")
    }

    func testSignaturesForDifferentMessages() {
        let wallet = createSharedWallet()

        guard let theWallet = wallet else {
            XCTAssert(false, "Wallet is nil")
            return
        }

        let firstMsg  = "First message"
        let secondMsg = "Second message"
        let signer: MessageSignerProtocol = EXAMessageSignatureBuilder(theWallet)

        let firstSign = signer.sign(message: firstMsg)
        let secondSign = signer.sign(message: secondMsg)

        guard let theFirstSign = firstSign else {
            XCTAssert(false, "Signature is nil")
            return
        }
        guard let theSecondSign = secondSign else {
            XCTAssert(false, "Signature is nil")
            return
        }

        XCTAssertNotEqual(theFirstSign, theSecondSign, "Signatures must be different")

        // correct messages - correct signatures
        let result1 = theWallet.verifySignedMessage(message: firstMsg, publicKey: theWallet.publicAddress(), signature: theFirstSign)
        let result2 = theWallet.verifySignedMessage(message: secondMsg, publicKey: theWallet.publicAddress(), signature: theSecondSign)

        XCTAssert(result1, "First mismatch")
        XCTAssert(result2, "Second signature")

        // swap messages
        let result3 = theWallet.verifySignedMessage(message: secondMsg, publicKey: theWallet.publicAddress(), signature: theFirstSign)
        let result4 = theWallet.verifySignedMessage(message: firstMsg, publicKey: theWallet.publicAddress(), signature: theSecondSign)

        XCTAssertFalse(result3, "Not valid signature verified")
        XCTAssertFalse(result4, "Not valid signature verified")
    }

    func testHexSignRepresentation() {
        let wallet = createSharedWallet()

        guard let theWallet = wallet else {
            XCTAssert(false, "Wallet is nil")
            return
        }

        let msg = "Test message for signature"
        let signer = EXAMessageSignatureBuilder(theWallet)

        let sign = signer.sign(message: msg)

        guard let theSign = sign else {
            XCTAssert(false, "Signature is nil")
            return
        }

        let hexSign = signer.hexSignRepresentation(base58Signature: theSign)
        guard let theHex = hexSign else {
            XCTAssert(false, "Hex signature is nil")
            return
        }

        XCTAssertNotNil(theHex.hexData(), "Incorrect signature conversion to hex")
    }
}
