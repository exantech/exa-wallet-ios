//
// Created by Igor Efremov on 02/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol Address {
    var addressString: String { get }
    var isValid: Bool { get }
}
