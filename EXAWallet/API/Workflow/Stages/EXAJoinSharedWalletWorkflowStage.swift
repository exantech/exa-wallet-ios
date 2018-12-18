//
// Created by Igor Efremov on 21/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class EXAJoinSharedWalletWorkflowStage: BaseMultisignatureWalletWorkflowStage, MultisignatureWalletAPIResultCallback {
    private var _api: MultisignatureJoinWalletAPI?
    private var _header: [String: String]?
    private var _payload: APIParam?
    private var _signer: MessageSigner?
    private let _messageBuilder: EXAMultisignatureMessageBuilder = EXAMultisignatureMessageBuilder()

    override var name: String {
        return "Join Stage"
    }

    override var completedMessage: String {
        return "Joined"
    }

    override var status: Bool {
        return false
    }

    override func execute() {
        _api = MultisignatureJoinWalletAPIImpl(resultCallback: self)

        print("Execute \(name) Stage")

        if preparePayload() {
            if let thePayload = _payload, let theHeaders = _header {
                // TODO: Check result
                _ = _api?.joinSharedWallet(theHeaders, payload: thePayload)
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

        guard let theInviteCode = AppState.sharedInstance.inviteCode(for: meta.metaInfo.uuid) else {
            print("Invite code not defined")
            _completion?.onStageCompleted(nil, type: nil)
            return false
        }
        
        let B = wallet.publicSpendKey()

        _payload = APIParamsBuilder.shared.prepareParamsUsingCurrentAPI(method: .join_wallet,
                rawParams: ["invite_code": theInviteCode.value, "public_key": B, "multi": wallet.multisigInfo(), "device_uid": DeviceUID.uid()])
        if let payloadString = _payload?.rawUTF8String() {
            let msg = _messageBuilder.buildMessage(data: payloadString,
                    sessionId: sessionId,
                    nonce: EXANonceService.shared.nonceAndIncrement())

            _signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
            let signature = _signer?.sign(message: msg) ?? ""

            _header = _api?.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature)
            return true
        }

        return false
    }

    func failure(error: String) {
        EXADialogs.showError(EXAError.CommonError(message: error))
    }

    func completed(result: String) {
        print("Join: \(result)")
        _completion?.onStageCompleted(nil, type: nil)
    }

    func completed(resultArray: [String]) {
        _completion?.onStageCompleted(result: resultArray, type: nil)
    }

    func completed(stage: MultisigStage) {

    }

    func completed(resultJSON: JSON) {}
}
