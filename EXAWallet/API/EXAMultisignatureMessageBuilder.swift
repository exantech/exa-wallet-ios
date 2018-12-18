//
// Created by Igor Efremov on 15/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class EXAMultisignatureMessageBuilder {

    func buildMessage(data: String, sessionId: String, nonce: UInt64) -> String {
        return data + sessionId + String(nonce)
    }
}
