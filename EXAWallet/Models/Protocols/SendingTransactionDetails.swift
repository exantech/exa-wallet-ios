//
// Created by Igor Efremov on 02/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol SendingTransactionDetails {
    var from: Address? { get }
    var to: Address? { get }
    var amount: Double? { get }
    var paymentId: String? { get }
}
