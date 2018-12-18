//
// Created by Igor Efremov on 13/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class MultiSigTestWallet: BaseCryptoWallet, MultisignatureWallet {
    var mnemonic: String {
        guard let multisigMnemonic = EXACommon.loadApiKey(MoneroCommonConstants.multisigMnemonicFile) else {
            return ""
        }
        
        return multisigMnemonic
    }

    var publicAddress: String {
        return "47S6zbYntp1hbKqDJRGozWiGwYCVicGccLNCpLYriHRHAFzTWUvpZzNQVmt7wRnBZv7A5HbaGySJmgvKeWH1GLqiS5UrqAb"
    }

    var signatures: UInt {
        return 2
    }

    var participants: UInt {
        return 3
    }

    var confirmed: Bool {
        return false
    }

    init() {
        print("=== INIT MultiSigTestWallet ===")
        print("==== Using Scheme \(signatures) of \(participants)")
    }

}
