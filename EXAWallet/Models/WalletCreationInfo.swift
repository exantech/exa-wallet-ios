//
// Created by Igor Efremov on 04/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

struct WalletCreationInfo {
    var meta: WalletMetaInfo

    var password: String
    var remoteNodeAddress: String
    var creationOption: EXAMoneroWalletCreateOption
    var mnemonic: String? // empty if creationOption == .create

    init(meta: WalletMetaInfo, password: String, remoteNodeAddress: String,
         creationOption: EXAMoneroWalletCreateOption = .restore, mnemonic: String? = nil) {
        self.meta = meta
        self.password = password
        self.remoteNodeAddress = remoteNodeAddress
        self.creationOption = creationOption
        self.mnemonic = mnemonic
    }
}
