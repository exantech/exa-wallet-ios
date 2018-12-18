//
// Created by Igor Efremov on 02/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol TransactionsService {
    func sendTransaction(_ currency: CryptoCurrency, details: SendingTransactionDetails) -> (Bool, String)
    func prepareAndSign(_ transaction: Transaction) -> Transaction
}
