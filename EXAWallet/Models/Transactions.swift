//
// Created by Igor Efremov on 26/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class Transactions {
    private var transactionsList: [Transaction] = [Transaction]()
    var count: Int {
        return transactionsList.count
    }

    init() {}

    func load(items: [Transaction]?) {
        guard let theItems = items else { return }

        transactionsList.removeAll()
        transactionsList.append(contentsOf: theItems)

        transactionsList.sort(by: {$0.timestamp > $1.timestamp} )
    }

    func add(_ item: Transaction) {
        transactionsList.append(item)
    }

    func item(_ index: Int) -> Transaction? {
        return transactionsList[index]
    }

    func clear() {
        return transactionsList.removeAll()
    }
}
