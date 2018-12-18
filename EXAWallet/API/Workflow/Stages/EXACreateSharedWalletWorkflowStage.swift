//
// Created by Igor Efremov on 14/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class EXACreateSharedWalletWorkflowStage: BaseMultisignatureWalletWorkflowStage, MultisignatureWalletAPIResultCallback {
    private var _api: MultisignatureCreateSharedWalletAPI?
    private var _header: [String: String]?
    private var _payload: APIParam?
    private var _signer: MessageSigner?
    private let _messageBuilder: EXAMultisignatureMessageBuilder = EXAMultisignatureMessageBuilder()

    override var status: Bool {
        return false
    }

    override var type: MultisigStage {
        return .create_wallet
    }

    override var name: String {
        return "Create Shared Wallet"
    }

    override var completedMessage: String {
        return "Created. Invite ready"
    }

    override var inviteStage: Bool {
        return true
    }

    override func execute() {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        _api = MultisignatureCreateSharedWalletAPIImpl(resultCallback: self)

        if let inviteCode = AppState.sharedInstance.inviteCode(for: meta.metaInfo.uuid) {
            print("Skip \(name) Stage")
            _completion?.onStageCompleted(inviteCode, type: self.type)
            return
        }

        print("Execute \(name) Stage")

        if preparePayload() {
            if let thePayload = _payload, let theHeaders = _header {
                // TODO: Check result
                _ = _api?.createSharedWallet(theHeaders, payload: thePayload)
            }
        }
    }

    private func preparePayload() -> Bool {
        print("\tPrepare payload")

        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let wallet = AppState.sharedInstance.currentWallet else { return false }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return false
        }

        _payload = APIParamsBuilder.shared.prepareParamsUsingCurrentAPI(method: .create_wallet,
                rawParams: ["meta": meta.metaInfo, "multi": wallet.multisigInfo(), "device_uid": DeviceUID.uid()])
        guard let payloadString = _payload?.rawUTF8String() else {
            print("payload cannot be serialized")
            return false
        }

        let msg = _messageBuilder.buildMessage(data: payloadString,
                sessionId: sessionId,
                nonce: EXANonceService.shared.nonceAndIncrement())

        _signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
        let signature = _signer?.sign(message: msg) ?? ""

        _header = _api?.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature)

        return true
    }

    func failure(error: String) {
        EXADialogs.showError(EXAError.CommonError(message: error))
    }

    func completed(result: String) {
        // got invite code
        // add meta to invite code (TEMP)
        guard let meta = AppState.sharedInstance.currentWalletMetaInfo else {
            _completion?.onStageCompleted(result, type: self.type)
            return
        }

        //ConfigurationSelector.shared.currentConfiguration
        let worker = EXAInviteCodeWorker()
        if let inviteCode = worker.process(inviteCodeValue: result, meta: meta) {
            _completion?.onStageCompleted(inviteCode, type: self.type)
        } else {
            _completion?.onStageCompleted(result, type: self.type)
        }
    }

    func completed(resultArray: [String]) {}

    func completed(stage: MultisigStage) {}
    func completed(resultJSON: JSON) {}
}
