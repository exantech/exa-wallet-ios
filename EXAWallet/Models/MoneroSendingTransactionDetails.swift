//
// Created by Igor Efremov on 02/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class MoneroSendingTransactionDetails: SendingTransactionDetails {
    private var _amount: Double?
    private var _to: MoneroAddress?
    private var _from: MoneroAddress?

    var paymentId: String?

    var from: Address? {
        return _from
    }
    var to: Address? {
        return _to
    }
    var amount: Double? {
        return _amount
    }

    init(amount: Double?, to: Address, from: Address) {
        _amount = amount
        _to = MoneroAddress(to.addressString)
        _from = MoneroAddress(from.addressString)
    }
}
