//
// Created by Igor Efremov on 05/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SDCAlertView
import SwiftyJSON

enum EXAWalletOutputsStageMode: Int {
    case update, get
}

class EXAWalletOutputsChangeStage: BaseMultisignatureWalletWorkflowStage, MultisignatureWalletAPIResultCallback {
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _api: EXAWalletOutputsChangeAPI?

    private var _header: [String: String]?
    private var _payload: APIParam?

    private let syncService = EXAMoneroSyncService()
    private let sendingService = MoneroTransactionsService()

    //weak var _completion: StageCompletion?

    private var mode: EXAWalletOutputsStageMode = .update

    override var name: String {
        return "Outputs Exchange Stage"
    }

    override var completedMessage: String {
        return "Completed"
    }

    override var status: Bool {
        return false
    }

    init(mode: EXAWalletOutputsStageMode) {
        super.init()
        self.mode = mode
    }

    override func execute() {
        _api = EXAWalletOutputsChangeAPIImpl(resultCallback: self)

        super.execute()
        if .update == mode {
            if isNeedToExportOutputs() {
                prepareAndSendOutputs()
            } else {
                _completion?.onStageCompleted("", type: nil)
            }
        }

        if .get == mode {
            if preparePayload(message: nil) {
                if let theHeaders = _header {
                    _api?.getOutputs(theHeaders)
                }
            }
        }
    }

    private func isNeedToExportOutputs() -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let theWallet = AppState.sharedInstance.currentWallet else { return false }

        return theWallet.isNeedSendOutputs(walletId: meta.metaInfo.uuid)
    }

    private func prepareAndSendOutputs() {
        guard let output = prepareOutput() else { return }
        if output.length > 0 {
            _api = EXAWalletOutputsChangeAPIImpl(resultCallback: self)
            if preparePayload(message: output) {
                if let theHeaders = _header, let thePayload = _payload {
                    _api?.sendOwnOutput(theHeaders, payload: thePayload)
                }
            }
        }
    }

    private func prepareOutput() -> String? {
        guard let wallet = AppState.sharedInstance.currentWallet else { return nil }

        if let result = wallet.exportMultisigPartialKeyImages() {
            wallet.store()
            print(result)

            return result
        }

        return nil
    }

    private func prepareRawPayload(message: String, apiVersion: APIVersion) -> APIParam? {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return nil }
        var result: APIParam?

        switch apiVersion {
        case .v1:
            result = SharedOutputsParam(message)
        case .v2:
            guard MoneroWalletMessageService.shared.recipientsCount == meta.metaInfo.participants else {
                print("MoneroWalletMessageService isn't setup correctly")
                return nil
            }

            if message.length > 0 {
                let walletId = meta.metaInfo.uuid
                let keyPair = MessageKeyPair(keyProvider: MessageKeyPairStorage(), for: walletId)
                result = MoneroWalletMessageService.shared.prepareEncodedPayload(message, keyPair: keyPair)
            }
        }

        return result
    }

    private func preparePayload(message: String?) -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let wallet = AppState.sharedInstance.currentWallet else { return false }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return false
        }

        var rawString: String = ""
        let signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)

        if let theMessage = message {
            _payload = prepareRawPayload(message: theMessage, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
            if let thePayload = _payload {
                rawString = thePayload.rawString() ?? ""
            }
        }

        let msg = _messageBuilder.buildMessage(data: rawString,
                sessionId: sessionId,
                nonce: EXANonceService.shared.nonceAndIncrement())
        let signature = signer.sign(message: msg) ?? ""
        _header = _api?.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature)

        return true
    }

    func failure(error: String) {
        EXADialogs.showMessage(error, title: l10n(.commonError), buttonTitle: l10n(.commonOk))
    }

    func completed(result: String) {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        guard let wallet = AppState.sharedInstance.currentWallet else { return }

        wallet.updateSentOutputs(walletId: meta.metaInfo.uuid)
        _completion?.onStageCompleted("", type: nil)
    }

    private func isValidResult(_ value: String) -> Bool {
        return value.hasPrefix(MoneroCommonConstants.multiExportSignature)
    }

    private func isNeedToImportOutputs(_ importHashes: [String]) -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let existHashes = AppState.sharedInstance.lastImportedOutputsHashes(for: meta.metaInfo.uuid) else { return true}

        let common = existHashes.filter { importHashes.contains($0) }
        return (common.count == 0)
    }

    private func enoughOutputsToImport(outputs: [String]) -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard outputs.count == meta.metaInfo.participants else { return false }

        return true
    }

    func completed(resultArray: [String]) {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        if enoughOutputsToImport(outputs: resultArray) {
            var importHashes = [String]()
            let sortedOutputs = resultArray.sorted()
            for item in sortedOutputs {
                importHashes.append(item.sha256())
            }

            print(importHashes)

            if isNeedToImportOutputs(importHashes) {
                guard let wallet = AppState.sharedInstance.currentWallet else { return }

                let result = wallet.importMultisigPartialKeyImages(resultArray)
                if result == true {
                    AppState.sharedInstance.setupLastImportedOutputsHashes(importHashes, for: meta.metaInfo.uuid)
                    wallet.store()
                    _completion?.onStageCompleted("Successfully import", type: nil)
                } else {
                    NSLog("Error: \(wallet.errorString())")
                    _completion?.onStageSkipped(result: true, reason: "Error during import. Skip import")
                }
            }
        } else {
            _completion?.onStageSkipped(result: true, reason: "Not yet output ready. Skip import")
        }
    }

    func completed(stage: MultisigStage) {

    }

    func completed(resultJSON: JSON) {}
}
