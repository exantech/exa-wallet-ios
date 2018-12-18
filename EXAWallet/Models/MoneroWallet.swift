//
// Created by Igor Efremov on 15/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class MoneroWallet: Wallet, WalletSyncProtocol, WalletBlockHeight, TransactionsHistory, StorageAbility,
        MoneroTransactionCreator, WalletPaymentIdProtocol {
    private let walletExtension = "wal"
    private var _wallet: MoneroWalletWrapper? = nil

    func create(_ walletFileName: String, password: String) -> (Bool, String) {
        guard let theDocumentDirectory = EXACommon.documentsDirectory else { return (false, "") }
        if let walletFilePath = theDocumentDirectory.appendPathComponent(walletFileName).appendPathExtension(walletExtension) {
            print(walletFilePath)
            
            let wrapper = MoneroWrapper(AppState.sharedInstance.settings.environment.isMainNet)
            _wallet = wrapper.createWallet(walletFilePath, password: password)
            if let theWallet = _wallet {
                return (theWallet.status(), theWallet.errorString())
            }
        }
        
        return (false, "")
    }

    deinit {
        print("deinit MoneroWallet")
    }

    func open(_ walletUUID: String, password: String) -> (Bool, String?) {
        guard let theDocumentDirectory = EXACommon.documentsDirectory else { return (false, "Document directory doesn't define") }
        print(theDocumentDirectory)

        guard let walletFilePath = theDocumentDirectory.appendPathComponent(walletUUID).appendPathExtension(walletExtension) else {
            return (false, "Path to wallet doesn't exist")
        }

        if !FileManager.default.fileExists(atPath: walletFilePath) {
            return (false, "Wallet file doesn't exist")
        }

        let wrapper = MoneroWrapper(AppState.sharedInstance.settings.environment.isMainNet)
        var err: NSString? = nil

        _wallet = wrapper.openWallet(walletFilePath, password: password, error: &err)
        if let theWallet = _wallet, theWallet.status() == true {
            return (true, nil)
        }

        return (false, err as String?)
    }

    func close() -> Bool {
        let wrapper = MoneroWrapper(AppState.sharedInstance.settings.environment.isMainNet)
        return wrapper.closeWallet(_wallet)
    }

    func restore(_ walletUUID: String, mnemonic: String, password: String, blockHeight: UInt64? = nil) -> (Bool, String) {
        guard let theDocumentDirectory = EXACommon.documentsDirectory else { return (false, "Not found Documents directory") }
        print(theDocumentDirectory)

        guard let walletFilePath = theDocumentDirectory.appendPathComponent(walletUUID).appendPathExtension(walletExtension) else {
            return (false, "Can't create wallet filepath")
        }

        let wrapper = MoneroWrapper(AppState.sharedInstance.settings.environment.isMainNet)
        _wallet = wrapper.restoreWallet(walletFilePath, mnemonic: mnemonic, password: password, blockHeight: blockHeight ?? 0)

        if let theWallet = _wallet {
            return (theWallet.status(), theWallet.errorString())
        }

        return (false, "")
    }

    func mnemonic() -> String {
        return _wallet?.seed() ?? ""
    }

    func publicAddress() -> String {
        return _wallet?.publicAddress() ?? ""
    }

    func publicSpendKey() -> String {
        return _wallet?.publicSpendKey() ?? ""
    }

    func secretSpendKey() -> String {
        return _wallet?.secretSpendKey() ?? ""
    }

    func publicMultiSpendKey() -> String {
        return _wallet?.publicMultiSpendKey() ?? ""
    }

    func multisigInfo() -> String {
        return _wallet?.multisigInfo() ?? ""
    }

    func isAlreadyTransformedToMultiSig() -> Bool {
        return _wallet?.isTransformedToMultiSigWallet() ?? false
    }

    func isReadyMultiSigWallet() -> Bool {
        return _wallet?.isReadyMultiSigWallet() ?? false
    }

    func isFinalizeMultiSigNeeded() -> Bool {
        return _wallet?.isFinalizeMultiSigNeeded() ?? false
    }

    func isWalletFinalized() -> Bool {
        return _wallet?.isWalletFinalized() ?? false
    }

    func exchangeMultisigKeys(_ extraInfo: [String]) -> String {
        return _wallet?.exchangeMultisigKeys(extraInfo) ?? ""
    }

    func finalizeMultisig(_ extraInfo: [String]) -> Bool {
        return _wallet?.finalizeMultisig(extraInfo) ?? false
    }

    func transformationIntoSharedWallet(participantsInfo: [String], signers: UInt) -> String? {
        return _wallet?.makeSharedWallet(participantsInfo, signers: signers)
    }

    func exportMultisigPartialKeyImages() -> String? {
        return _wallet?.exportMultisigPartialKeyImages()
    }

    func importMultisigPartialKeyImages(_ parts: [String]) -> Bool {
        return _wallet?.importMultisigPartialKeyImages(parts) ?? false
    }

    func errorString() -> String {
        return _wallet?.errorString() ?? ""
    }

    func verifySignedMessage(message: String, publicKey: String, signature: String) -> Bool {
        guard let wallet = _wallet else { return false }

        return wallet.verifySignedMessage(message, publicKey: publicKey, signature: signature)
    }

    class func deleteAll() -> Bool {
        var result: Bool = false

        guard let theDocumentDirectory = EXACommon.documentsDirectory else { return result }
        let fm = FileManager.default
        do {
            let folderPath = theDocumentDirectory
            let paths = try fm.contentsOfDirectory(atPath: folderPath)
            for path in paths {
                try fm.removeItem(atPath: "\(folderPath)/\(path)")
            }

            result = true
        } catch {
            print(error.localizedDescription)
        }

        return result
    }

    func isSynched() -> Bool {
        return _wallet?.isSynchronized() ?? false
    }

    func sync(from block: UInt64) -> Bool {
        return _wallet?.sync(block) ?? false
    }

    func cancelSync() {
        _wallet?.cancelSync()
    }

    func currentSyncBlock() -> UInt64 {
        return _wallet?.currentSyncBlock() ?? 0
    }

    func hasUnconfirmed() -> Bool {
        return _wallet?.hasUnconfirmed() ?? false
    }

    func initializeSync() -> Bool {
        let defaultNode = AppState.sharedInstance.settings.environment.nodes.currentNode
        return _wallet?.initializeSync(defaultNode) ?? false
    }

    func isConnectedToSync() -> Bool {
        return _wallet?.isConnected() ?? false
    }

    func pauseSync() {
        _wallet?.pauseSync()
        //_wallet?.clear()
    }

    func clear() {
        _wallet?.clear()
    }

    func formattedBalance() -> String {
        guard let theWallet = _wallet else { return "" }
        return formatAmount(theWallet.amount())
    }

    func formattedUnconfirmedBalance() -> String {
        guard let theWallet = _wallet else { return "" }
        return formatAmount(theWallet.unconfirmedAmount())
    }

    func formatAmount(_ value: UInt64) -> String {
        guard let theWallet = _wallet else { return "" }
        guard let preformattedAmount = theWallet.formatAmount(value) else { return ""}

        return EXAWalletFormatter.formattedAmount(preformattedAmount) ?? ""
    }

    func amount(from value: Double?) -> UInt64? {
        guard let theValue = value else { return nil }
        guard let theWallet = _wallet else { return nil }
        return theWallet.amount(from: theValue)
    }

    func transactions() -> [Transaction]? {
        guard let items = _wallet?.transactionsHistory() else { return nil }
        var result = [Transaction]()
        for item: InnerMoneroTransaction in items {
            let tx = Transaction()
            tx.txHash = item.txHash
            tx.destination = item.destination
            tx.amountString = item.amountString
            tx.feeString = item.feeString
            tx.timestamp = item.timestamp
            tx.type = TransactionType(rawValue: item.direction)!
            tx.paymentId = item.paymentId
            tx.confirmations = item.confirmations

            if result.contains(where: {$0.txHash == tx.txHash}) {
                print("Tx already exist")
            }

            result.append(tx)
        }

        return result
    }

    func allTransactionsCount() -> Int {
        let neededConfirmation = 1

        guard let r = transactions() else { return 0}
        return r.filter{$0.confirmations >= neededConfirmation}.count
    }

    func store() {
        _wallet?.store()
    }

    func createTransaction(to: Address, paymentId: String?, amount: Double?) -> (TransactionWrapper?, Bool, String) {
        guard let theWallet = _wallet else { return (nil, false, EXAError.WalletNotInitialized.description) }
        guard let moneroAmount = self.amount(from: amount) else { return (nil, false, EXAError.AmountNotSetup.description) }
        let transactionWrapper = theWallet.createTransaction(to.addressString, paymentId: paymentId ?? "", amount: moneroAmount)
        if theWallet.status() == false {
            return (nil, false, theWallet.errorString())
        }

        if let theTransactionWrapper = transactionWrapper {
            let result = theTransactionWrapper.commit()
            return (transactionWrapper, result, "Transaction successfully sent")
        }

        return (nil, false, "No implemented")
    }

    func createTransactionProposal(to: Address, paymentId: String?, amount: Double?) -> (Bool, String?) {
        guard let theWallet = _wallet else { return (false, EXAError.WalletNotInitialized.description) }
        guard let moneroAmount = self.amount(from: amount) else { return (false, EXAError.AmountNotSetup.description) }

        var resultString: NSString? = nil
        let result = theWallet.createTransactionProposal(to.addressString, paymentId: paymentId ?? "", amount: moneroAmount, result: &resultString)
        //let proposalDataString = theWallet.createTransactionProposal(to.addressString, paymentId: paymentId ?? "", amount: moneroAmount)

        return (result, resultString as String?)

        //return (proposalDataString, "Transaction proposal created")
    }

    func createTransactionProposal(transactionData: String) -> TransactionWrapper? {
        guard let theWallet = _wallet else { return nil }
        return theWallet.createTransactionProposal(transactionData)
    }

    func signTransactionProposal(transactionData: String) -> (String?, String) {
        guard let theWallet = _wallet else { return (nil, EXAError.WalletNotInitialized.description) }
        let proposalDataString = theWallet.signedTransactionProposal(transactionData)

        return (proposalDataString, "Transaction proposal signed")
    }

    func signMultisigTransaction(transactionData: String) -> (Bool, TransactionWrapper?, String?) {
        guard let theWallet = _wallet else { return (false, nil, EXAError.WalletNotInitialized.description) }
        var wrapper: TransactionWrapper? = nil
        var error: NSString? = nil

        let result = theWallet.signMultisigTransaction(transactionData, wrapper: &wrapper, error: &error)
        if result {
            return (true, wrapper, nil)
        } else {
            return (false, nil, error as String?)
        }
    }

    func isMultisigOutputsReady() -> Bool {
        guard let theWallet = _wallet else { return false }
        return theWallet.hasMultisigPartialKeyImages()
    }

    func isNeedSendOutputs(walletId: String) -> Bool {
        guard let theWallet = _wallet else { return false }
        guard theWallet.isReadyMultiSigWallet() == true else { return false }

        var completedProposalCount: Int = 0
        var deniedExport = false
        for proposal in AppState.sharedInstance.proposals {
            if proposal.completed {
                completedProposalCount += 1
                continue
            }

            deniedExport = true
        }

        if deniedExport {
            return false
        }

        let count = allTransactionsCount() + completedProposalCount
        return count > AppState.sharedInstance.sentOutputForTransactionsCount(for: walletId)
    }

    func updateSentOutputs(walletId: String) {
        var completedProposalCount: Int = 0
        for proposal in AppState.sharedInstance.proposals {
            if proposal.completedForMe {
                completedProposalCount += 1
            }
        }

        AppState.sharedInstance.setupSentOutputForTransactionsCount(allTransactionsCount() + completedProposalCount, for: walletId)
    }

    func connect() {
        guard let theWallet = _wallet else { return }
        let defaultNode = AppState.sharedInstance.settings.environment.nodes.currentNode
        print("Connect to node: \(defaultNode)")
        theWallet.connect(toDaemon: defaultNode)
    }

    func blockHeight() -> UInt64 {
        guard let theWallet = _wallet else { return 0 }
        return theWallet.walletBlockHeight()
    }

    func networkBlockHeight() -> UInt64 {
        guard let theWallet = _wallet else { return 0 }
        return theWallet.networkBlockHeight()
    }

    func generatePaymentId() -> String {
        guard let theWallet = _wallet else { return "" }
        return theWallet.generatePaymentId()
    }

    func isAddressValid(_ value: String) -> Bool {
        guard let theWallet = _wallet else { return false }
        return theWallet.isAddressValid(value)
    }
}

extension MoneroWallet: WalletSignerProtocol {

    func sign(message: String, key: String, walletId: String?) -> String? {
        return MoneroWalletWrapper.signMessage(message, withKey: key)
    }

    func multiSign(message: String) -> String? {
        let result = _wallet?.signMultiMessage(message)
        return result
    }

    func hasMultiSign() -> Bool {
        return _wallet?.isReadyMultiSigWallet() ?? false
    }

    func isTransformedToMulti() -> Bool {
        return _wallet?.isTransformedToMultiSigWallet() ?? false
    }
}

extension MoneroWallet: DecoderBase58Protocol {

    func decodeBase58(_ encodedString: String) -> String? {
        return  _wallet?.decodeBase58Info(encodedString)
    }
}
