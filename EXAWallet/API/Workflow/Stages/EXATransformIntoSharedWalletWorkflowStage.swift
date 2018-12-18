//
// Created by Igor Efremov on 28/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import KeychainAccess

class EXATransformIntoSharedWalletWorkflowStage: BaseMultisignatureWalletWorkflowStage {
    private var _api: MultisignatureKeyExchangeWalletAPI?
    private var _header: [String: String]?
    private var _payload: PublicKeyParam?

    private let _messageBuilder = EXAMultisignatureMessageBuilder()

    private var exchExtraMultisigService: EXAExchangeExtraMultisigService?

    private var _info: [String]?

    override var type: MultisigStage {
        return .transform
    }

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Transform Into Shared Wallet"
    }

    override var completedMessage: String {
        return "Shared wallet ready to use"
    }

    override init() {
        super.init()
    }

    deinit {
        print("deinit EXATransformIntoSharedWalletWorkflowStage")
    }

    private func isAllParticipantsJoined(_ participantsInfo: [String]?) -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        guard let info = participantsInfo else { return false }

        return info.count == meta.metaInfo.participants
    }

    override func execute() {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        guard let wallet = AppState.sharedInstance.currentWallet else { return }

        if wallet.isAlreadyTransformedToMultiSig() {
            _completion?.onStageCompleted(result: nil, type: .transform)
            return
        }

        guard isAllParticipantsJoined(_info) else {
            _completion?.onStageSkipped(result: false, reason: "Not all signatures ready yet")
            return
        }

        print("Execute \(name) Stage")

        let storage = MessageKeyPairStorage()
        let manager = MessageKeysManager()
        _ = manager.savePersonalWalletKeys(storage: storage)

        if let theInfo = _info {
            // TODO check signers count value
            let transformation = MoneroWalletTransformation()
            let result = transformation.transformToSharedWallet(wallet, multisigInfos: theInfo,
                    signers: meta.metaInfo.signatures, participants: meta.metaInfo.participants)
            if result.0 {
                if wallet.isReadyMultiSigWallet() {
                    _completion?.onStageCompleted("Transformation completed", type: self.type)
                    return
                } else {
                    if !meta.metaInfo.scheme().isNofN() {
                        AppState.sharedInstance.setupExtraMultiInfo(result.1, for: meta.metaInfo.uuid)
                        AppState.sharedInstance.setupWalletTransformationCurrentLevel(1, for: meta.metaInfo.uuid)
                    }
                    _completion?.onStageCompleted("Wallet Transformed", type: self.type)
                }
            } else {
                _completion?.onStageSkipped(result: false, reason: "Transformation fails")
            }
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

    func failure(error: String) {
        EXADialogs.showError(EXAError.CommonError(message: error))
        _completion?.onStageSkipped(result: false, reason: "Extra multi sig not setup")
    }

    func completed(result: String) {
        print(result)
        _completion?.onStageCompleted("Transformed and sent extra multi sig", type: self.type)
    }

}
