//
// Created by Igor Efremov on 2019-02-14.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class MessageKeyPair {
    private var _pubKey: String?
    private var _secretKey: String?

    var isValid: Bool {
        guard let _ = _pubKey, let _ = _secretKey else { return false }
        return true
    }

    var pubKey: String {
        return _pubKey ?? ""
    }

    var secretKey: String {
        return _secretKey ?? ""
    }

    init(keyProvider: MessageKeyPairProvider, for walletId: String) {
        let pair = keyProvider.encodingKeys(for: walletId)

        _pubKey = pair.0
        _secretKey = pair.1
    }
}
