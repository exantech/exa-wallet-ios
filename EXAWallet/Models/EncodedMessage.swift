//
// Created by Igor Efremov on 04/02/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias RecipientKey = String
typealias EncryptedString = String

class EncodedMessage: Jsonable {
    private var _sender: String
    private var _payload: [RecipientKey: EncryptedString]
    private var _seed: UInt32 = 0

    var sender: String {
        return _sender
    }

    var seed: UInt32 {
        return _seed
    }

    var payload: [RecipientKey: EncryptedString] {
        return _payload
    }

    init(sender: String, seed: UInt32, payload: [RecipientKey: EncryptedString]) {
        _sender = sender
        _seed = seed
        _payload = payload
    }

    func json() -> JSON? {
        let params: JSON? = ["seed": seed, "payload": payload]
        return params
    }
}
