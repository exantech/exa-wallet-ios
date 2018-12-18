//
// Created by Igor Efremov on 06/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class WalletInfo {
    static let hiddenBalance = "***"

    private var _metaInfo: WalletMetaInfo
    private var _balance: String
    private var _lockedBalance: String

    var metaInfo: WalletMetaInfo {
        return _metaInfo
    }

    var balance: String {
        if _metaInfo.hideBalance {
            return "\(WalletInfo.hiddenBalance) \(CryptoTicker.XMR)"
        }

        return "\(_balance) \(CryptoTicker.XMR)"
    }

    var lockedBalance: String {
        return _lockedBalance
    }

    init(_ metaInfo: WalletMetaInfo, balance: String = "0.00", lockedBalance: String = "0.00") {
        _metaInfo = metaInfo
        _balance = balance
        _lockedBalance = lockedBalance
    }
}
