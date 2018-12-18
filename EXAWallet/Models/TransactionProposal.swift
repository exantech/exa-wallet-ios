//
// Created by Igor Efremov on 12/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class TransactionProposal {
    private var _to: String?

    var ticker: CryptoTicker = .XMR
    var identifier: String?
    var to: String {
        return _to ?? ""
    }
    var amountString: String {
        if let wallet = AppState.sharedInstance.currentWallet {
            return wallet.formatAmount(amount)
        }

        return ""
    }
    var amount: UInt64 = 0
    var timestamp: TimeInterval = 0
    var description: String = ""
    var date: String {
        return Date(timeIntervalSince1970: timestamp).formattedWith(EXAWalletFormatter.transactionDateFormat)
    }

    var lastSignedTransaction: String = ""
    var approvals: [String]?
    var approvalsCount: UInt {
        return UInt(approvals?.count ?? 0)
    }

    var alreadySigned: Bool = false
    func isAlreadySigned(_ publicKey: String) -> Bool {
        return approvals?.contains(publicKey) ?? false
    }

    var approved: Bool = false
    var rejected: Bool = false
    var relayed: Bool = false

    var completedForMe: Bool {
        return rejected || alreadySigned
    }
    
    var completed: Bool {
        return rejected || approved || relayed
    }

    init() {}

    init(identifier: String, to: String, lastSignedTransaction: String, _ amount: UInt64, _ timestamp: TimeInterval, _ description: String?) {
        self.identifier = identifier
        self._to = to
        self.lastSignedTransaction = lastSignedTransaction
        self.amount = amount
        self.timestamp = timestamp
        self.description = description ?? ""
    }
}
