//
//  EXAMessageEncoderTest.swift
//  EXAWallet
//
//  Created by Igor Efremov on 2019-02-06.
//  Copyright © 2019 Exantech. All rights reserved.
//

import XCTest

class EXAMessageEncoderTest: XCTestCase {
    private var message = ""
    private var recipientPublicKeys: [String] = [String]()

    override func setUp() {
        message = "Test message"
        recipientPublicKeys = ["7b2606000f72ca931d3cfda1b84934f48dc055743e3eedf5cfedb26fad207fa8",
                               "5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc95"]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncodeMessage() {
        let encoder = EXAMessageEncoder()
        let encodedMessage = encoder.encode(msg: message, senderPublicKey: "7b2606000f72ca931d3cfda1b84934f48dc055743e3eedf5cfedb26fad207fa8",
                senderSecretKey: "1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e",
                recipientPublicKeys: recipientPublicKeys)

        XCTAssertEqual(encodedMessage.payload.count, 2, "Payload is not correct")
        XCTAssertNotNil(encodedMessage.payload[recipientPublicKeys.first ?? ""], "Empty payload for recipient: \(recipientPublicKeys.first)")
        XCTAssertNotNil(encodedMessage.payload[recipientPublicKeys.last ?? ""], "Empty payload for recipient: \(recipientPublicKeys.last)")
    }

    func testDecodeMessage() {
        let encoder = EXAMessageEncoder()
        let encodedMessage = encoder.encode(msg: message, senderPublicKey: "7b2606000f72ca931d3cfda1b84934f48dc055743e3eedf5cfedb26fad207fa8",
                senderSecretKey: "1e2d87c015b3dd6fb7276e6bf3ea2ff58ea3202f7384b43849f9dbe9e124070e",
                recipientPublicKeys: recipientPublicKeys)

        let decoded = encoder.decode(encodedMessage, recipientPublicKey: "5c88b480cb7ba4ba635b887c752d90f2046d4e37a5e7a9ead1c12baeffb6fc95",
                recipientSecretKey: "7bf7df68fe6e55dbc3e9b29e7101f434ea44f7177cc7b9c6a24b31de0a4f0305")
        XCTAssertEqual(message, decoded, "Messages after decode are not equal")
    }

}
