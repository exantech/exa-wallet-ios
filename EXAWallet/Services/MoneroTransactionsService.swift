//
// Created by Igor Efremov on 02/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class MoneroTransactionsService: TransactionsService {

    /*!
     * \brief createTransaction creates transaction. if dst_addr is an integrated address, payment_id is ignored
     * \param dst_addr          destination address as string
     * \param payment_id        optional payment_id, can be empty string
     * \param amount            amount
     * \param mixin_count       mixin count. if 0 passed, wallet will use default value
     * \param subaddr_account   subaddress account from which the input funds are taken
     * \param subaddr_indices   set of subaddress indices to use for transfer or sweeping. if set empty, all are chosen when sweeping, and one or more are automatically chosen when transferring. after execution, returns the set of actually used indices
     * \param priority
     * \return                  PendingTransaction object. caller is responsible to check PendingTransaction::status()
     *                          after object returned
     */

/*virtual PendingTransaction * createTransaction(const std::string &dst_addr, const std::string &payment_id,
    optional<uint64_t> amount, uint32_t mixin_count,
PendingTransaction::Priority = PendingTransaction::Priority_Low,
uint32_t subaddr_account = 0,
std::set<uint32_t> subaddr_indices = {}) = 0;*/

    func prepare() {
        if let theWallet = AppState.sharedInstance.currentWallet {
            theWallet.connect()
        }
    }

    func createMoneroTransactionProposal(details: SendingTransactionDetails) -> String? {
        if let theAmount = details.amount {
            return createMoneroTransactionProposal(to: details.to, amount: theAmount, paymentId: details.paymentId)
        }

        return nil
    }

    func sendTransaction(_ currency: CryptoCurrency, details: SendingTransactionDetails) -> (Bool, String) {
        if let theAmount = details.amount {
            return createMoneroTransaction(to: details.to, amount: theAmount, paymentId: details.paymentId)
        }

        return (false, "")
    }

    func createTransaction(data transactionData: String) -> TransactionWrapper? {
        guard let wallet = AppState.sharedInstance.currentWallet else { return nil }
        return wallet.createTransactionProposal(transactionData: transactionData)
    }

    func prepareAndSign(_ transaction: Transaction) -> Transaction {
        return transaction
    }

    private func createMoneroTransaction(to: Address?, amount: Double, paymentId: String?) -> (Bool, String) {
        guard let theToAddress = to else { return (false, "") }

        if let theWallet = AppState.sharedInstance.currentWallet {
            let result = theWallet.createTransaction(to: theToAddress, paymentId: paymentId ?? "", amount: amount)
            return (result.1, result.2)
        }

        return (false, "")
    }

    private func createMoneroTransactionProposal(to: Address?, amount: Double, paymentId: String?) -> String? {
        guard let theToAddress = to else { return nil }

        if let theWallet = AppState.sharedInstance.currentWallet {
            let result = theWallet.createTransactionProposal(to: theToAddress, paymentId: paymentId ?? "", amount: amount)
            if !result.0 {
                EXADialogs.showMessage(result.1 ?? "Unknown error", title: l10n(.commonError), buttonTitle: l10n(.commonOk))
                return nil
            }

            return result.1
        }

        return nil
    }
}
