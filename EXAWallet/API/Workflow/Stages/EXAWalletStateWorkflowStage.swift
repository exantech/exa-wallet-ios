//
// Created by Igor Efremov on 04/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class EXAWalletStateWorkflowStage: BaseMultisignatureWalletWorkflowStage {
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _api: SharedWalletStateWalletAPI?
    private let _callback = SharedWalletStateAPIResultCallbackImpl()

    override var type: MultisigStage {
        return .wallet_state
    }

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Wallet State"
    }

    override var completedMessage: String {
        return "Shared wallet is ready for work"
    }

    override func execute() {
        _callback.completionDelegate = _completion
        _api = SharedWalletStateWalletAPIImpl(resultCallback: _callback)

        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return
        }

        guard let api = _api else { return }

        print("Execute \(name) Stage")

        let signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
        let msg = _messageBuilder.buildMessage(data: "",
                sessionId: sessionId,
                nonce: EXANonceService.shared.nonceAndIncrement())
        let signature = signer.sign(message: msg) ?? ""

        guard let headers = api.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature) else {
            EXADialogs.showError(EXAError.CommonError(message: "Can't build request header. Maybe session id is nil"))
            return
        }

        print(headers)

        api.walletState(headers)
    }
}

class SharedWalletStateAPIResultCallbackImpl: SharedWalletAPIResultCallback {
    typealias T = SharedWalletState
    weak var completionDelegate: StageCompletion?

    init() {

    }

    func completed(result: T) {
        print(result)

        if result.isReady() {
            guard let meta = AppState.sharedInstance.currentWalletInfo else { return }

            let storageService = EXAWalletMetaInfoStorageService()
            _ = storageService.load()
            meta.metaInfo.sharedReady = true
            _ = storageService.changeMeta(by: meta.metaInfo.uuid, newMeta: meta.metaInfo)
            AppState.sharedInstance.currentWalletInfo = meta

            AppState.sharedInstance.saveSharedPublicKeys(result.publicKeys, for: meta.metaInfo.uuid)
            MoneroWalletMessageService.shared.setupPublicKeys(result.publicKeys)
            completionDelegate?.onFinishWorkflow()
        } else {
            if result.isCompleted() {
                MoneroWalletMessageService.shared.setupPublicKeys(result.publicKeys)
            }

            delay(10, closure: { [weak self] in
                self?.completionDelegate?.onStageSkipped(result: true, reason: "Waiting participants...")
            })
        }

        /*let storageService = EXAWalletMetaInfoStorageService()
        // TODO: Check result
        _ = storageService.load()

        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        meta.metaInfo.sharedReady = true

        // TODO: Check result
        _ = storageService.changeMeta(by: meta.metaInfo.uuid, newMeta: meta.metaInfo)
        AppState.sharedInstance.currentWalletInfo = meta*/
    }

    func failure(error: String) {
        EXADialogs.showError(EXAError.CommonError(message: error))
    }
}
