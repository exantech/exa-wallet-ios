//
// Created by Igor Efremov on 2019-02-06.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class SendExtraMultiSignInfoWorkflowStage: BaseMultisignatureWalletWorkflowStage, MultisignatureWalletAPIResultCallback {
    private var _signer: MessageSigner?
    private var _header: [String: String]?
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _api: MultisignatureKeyExchangeWalletAPI?

    private var _payload: APIParam?
    private let _callback = SendMultiSignInfoAPIResultCallbackImpl()

    private var exchExtraMultisigService: EXAExchangeExtraMultisigService?

    override var type: MultisigStage {
        return .send_extra_multisig
    }

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Send Extra multisig Info"
    }

    override var completedMessage: String {
        return "Shared wallet is ready for work"
    }

    override init() {
        super.init()
    }

    deinit {
        print("deinit SendMultiSignInfoWorkflowStage")
    }

    private func preparePayload() -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let wallet = AppState.sharedInstance.currentWallet else { return false }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return false
        }

        guard MoneroWalletMessageService.shared.recipientsCount == meta.metaInfo.participants else {
            print("MoneroWalletMessageService isn't setup correctly")
            return false
        }

        let message = wallet.multisigInfo()
        let walletId = meta.metaInfo.uuid

        let content = payloadContent(apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion,
                walletId: walletId, message: message)
        if let rawString = content {
            _signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
            let msg = _messageBuilder.buildMessage(data: rawString,
                    sessionId: sessionId,
                    nonce: EXANonceService.shared.nonceAndIncrement())
            let signature = _signer?.sign(message: msg) ?? ""
            _header = _api?.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature)

            return true
        }

        return false
    }

    func payloadContent(apiVersion: APIVersion, walletId: String, message: String) -> String? {
        switch apiVersion {
        case .v1:
            _payload = MultiSigInfoV1Param(message)
        case .v2:
            let keyPair = MessageKeyPair(keyProvider: MessageKeyPairStorage(), for: walletId)
            _payload = MoneroWalletMessageService.shared.prepareEncodedPayload(message, keyPair: keyPair)
        }

        return _payload?.rawString()
    }

    override func execute() {
        _callback.completionDelegate = _completion
        _api = MultisignatureKeyExchangeWalletAPIImpl(resultCallback2: _callback)

        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        guard let _ = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return
        }

        guard let wallet = AppState.sharedInstance.currentWallet else { return }

        print("Execute \(name) Stage")

        if let extraMultiSigInfo = AppState.sharedInstance.extraMultiInfo(for: meta.metaInfo.uuid) {
            let level = AppState.sharedInstance.walletTransformationCurrentLevel(for: meta.metaInfo.uuid)
            exchExtraMultisigService = EXAExchangeExtraMultisigService(ConfigurationSelector.shared.currentConfiguration.apiVersion, wallet: wallet)
            exchExtraMultisigService?.sendExtraMultisigInfo(extraMultiSigInfo, level: level, completionAction: { [weak self] (result) in
                self?._completion?.onStageCompleted("Success", type: .send_extra_multisig)
            }, failureAction: { [weak self]  (error) in
                print("Error: " + error)
                self?._completion?.onStageSkipped(result: false, reason: error)
            })
        } else {
            _completion?.onStageSkipped(result: false, reason: "Error")
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

class SendMultiSignInfoAPIResultCallbackImpl: SharedWalletAPIResultCallback {
    typealias T = String
    weak var completionDelegate: StageCompletion?

    init() {

    }

    func completed(result: T) {
        print(result)
        completionDelegate?.onStageCompleted(result, type: .send_extra_multisig)
    }

    func failure(error: String) {
        EXADialogs.showError(EXAError.CommonError(message: error))
    }
}