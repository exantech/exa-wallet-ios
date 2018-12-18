//
// Created by Igor Efremov on 02/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class MoneroAddress: Address {
    private var _address: String
    
    var isValid: Bool {
        return _address.length > 0
    }

    var addressString: String {
        get {
            return _address
        }
    }

    init(_ value: String) {
        _address = value
    }
}
