//
// Created by Igor Efremov on 2019-02-11.
// Copyright (c) 2019 EXANTE. All rights reserved.
//

import Foundation
import SwiftyJSON

class MoneroWalletMessageService {
    static let shared = MoneroWalletMessageService()

    private var _pubKeys: [String]
    private let _enc = EXAMessageEncoder()

    var recipientsCount: Int {
        return _pubKeys.count
    }

    private init() {
        _pubKeys = [String]()
    }

    func setupPublicKeys(_ pubKeys: [String]?) {
        _pubKeys.removeAll()

        guard let pk = pubKeys else { return }
        _pubKeys.append(contentsOf: pk)
    }

    func prepareEncodedPayload(_ message: String, keyPair: MessageKeyPair) -> SecureDataParam? {
        guard keyPair.isValid else { return nil }

        let encodedMessage = _enc.encode(msg: message, senderPublicKey: keyPair.pubKey,
                senderSecretKey: keyPair.secretKey, recipientPublicKeys: _pubKeys)

        return SecureDataParam(encodedMessage)
    }

    func decode(_ encodedMessages: [EncodedMessage], keyPair: MessageKeyPair) -> [String] {
        return encodedMessages.compactMap{decodeMessage($0, keyPair: keyPair)}
    }

    func decodeMessage(_ encodedMessage: EncodedMessage, keyPair: MessageKeyPair) -> String? {
        guard keyPair.isValid else { return nil }

        return _enc.decode(encodedMessage, recipientPublicKey: keyPair.pubKey,
                recipientSecretKey: keyPair.secretKey)
    }
}
