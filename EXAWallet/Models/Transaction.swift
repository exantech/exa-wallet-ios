//
// Created by Igor Efremov on 26/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol TransactionAttributesList: class {
    func txAttribute(by attribute: TransactionAttribute) -> String?
    func attribute(by index: Int) -> TransactionAttribute
    func notEmptyAttributesCount() -> Int
}

enum TransactionAttribute: Int {
    case date = 0, amount, txHash, destination, confirmations, fee, paymentId, viewInBlockchainAction
    static let all = [date, destination, amount, txHash, fee, confirmations, paymentId, viewInBlockchainAction]
    static let orderedList = [destination, date, fee, txHash, confirmations, paymentId, viewInBlockchainAction]

    var type: EXATableCellInfoType {
        switch self {
        case .viewInBlockchainAction:
            return .action
        default:
            return .content
        }
    }

    var description: String {
        switch self {
            case .destination:
                return "To"
            case .date:
                return "When"
            case .amount:
                return "Amount"
            case .txHash:
                return "Tx hash"
            case .confirmations:
                return "Confirmations"
            case .fee:
                return "Fee"
            case .paymentId:
                return "Payment Id"
            case .viewInBlockchainAction:
                return l10n(.viewInBlockchain)
        }
    }

    var height: Int {
        switch self {
        case .txHash, .paymentId:
            return 98
        case .destination:
            return 128
        case .viewInBlockchainAction:
            return 80
        default:
            return 60
        }
    }
}

class Transaction {
    var txHash: String = ""
    var destination: String = ""
    var ticker: CryptoTicker = .XMR
    var amountString: String?
    var feeString: String?
    var amount: NSDecimalNumber?
    var type: TransactionType = .received
    var timestamp: TimeInterval = 0
    var confirmations: UInt64 = 0
    var date: String {
        return Date(timeIntervalSince1970: timestamp).formattedWith(EXAWalletFormatter.transactionDateFormat)
    }

    var paymentId: String?

    init() {}

    init(_ txHash: String, _ amount: NSDecimalNumber?, _ timestamp: TimeInterval, _ type: TransactionType) {
        self.txHash = txHash
        self.amount = amount
        self.timestamp = timestamp
        self.type = type
    }
}

extension Transaction: TransactionAttributesList {
    func txAttribute(by attribute: TransactionAttribute) -> String? {
        switch attribute {
        case .destination:
            return destination
        case .txHash:
            return txHash
        case .confirmations:
            return String(confirmations)
        case .amount:
            let theAmount = EXAWalletFormatter.formattedAmount(amountString) ?? "?"
            return "\(theAmount) \(CryptoTicker.XMR.description)"
        case .date:
            return date
        case .fee:
            if type == .received {
                return nil
            }

            let theAmount = EXAWalletFormatter.formattedAmount(feeString) ?? "?"
            return "\(theAmount) \(CryptoTicker.XMR.description)"
        case .paymentId:
            return (paymentId != String(repeating: "0", count: 16) ? paymentId : nil)
        case .viewInBlockchainAction:
             return txHash
        }
    }

    func notEmptyAttributesCount() -> Int {
        var result = 0
        for attrName in TransactionAttribute.orderedList {
            if let theAttribute = txAttribute(by: attrName), theAttribute.length > 0 {
                result += 1
            }
        }

        return result
    }

    func attribute(by index: Int) -> TransactionAttribute {
        let attrs = TransactionAttribute.orderedList.filter{txAttribute(by: $0) != nil && txAttribute(by: $0) != ""}
        return attrs[index] // TODO: check for out-of-boundary
    }
}
