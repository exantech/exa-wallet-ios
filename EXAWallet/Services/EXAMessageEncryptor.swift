//
// Created by Igor Efremov on 2019-02-06.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

final class EXAMessageEncryptor {
    private let wrapper = MoneroWrapper()

    func encryptMessage(_ msg: String, ephemeralKey: String) -> String {
        return wrapper.encryptMessage(msg, key: ephemeralKey)
    }

    func encryptMessage(_ msg: String, senderSecretKey: String, recipientPublicKey: String, seed: UInt32) -> String {
        let commonKey = evalCommonKey(senderSecretKey, recipientPublicKey)
        let ephemeralKey = evalEphemeralKey(commonKey, seed: seed)
        return encryptMessage(msg, ephemeralKey: ephemeralKey)
    }

    func decryptMessage(_ msg: String, ephemeralKey: String) -> String {
        return wrapper.decryptMessage(msg, key: ephemeralKey)
    }

    func decryptMessage(_ msg: String, recipientSecretKey: String, senderPublicKey: String, seed: UInt32) -> String {
        let commonKey = evalCommonKey(recipientSecretKey, senderPublicKey)
        let ephemeralKey = evalEphemeralKey(commonKey, seed: seed)
        return decryptMessage(msg, ephemeralKey: ephemeralKey)
    }

    func evalCommonKey(_ senderSecretKey: String, _ recipientPublicKey: String) -> String {
        return wrapper.commonKey(recipientPublicKey, secretKey: senderSecretKey)
    }

    func evalEphemeralKey(_ commonKey: String, seed: UInt32) -> String {
        return wrapper.ephemeralKey(commonKey, seed: seed)
    }
}
