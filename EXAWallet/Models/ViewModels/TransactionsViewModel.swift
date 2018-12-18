//
// Created by Igor Efremov on 27/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class TransactionsViewModel {
    var model: Transactions?

    func load() {
        if AppState.sharedInstance.usingMock {
            model = MockObjects.shared.transactions
        }
    }

    func load(history: TransactionsHistory?) {
        model = Transactions()
        model?.load(items: history?.transactions())
    }

    func clear() {
        model?.clear()
    }

    func isEmpty() -> Bool {
        guard let count = model?.count else { return true }
        return count == 0
    }
}
