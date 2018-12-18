//
// Created by Igor Efremov on 26/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class MockTransactionsHistory {
    private var _transactions: Transactions
    var transactions: Transactions {
        return _transactions
    }

    init() {
        _transactions = Transactions()

        _transactions.add(Transaction("n1ijgnewiog", 0.85, 1530106031, .received))
        _transactions.add(Transaction("nmjg324wiog", 2.53, 1530106051, .received))
        _transactions.add(Transaction("nmijgn54iog", 1.43, 1530106081, .received))
        _transactions.add(Transaction("nm34gnewiog", 0.05, 1530106121, .sent))
    }
}
