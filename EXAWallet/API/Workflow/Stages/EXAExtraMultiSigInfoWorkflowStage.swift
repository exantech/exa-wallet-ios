//
// Created by Igor Efremov on 01/10/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class EXAExtraMultiSigInfoWorkflowStage: BaseMultisignatureWalletWorkflowStage, MultisignatureWalletAPIResultCallback {
    private var _signer: MessageSigner?
    private var _header: [String: String]?
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _api: MultisignatureKeyExchangeWalletAPI?

    override var type: MultisigStage {
        return .get_extra_multisig
    }

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Get Extra MultiSig Info"
    }

    override var completedMessage: String {
        return "Shared wallet is ready for work"
    }

    override init() {
        super.init()
    }

    deinit {
        print("deinit EXAExtraMultiSigInfoWorkflowStage")
    }

    private func preparePayloadCommon() -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let wallet = AppState.sharedInstance.currentWallet else { return false }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return false
        }

        _signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
        let msg = _messageBuilder.buildMessage(data: "",
                sessionId: sessionId,
                nonce: EXANonceService.shared.nonceAndIncrement())
        let signature = _signer?.sign(message: msg) ?? ""
        _header = _api?.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature)
        return true
    }

    override func execute() {
        _api = MultisignatureKeyExchangeWalletAPIImpl(resultCallback: self)

        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        guard let _ = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return
        }

        if !wallet.isFinalizeMultiSigNeeded() {
            print("Skip \(name) Stage")
            _completion?.onStageCompleted("Success", type: .get_extra_multisig)

            return
        }

        guard let api = _api else { return }

        print("Execute \(name) Stage")

        if preparePayloadCommon() {
            if let theHeaders = _header {
                let level = AppState.sharedInstance.walletTransformationCurrentLevel(for: meta.metaInfo.uuid)
                api.getExtraMultiSigInfo(theHeaders, level: level)
            }
        }
    }

    func failure(error: String) {
        EXADialogs.showError(EXAError.CommonError(message: error))
    }

    func completed(result: String) {
        let storageService = EXAWalletMetaInfoStorageService()
        // TODO: Check result
        _ = storageService.load()

        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        meta.metaInfo.sharedReady = true

        // TODO: Check result
        _ = storageService.changeMeta(by: meta.metaInfo.uuid, newMeta: meta.metaInfo)
        AppState.sharedInstance.currentWalletInfo = meta

        _completion?.onStageCompleted("Success", type: self.type)
    }

    func completed(resultArray: [String]) {
        print(resultArray)
        _completion?.onStageCompleted(result: resultArray, type: nil)
    }

    func completed(stage: MultisigStage) {

    }

    func completed(resultJSON: JSON) {}
}
