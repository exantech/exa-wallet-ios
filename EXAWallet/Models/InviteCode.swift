//
// Created by Igor Efremov on 01/02/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class InviteCode {
    static let fixedLength = 96
    private var _value: String? = nil

    var value: String {
        return _value ?? ""
    }

    init?(value: String?) {
        guard let v = value else { return nil }
        guard InviteCode.fixedLength == v.length else { return nil }
        _value = v
    }
}
