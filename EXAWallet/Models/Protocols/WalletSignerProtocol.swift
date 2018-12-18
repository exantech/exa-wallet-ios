//
// Created by Igor Efremov on 15/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol WalletSignerProtocol {
    func sign(message: String, key: String, walletId: String?) -> String?
    func multiSign(message: String) -> String?
    func hasMultiSign() -> Bool
    func isTransformedToMulti() -> Bool
}

class MockWalletSigner: WalletSignerProtocol, DecoderBase58Protocol {
    func sign(message: String, key: String, walletId: String?) -> String? {
        return "dead000000000000000000000000000000000000000000000000000000000000"
    }

    func multiSign(message: String) -> String? {
        return "dead000000000000000000000000000000000000000000000000000000000000"
    }

    func hasMultiSign() -> Bool {
        return false
    }

    func isTransformedToMulti() -> Bool {
        return false
    }

    func decodeBase58(_ encodedString: String) -> String? {
        return nil
    }
}
