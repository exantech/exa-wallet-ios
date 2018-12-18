//
// Created by Igor Efremov on 2019-04-16.
// Copyright (c) 2019 EXANTE. All rights reserved.
//

import Foundation

protocol SafeStorageWalletItem: class {
    func safeSave(value: String, walletId: String)
    func safeLoad(walletId: String) -> String?
}

class SharedWalletSeed: SafeStorageWalletItem {
    private let personalSeedKeyPrefix = "personalSeedKeyPrefix"

    private func key(_ walletId: String) -> String {
        return "\(personalSeedKeyPrefix)_\(walletId)"    
    }

    func safeSave(value: String, walletId: String) {
        let ss = SafeStorage()
        ss.save(key: key(walletId), value: value)
    }

    func safeLoad(walletId: String) -> String? {
        let ss = SafeStorage()
        return ss.load(key(walletId))
    }
}
