//
// Created by Igor Efremov on 2019-02-06.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

final class EXAMessageEncoder {
    private let encryptor = EXAMessageEncryptor()

    init() {}

    func encode(msg: String, senderPublicKey: String, senderSecretKey: String, recipientPublicKeys: [String]) -> EncodedMessage {
        let seed = EXAMath.seed()
        var payload = [String: String]()
        for pubKey in recipientPublicKeys {
            let encMessage = encryptor.encryptMessage(msg,
                    senderSecretKey: senderSecretKey, recipientPublicKey: pubKey, seed: seed)
            payload[pubKey] = encMessage
        }

        return EncodedMessage(sender: senderPublicKey, seed: seed, payload: payload)
    }

    func decode(_ encoded: EncodedMessage, recipientPublicKey: String, recipientSecretKey: String) -> String? {
        guard let encodedMessageForRecipient = encoded.payload[recipientPublicKey] else { return nil }
        print(encodedMessageForRecipient )

        return encryptor.decryptMessage(encodedMessageForRecipient, recipientSecretKey: recipientSecretKey, senderPublicKey: encoded.sender, seed: encoded.seed)
    }
}
