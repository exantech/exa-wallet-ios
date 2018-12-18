//
// Created by Igor Efremov on 15/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol MessageSignerProtocol {
    func sign(message: String, key: String?) -> String?
}

class EXAMessageSignatureBuilder {
    private var _signer: WalletSignerProtocol & DecoderBase58Protocol

    private init() {
        _signer = MockWalletSigner()
    }

    init(_ signer: WalletSignerProtocol & DecoderBase58Protocol) {
        _signer = signer
    }

    func sign(message: String, key: String) -> String? {
        let walletId = AppState.sharedInstance.currentWalletInfo?.metaInfo.uuid
        guard let result = _signer.sign(message: message, key: key, walletId: walletId) else { return nil }
        print("Signature: \(result)")
        return result
    }

    func multiSign(message: String) -> String? {
        guard let result = _signer.multiSign(message: message) else { return nil }
        print("Multi signature: \(result)")
        return result
    }

    func hasMultiSign() -> Bool {
        return _signer.hasMultiSign()
    }

    func isTransformedToMulti() -> Bool {
        return _signer.isTransformedToMulti()
    }

    func hexSignRepresentation(base58Signature: String) -> String? {
        return base58Signature // backend sign processing changed, no changes for sign on client
    }
}
