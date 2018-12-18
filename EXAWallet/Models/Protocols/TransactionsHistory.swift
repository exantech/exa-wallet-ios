//
// Created by Igor Efremov on 28/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol TransactionsHistory {
    func transactions() -> [Transaction]?
}
