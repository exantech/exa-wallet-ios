//
// Created by Igor Efremov on 13/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol MultisignatureWallet {
    var signatures: UInt { get }
    var participants: UInt { get }
    var confirmed: Bool { get }
}
