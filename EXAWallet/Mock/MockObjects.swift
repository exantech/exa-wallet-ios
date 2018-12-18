//
// Created by Igor Efremov on 27/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class MockObjects {
    static let shared = MockObjects()
    private let _transactionsHistory = MockTransactionsHistory()

    var transactions: Transactions {
        return _transactionsHistory.transactions
    }

    var multisigWallet: MultiSigTestWallet = MultiSigTestWallet()

    init() {
        print("== INIT Mock object ==")
    }
}
