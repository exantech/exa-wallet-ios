//
// Created by Igor Efremov on 02/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol MoneroTransactionCreator {
    func createTransaction(to: Address, paymentId: String?, amount: Double?) -> (TransactionWrapper?, Bool, String)
    func createTransactionProposal(to: Address, paymentId: String?, amount: Double?) -> (Bool, String?)
}
