//
// Created by Igor Efremov on 07/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class EXAPaymentIdGenerator {

    func generatePaymentId() -> String {
        let left = UUID().uuidString.substring(0, length: 8)
        let right = UUID().uuidString.substring(0, length: 8)
        let result = (left + right).lowercased()

        return result
    }
}
