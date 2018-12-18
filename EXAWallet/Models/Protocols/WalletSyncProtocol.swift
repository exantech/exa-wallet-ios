//
// Created by Igor Efremov on 09/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol WalletSyncProtocol {
    func initializeSync() -> Bool
    func sync(from block: UInt64) -> Bool
    func isConnectedToSync() -> Bool

    func currentSyncBlock() -> UInt64
    func hasUnconfirmed() -> Bool
}
