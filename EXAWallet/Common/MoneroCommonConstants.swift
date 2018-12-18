//
// Created by Igor Efremov on 13/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

struct MoneroCommonConstants {
    static let fabricApiKeyPath = "fabric.apikey"
    static let multisigMnemonicFile = "multisig_test.mnemonic"
    static let restoreMnemonicFile = "restore.mnemonic"
    static let testMnemonicFile = "test.mnemonic"
    
    // TODO: write test to control possible library changes
    static let multiExportSignature = "4d6f6e65726f206d756c7469736967206578706f7274"
#if TEST
    static let projectPath = "Projects/MySandBox/EXAWallet/EXAWallet/Resources/OnlyDebug"
    static let inviteCodeTxt = "invite_code.txt"
    static let receiveAddressTxt = "receive_address.txt"
    static let testProposals = "test_proposals.txt"

    static let testDefaultPassword = "12345678"
    static let testSendToAddress =
"52xFuevqEaHR1QQzoJ8LxUJAMnaQ2EPyHdMMKxLWjfNGdcUs7J1ReCTZS35Fwz2VWzVuV6fEgtsWhVMgenPMkN7LRabUUy9"
#endif
}
