//
// Created by Igor Efremov on 08/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum RestoreWalletStatus: Int {
    case none, in_progress, fail, completed
}

class RestoreWalletState {
    var blockHeight: UInt64? = nil
    var mnemonic: String? = nil
    var status: RestoreWalletStatus = .none
    var type: WalletType = .personal

    func preValidateMnemonic() -> Bool {
        guard let theMnemonic = mnemonic else { return false }
        let words: [String] = theMnemonic.split(separator: " ", omittingEmptySubsequences: true).map{String($0)}
        return words.count == 25
    }
}
