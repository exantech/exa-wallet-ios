//
// Created by Igor Efremov on 08/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol WalletBlockHeight {
    func blockHeight() -> UInt64
    func networkBlockHeight() -> UInt64
}
