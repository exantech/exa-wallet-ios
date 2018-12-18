//
// Created by Igor Efremov on 13/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol BaseCryptoWallet {
    var mnemonic: String { get }
    var publicAddress: String { get }
}
