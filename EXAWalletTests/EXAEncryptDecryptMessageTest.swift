//
//  EXAEncryptDecryptMessageTest.swift
//  EXAWallet
//
//  Created by Igor Efremov on 2019-02-04.
//  Copyright © 2019 Exantech. All rights reserved.
//

import XCTest

class EXAEncryptDecryptMessageTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEvalCommonKey() {
        let enc = EXAMessageEncryptor()

        let commonKey = enc.evalCommonKey("1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e",
                "5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc95")
        XCTAssertEqual("4a4478df1821aaa005597808a9b9068f180f6daa354395320028d2eee205eff8", commonKey, "Common key is incorrect. Main case")

        let commonSwapKey = enc.evalCommonKey("5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc95",
                "1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e")
        XCTAssertNotEqual("4a4478df1821aaa005597808a9b9068f180f6daa354395320028d2eee205eff8", commonSwapKey, "Common key is incorrect. Swap case")

        let keyForSame = enc.evalCommonKey("5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc95",
                "5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc95")
        XCTAssertEqual("b2cfe5a793cd0cae22220d5daf9a913e595c7b919004fc46c1a2f2781f885dea", keyForSame, "Common key is incorrect for same keys (5c88...)")

        let anotherKeyForSame = enc.evalCommonKey("1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e",
                "1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e")
        XCTAssertNotEqual("b2cfe5a793cd0cae22220d5daf9a913e595c7b919004fc46c1a2f2781f885dea", anotherKeyForSame, "Common key is incorrect for same keys (1e2d...)")

        let emptyKey = enc.evalCommonKey("1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e90",
                "5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc9575")
        XCTAssertEqual("", emptyKey, "Result isn't empty")
    }

    func testEvalEphemeralKey() {
        let enc = EXAMessageEncryptor()

        let testSeed = UInt32(1614858088)
        let testSeed2 = UInt32(1614858089)
        let commonKey = enc.evalCommonKey("1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e",
                "5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc95")

        let ephemeralKey = enc.evalEphemeralKey(commonKey, seed: testSeed)
        let ephemeralKey2 = enc.evalEphemeralKey(commonKey, seed: testSeed2)

        XCTAssertEqual("be3fe6d5907328c6c226b44cec3da1c1b66af6aefbf3984153ebef9a6b739c62", ephemeralKey, "Ephemeral key is incorrect")
        XCTAssertEqual("d67142d5b9bb5c7daa734bb7ab55bd383f9c84035896c915d7315e884354c2fa", ephemeralKey2, "Ephemeral key is incorrect")
    }

    func testCompareEphemeralKeysWithDifferentSeeds() {
        let enc = EXAMessageEncryptor()

        let firstSeed = EXAMath.seed()
        var secondSeed = EXAMath.seed()

        while firstSeed == secondSeed {
            secondSeed = EXAMath.seed()
        }

        let commonKey = enc.evalCommonKey("1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e", "5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc95")
        let wrapper = MoneroWrapper()

        let ephemeralKey = enc.evalEphemeralKey(commonKey, seed: firstSeed)
        let ephemeralKey2 = enc.evalEphemeralKey(commonKey, seed: secondSeed)

        XCTAssertNotEqual(ephemeralKey, ephemeralKey2, "Ephemeral keys are same for different seeds \(firstSeed) and \(secondSeed)")
    }

    func testEncryptMessageForEmpty() {
        let encryptor = EXAMessageEncryptor()
        let encryptedMsg = encryptor.encryptMessage("Hello, world!", senderSecretKey: "1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e",
                recipientPublicKey: "5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc95", seed: UInt32(1614858088))

        XCTAssertNotEqual(encryptedMsg, "", "Encrypted message is empty")
    }

    func testDecryptMessage() {
        let enc = EXAMessageEncryptor()
        let message = "Hello, world!"
        let testSeed = UInt32(1614858088)
        let commonKey = enc.evalCommonKey("1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e", "5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc95")
        let ephemeralKey = enc.evalEphemeralKey(commonKey, seed: testSeed)

        let encryptedMsg = enc.encryptMessage(message, ephemeralKey: ephemeralKey)
        let decryptedMsg = enc.decryptMessage(encryptedMsg, ephemeralKey: ephemeralKey)

        XCTAssertEqual(message, decryptedMsg, "Decrypted message isn't correct")
    }
}
