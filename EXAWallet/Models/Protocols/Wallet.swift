//
// Created by Igor Efremov on 15/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol Wallet {
    func create(_ walletFileName: String, password: String) -> (Bool, String)
    func open(_ walletUUID: String, password: String) -> (Bool, String?)
    func restore(_ walletUUID: String, mnemonic: String, password: String, blockHeight: UInt64?) -> (Bool, String)
    func mnemonic() -> String
    func publicAddress() -> String

    func isSynched() -> Bool
    func pauseSync()

    func formattedBalance() -> String
}
