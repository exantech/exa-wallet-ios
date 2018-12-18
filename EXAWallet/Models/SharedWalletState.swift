//
// Created by Igor Efremov on 04/02/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation


struct SharedWalletState {
    var status: String = ""
    var signers: UInt = 0
    var participants: UInt = 0
    var joined: UInt = 0
    var publicKeys: [String]?

    func isValid() -> Bool {
        return participants >= 2 && participants >= signers
    }

    func isCompleted() -> Bool {
        return isValid() && joined == participants
    }

    func isReady() -> Bool {
        return isCompleted() && status == "ready"
    }
}

extension SharedWalletState {
    static var None: SharedWalletState {
        return SharedWalletState(status: "", signers: 0, participants: 0, joined: 0, publicKeys: nil)
    }
}
