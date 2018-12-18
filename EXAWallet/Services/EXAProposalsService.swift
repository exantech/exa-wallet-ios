//
// Created by Igor Efremov on 06/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol MoneroTransactionProposalsServiceProtocol {
    func createTransactionProposal(_ details: SendingTransactionDetails) -> String?
}

protocol MoneroTransactionSigner {
    func sign()
}

class EXAProposalsService: MoneroTransactionProposalsServiceProtocol, MultisignatureWalletAPIResultCallback {
    private var _signer: MessageSigner?
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _transactionService: MoneroTransactionsService?
    private var _api: EXAProposalsAPI!
    private var _header: [String: String]?
    private var _payload: TxProposalParam?

    init(transactionService: MoneroTransactionsService) {
        _transactionService = transactionService
        _api = EXATransactionProposalsAPIImpl(resultCallback: self)
    }

    init() {
        _api = EXATransactionProposalsAPIImpl(resultCallback: self)
    }

    func createTransactionProposal(_ details: SendingTransactionDetails) -> String? {
        guard let _ = _transactionService else { return nil }

        NSLog("CALL createTransactionProposal")

        return _transactionService?.createMoneroTransactionProposal(details: details)
    }

    func currentProposals() {
        debugPrint("<<< currentProposals")
        if preparePayload(payload: nil) {
            if let theHeaders = _header {
                _api?.currentTxProposals(theHeaders)
            }
        }
    }

    func setupTransactionProposalPayload(_ params: TxProposalParam?) {
        _payload = params
    }

    func sendTransactionProposal() {
        if let thePayload = _payload{
            if preparePayload(payload: thePayload) {
                if let theHeaders = _header {
                    _api?.sendTxProposal(theHeaders, payload: thePayload)
                }
            }

        }
    }

    private func preparePayload(payload: Jsonable? = nil) -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let wallet = AppState.sharedInstance.currentWallet else { return false }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return false
        }

        let payloadString = payload?.rawUTF8String() ?? ""
        let msg = _messageBuilder.buildMessage(data: payloadString,
                sessionId: sessionId,
                nonce: EXANonceService.shared.nonceAndIncrement())

        _signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
        let signature = _signer?.sign(message: msg) ?? ""
        _header = _api?.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature)

        return true
    }

    func failure(error: String) {
        NSLog("Get proposal error: \(error)")
    }

    func completed(result: String) {
        // let's try to simulate accept proposal and sign transaction

        print("Accept proposal & sign transaction")
        /*let result = signParticipant(result)
        if result.0 {
            createTransaction(result.1!)

        }*/
        //signParticipantAndCommit(result)
    }

    func completed(resultArray: [String]) {

    }

    func completed(stage: MultisigStage)  {

    }
}

extension EXAProposalsService {

    /*func signParticipant(_ transactionData: String) -> String? {
        guard let wallet = AppState.sharedInstance.currentWallet else { return false }

        let result = wallet.signMultisigTransaction(transactionData: transactionData)
        if !result.0 {
            EXADialogs.showMessage(result.2 ?? "Unknown error", title: l10n(.commonError), buttonTitle: l10n(.commonOk))
            return false
        } else {
            return result.1?.signedData()
        }
    }*/

    func signParticipantAndCommit(_ transactionData: String) -> Bool {
        guard let wallet = AppState.sharedInstance.currentWallet else { return false }

        let result = wallet.signMultisigTransaction(transactionData: transactionData)
        if !result.0 {
            EXADialogs.showMessage(result.2 ?? "Unknown error", title: l10n(.commonError), buttonTitle: l10n(.commonOk))
            return false
        } else {
            return result.1?.commit() ?? false
        }
    }

    func signParticipant(_ transactionData: String) -> (Bool, String?) {
        guard let wallet = AppState.sharedInstance.currentWallet else { return (false, nil) }

        let signed = wallet.signTransactionProposal(transactionData: transactionData).0
        return (true, signed)
    }

    func createTransaction(_ transactionData: String) {
        guard let wallet = AppState.sharedInstance.currentWallet else { return }

        // TODO: Check result
        _ = wallet.createTransactionProposal(transactionData: transactionData)

        _transactionService?.prepare()
        delay(5.0, closure: {
            if let theTransactionWrapper = self._transactionService?.createTransaction(data: transactionData) {
                theTransactionWrapper.commit()
            }
        })
    }

    func completed(resultJSON: JSON) {
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        AppState.sharedInstance.proposals.removeAll()

        if let count = resultJSON.array?.count {
            let checkProposalSign = wallet.publicMultiSpendKey()

            for n in 0..<count {
                if let theNumber = resultJSON[n]["amount"].number, let proposalId = resultJSON[n]["proposal_id"].string {
                    let amount = theNumber.uint64Value
                    let description = resultJSON[n]["description"].string ?? ""
                    let lastSignedTransaction = resultJSON[n]["last_signed_transaction"].string ?? ""
                    let to = resultJSON[n]["destination_address"].string ?? ""

                    let approvals: [String]? = resultJSON[n]["approvals"].array?.compactMap{$0.string}
                    let proposal = TransactionProposal(identifier: proposalId, to: to, lastSignedTransaction: lastSignedTransaction,
                            amount, Date().timeIntervalSince1970, description)
                    if resultJSON[n]["status"].string == "approved" {
                        proposal.approved = true
                    }

                    if resultJSON[n]["status"].string == "rejected" {
                        proposal.rejected = true
                    }

                    if resultJSON[n]["status"].string == "relayed" {
                        proposal.relayed = true
                    }

                    proposal.approvals = approvals
                    proposal.alreadySigned = proposal.isAlreadySigned(checkProposalSign)

                    AppState.sharedInstance.proposals.append(proposal)
                }
            }

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name.ProposalsReloadNeeded), object: nil)
        }
    }
}
