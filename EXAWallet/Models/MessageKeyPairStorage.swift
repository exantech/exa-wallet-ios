//
// Created by Igor Efremov on 2019-02-15.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class MessageKeyPairStorage: MessageKeyPairProvider {

    func saveEncodingKeys(publicKey: String, secretKey: String, for walletId: String) {
        UserDefaults.standard.set(publicKey, forKey: compositeKey(.oldPubKey, walletId))
        UserDefaults.standard.set(secretKey, forKey: compositeKey(.oldSecretKey, walletId))
    }

    func encodingKeys(for walletId: String) -> (String?, String?) {
        let pubKey = UserDefaults.standard.string(forKey: compositeKey(.oldPubKey, walletId))
        let secretKey = UserDefaults.standard.string(forKey: compositeKey(.oldSecretKey, walletId))

        return (pubKey, secretKey)
    }

    private func compositeKey(_ key: EXAWalletDefaults, _ walletId: String) -> String {
        return "\(key.rawValue)_\(walletId)"
    }
}
