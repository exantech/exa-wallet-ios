//
// Created by Igor Efremov on 21/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum EXAMultisignatureWalletAPIEndPoint: String {
    case auth, create_wallet, join_wallet, scheme, wallet_scheme, push_register, multisig, multisig_info, change_public_key, extra_multisig_info, extra_multisig, wallet, ready, outputs, tx_proposals, decision

    var endPoint: String {
        switch self {
        case .push_register:
            return "push/register"
        default:
            return self.rawValue
        }
    }
}

enum EXAAPISupportedProtocols: String {
    case PairwiseDH
}

