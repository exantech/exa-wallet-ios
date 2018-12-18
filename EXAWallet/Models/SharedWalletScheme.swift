//
// Created by Igor Efremov on 2018-08-21.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

struct SharedWalletScheme {
    var signers: UInt
    var participants: UInt
    let minParticipants: UInt = 2
    let maxParticipants: UInt = 7

    func isValid() -> Bool {
        return participants >= minParticipants && participants >= signers && maxParticipants >= participants
    }

    var level: UInt {
        return participants - signers
    }

    func isMofN() -> Bool {
        guard isValid() else { return false }
        return level > 1
    }

    func isNofN() -> Bool {
        guard isValid() else { return false }
        return level == 0
    }

    init(_ signers: UInt, _ participants: UInt) {
        self.signers = signers
        self.participants = participants
    }
}

extension SharedWalletScheme {
    static var None: SharedWalletScheme {
        return SharedWalletScheme(0, 0)
    }
}

