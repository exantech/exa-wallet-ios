//
// Created by Igor Efremov on 2019-02-15.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class MessageKeysManager {

    func savePersonalWalletKeys(storage: MessageKeyPairProvider) -> Bool {
        // TODO remove dependencies
        guard let theWallet = AppState.sharedInstance.currentWallet else { return false }
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }

        let pk = theWallet.publicSpendKey()
        let sk = theWallet.secretSpendKey()

        storage.saveEncodingKeys(publicKey: pk, secretKey: sk, for: meta.metaInfo.uuid)

        return true
    }
}
