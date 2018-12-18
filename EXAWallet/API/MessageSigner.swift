//
// Created by Igor Efremov on 2019-02-21.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class MessageSigner: MessageSignerProtocol {
    private var _builder: EXAMessageSignatureBuilder
    private var _apiVersion: APIVersion

    init(_ signer: WalletSignerProtocol & DecoderBase58Protocol, apiVersion: APIVersion) {
        _builder = EXAMessageSignatureBuilder(signer)
        _apiVersion = apiVersion
    }

    func sign(message: String, key: String? = nil) -> String? {
        var result: String?
        if let theKey = key {
            result = _builder.sign(message: message, key: theKey)
        } else {
            let hasMultiSign = _builder.hasMultiSign()
            let alreadyTransformed = _builder.isTransformedToMulti()
            switch (_apiVersion, hasMultiSign) {
            case (.v1, true):
                result = _builder.multiSign(message: message)
            case (.v2, true):
                result = signWithStoredPersonalKey(message)
            default:
                if alreadyTransformed {
                    result = signWithStoredPersonalKey(message)
                } else {
                    result = signWithPersonalKey(message)
                }
            }
        }

        print("Signature: \(String(describing: result))")
        return result
    }

    private func signWithStoredPersonalKey(_ message: String) -> String? {
        guard let walletId = AppState.sharedInstance.currentWalletInfo?.metaInfo.uuid else { return nil }
        let keyPair = MessageKeyPair(keyProvider: MessageKeyPairStorage(), for: walletId)
        guard keyPair.isValid else { return nil }

        return _builder.sign(message: message, key: keyPair.secretKey)
    }

    private func signWithPersonalKey(_ message: String) -> String? {
        // TODO Remove AppState from here
        guard let wallet = AppState.sharedInstance.currentWallet else { return nil }
        return _builder.sign(message: message, key: wallet.secretSpendKey())
    }
}
