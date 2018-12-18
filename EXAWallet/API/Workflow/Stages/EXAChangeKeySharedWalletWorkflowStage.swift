//
// Created by Igor Efremov on 02/10/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class EXAChangeKeySharedWalletWorkflowStage: BaseMultisignatureWalletWorkflowStage {
    private var _api: MultisignatureKeyExchangeWalletAPI?
    private var _header: [String: String]?
    private var _payload: PublicKeyParam?
    private let _messageBuilder = EXAMultisignatureMessageBuilder()

    private var _info: [String]?

    override var type: MultisigStage {
        return .transform
    }

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Change Key Stage"
    }

    override var completedMessage: String {
        return "Shared wallet ready to use"
    }

    private func isAllParticipantsJoined(_ participantsInfo: [String]?) -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let info = participantsInfo else { return false }

        return info.count == meta.metaInfo.participants
    }

    override func execute() {
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        guard let meta = AppState.sharedInstance.currentWalletInfo else {
            _completion?.onStageSkipped(result: false, reason: "meta is nil")
            return
        }

        guard wallet.isReadyMultiSigWallet() else {
            _completion?.onStageSkipped(result: false, reason: "Not all signatures ready yet")
            return
        }

        let alreadyChanged = AppState.sharedInstance.changedKey(for: meta.metaInfo.uuid)
        if !alreadyChanged {
            _api = MultisignatureKeyExchangeWalletAPIImpl()
            _api?.completionAction = completed
            _api?.failureAction = failure

            print("Execute \(name) Stage")

            if preparePayload() {
                if let thePayload = _payload, let theHeaders = _header {
                    _api?.changePublicKey(theHeaders, payload: thePayload)
                }
            }
        } else {
            _completion?.onStageSkipped(result: true, reason: "Already changed")
        }
    }

    override func setupStage(data: [Any]?) {
        if let theData = data as? [String] {
            _info = theData
        }
    }

    private func savePersonalWallet() -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        return EXAWalletFileManager.shared.copyWalletFile(meta.metaInfo.uuid)
    }

    private func preparePayloadCommon(_ payload: APIParam) -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let wallet = AppState.sharedInstance.currentWallet else { return false }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return false
        }

        if let thePayloadContent = payload.rawString() {
            let msg = _messageBuilder.buildMessage(data: thePayloadContent,
                    sessionId: sessionId,
                    nonce: EXANonceService.shared.nonceAndIncrement())
            let signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
            let signature = signer.sign(message: msg) ?? ""
            _header = _api?.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature)
            return true
        }

        return false
    }

    private func preparePayload() -> Bool {
        print("\tPrepare new public key")

        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let wallet = AppState.sharedInstance.currentWallet else { return false }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return false
        }

        let B = wallet.publicMultiSpendKey()
        _payload = PublicKeyParam(B)
        print("Sent key: \(B)")
        let keyPair = MessageKeyPair(keyProvider: MessageKeyPairStorage(), for: meta.metaInfo.uuid)
        if keyPair.isValid {
            if let thePayloadContent = _payload?.rawString() {
                let msg = _messageBuilder.buildMessage(data: thePayloadContent,
                        sessionId: sessionId,
                        nonce: EXANonceService.shared.nonceAndIncrement())
                let wrapper = MoneroWrapper(AppState.sharedInstance.settings.environment.isMainNet)
                guard let signature = wrapper.signMessage(msg, key: keyPair.secretKey) else { return false }

                _header = _api?.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature)
                return true
            }
        }

        return true
    }

    private func finalizeSharedWallet(participantsInfo: [String], signers: UInt) -> (Bool, String) {
        print(participantsInfo)

        guard let wallet = AppState.sharedInstance.currentWallet else { return (false, "") }
        if let result = wallet.transformationIntoSharedWallet(participantsInfo: participantsInfo, signers: signers) {
            if result == "" && participantsInfo.count == signers {
                return (true, result)
            }

            if result != "" && participantsInfo.count > signers {
                return (true , result)
            }
        }

        return (false, "")
    }

    func failure(error: String) {
        EXADialogs.showError(EXAError.CommonError(message: error))
    }

    func completed(result: String) {
        if let meta = AppState.sharedInstance.currentWalletInfo {
            AppState.sharedInstance.setupChangedKey(true, for: meta.metaInfo.uuid)
        }

        _completion?.onStageCompleted("Wallet key changed to multikey", type: self.type)
    }

}
