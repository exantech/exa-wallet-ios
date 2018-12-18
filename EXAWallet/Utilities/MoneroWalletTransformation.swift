//
// Created by Igor Efremov on 2019-02-12.
// Copyright (c) 2019 EXANTE. All rights reserved.
//

import Foundation

class MoneroWalletTransformation {

    func transformToSharedWallet(_ wallet: MoneroWallet, multisigInfos: [String], signers: UInt, participants: UInt) -> (Bool, String) {
        guard signers <= participants else {
            return (false , "Incorrect wallet scheme: signers \(signers) of \(participants)")
        }

        guard participants == multisigInfos.count else {
            return (false , "Multisig info doesn't conform to participants count)")
        }

        print(multisigInfos)

        if let result = wallet.transformationIntoSharedWallet(participantsInfo: multisigInfos, signers: signers) {
            if result == "" {
                return (true, result)
            }

            if result != "" && multisigInfos.count > signers {
                return (true , result)
            }
        }

        return (false, "")
    }
}
