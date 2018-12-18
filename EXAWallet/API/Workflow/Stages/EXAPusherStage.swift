//
// Created by Igor Efremov on 2019-03-04.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

protocol PusherCompletionDelegate: class {
    func completed(result: String)
    func failure(error: String)
}

class EXAPusherStage: BaseMultisignatureWalletWorkflowStage, PusherCompletionDelegate {
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _api: WalletPusherAPI?
    private var _callback: WalletPusherAPIResultCallbackImpl?
    private var _inviteCode: String?

    override var type: MultisigStage {
        return .pusher
    }

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Register for Pushes"
    }

    override var completedMessage: String {
        return "Registration successfully"
    }

    override init() {
        super.init()
        _callback = WalletPusherAPIResultCallbackImpl(completionDelegate: self)
    }

    override func execute() {
        _api = WalletPusherAPIImpl(resultCallback: _callback)

        guard let api = _api else { return }
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            _completion?.onStageSkipped(result: false, reason: "Session Id not defined")
            return
        }

        print("Execute \(name) Stage")
        guard let token = AppState.sharedInstance.token() else {
            _completion?.onStageSkipped(result: false, reason: "token is nil")
            return
        }
        let payload = PusherRegisterParam(deviceUid: DeviceUID.uid(), token: token)

        if let thePayloadContent = payload.rawString() {
            let msg = _messageBuilder.buildMessage(data: thePayloadContent,
                    sessionId: sessionId,
                    nonce: EXANonceService.shared.nonceAndIncrement())
            let signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
            let signature = signer.sign(message: msg) ?? ""
            if let header = api.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature) {
                api.register(header, payload: payload)
            }
        }
    }

    func failure(error: String) {
        EXADialogs.showError(EXAError.CommonError(message: error))
    }

    func completed(result: String) {
        _completion?.onStageCompleted(result, type: self.type)
        return
    }

    deinit {
        print("deinit EXAPusherStage")
    }
}

class WalletPusherAPIResultCallbackImpl: SharedWalletAPIResultCallback {
    typealias T = String
    weak var _completionDelegate: PusherCompletionDelegate?

    init(completionDelegate: PusherCompletionDelegate) {
        _completionDelegate = completionDelegate
    }

    func completed(result: T) {
        print(result)
        _completionDelegate?.completed(result: result)
    }

    func failure(error: String) {
        _completionDelegate?.failure(error: error)
    }
}

