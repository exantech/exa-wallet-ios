//
// Created by Igor Efremov on 28/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class EXAMultisigInfoWorkflowStage: BaseMultisignatureWalletWorkflowStage {
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _api: MultisignatureCheckJoinStateWalletAPI?
    private let _callback = SharedWalletAPIResultCheckJoinCallbackImpl()

    override var type: MultisigStage {
        return .get_extra_multisig
    }

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Check Join State"
    }

    override var completedMessage: String {
        return "All participants joined"
    }

    override func execute() {
        super.execute()
        _callback.completionDelegate = _completion
        _api = MultisignatureCheckJoinStateWalletAPIImpl(resultCallback: _callback,
                apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)

        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return
        }

        // check if already multisig
        if wallet.isReadyMultiSigWallet() {
            print("Skip \(name) Stage")
            _completion?.onStageCompleted(result: nil, type: .get_extra_multisig)
            return
        }

        guard let api = _api else { return }

        let signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
        let msg = _messageBuilder.buildMessage(data: "",
                sessionId: sessionId,
                nonce: EXANonceService.shared.nonceAndIncrement())
        guard let signature = signer.sign(message: msg) else {
            print("Empty signature")
            return
        }
        guard let headers = api.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature) else {
            print("Can't build request header. Maybe session id is nil")
            return
        }

        print(headers)
        api.checkMultisigInfo(headers)
    }
}

class SharedWalletAPIResultCheckJoinCallbackImpl: SharedWalletAPIResultCallback {
    typealias T = [String]

    weak var completionDelegate: StageCompletion?

    init() {

    }

    func failure(error: String) {
        EXADialogs.showError(EXAError.CommonError(message: error))
    }

    func completed(result: T) {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }

        if result.count == meta.metaInfo.participants {
            completionDelegate?.onStageCompleted(result: result, type: .get_extra_multisig)
        } else {
            completionDelegate?.onStageSkipped(result: true, reason: "Multisig infos aren't ready")
        }
    }
}
