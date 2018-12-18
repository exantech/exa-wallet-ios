//
// Created by Igor Efremov on 01/10/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class EXAWalletFinalizeWorkflowStage: BaseMultisignatureWalletWorkflowStage, MultisignatureWalletAPIResultCallback {
    private var _signer: EXAMessageSignatureBuilder?
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _api: MultisignatureCheckJoinStateWalletAPI?

    private var _info: [String]?

    override var type: MultisigStage {
        return .finalize_wallet
    }

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Finalize Wallet"
    }

    override var completedMessage: String {
        return "Shared wallet is ready for work"
    }

    override func setupStage(data: [Any]?) {
        _info = []
        if let theData = data as? [String] {
            _info = theData
        }
    }

    override func execute() {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        guard let _ = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return
        }

        if !wallet.isFinalizeMultiSigNeeded() {
            print("Skip \(name) Stage")
            _completion?.onStageSkipped(result: true, reason: "")
            return
        }

        if let theInfo = _info {
            if theInfo.count < meta.metaInfo.participants {
                print("Skip \(name) Stage")
                _completion?.onStageSkipped(result: true, reason: "")
            } else {
                var result = false

                if meta.metaInfo.scheme().isMofN() {
                    print("Execute \(name) Stage for M of N")

                    let walletTransformationLevel = AppState.sharedInstance.walletTransformationCurrentLevel(for: meta.metaInfo.uuid)
                    if walletTransformationLevel <= meta.metaInfo.scheme().level {
                        let info = wallet.exchangeMultisigKeys(theInfo)
                        AppState.sharedInstance.setupExtraMultiInfo(info, for: meta.metaInfo.uuid)
                        AppState.sharedInstance.setupWalletTransformationCurrentLevel(walletTransformationLevel + 1, for: meta.metaInfo.uuid)
                        result = true
                    }
                } else {
                    print("Execute \(name) Stage for N-1 of N")
                    result = wallet.finalizeMultisig(theInfo)
                }

                if result {
                    _completion?.onStageCompleted("Success", type: nil)
                } else {
                    _completion?.onStageSkipped(result: false, reason: "")
                }
            }
        }
    }

    func failure(error: String) {
        EXADialogs.showError(EXAError.CommonError(message: error))
    }

    func completed(result: String) {
        /*let storageService = EXAWalletMetaInfoStorageService()
        storageService.load()

        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        meta.metaInfo.sharedReady = true

        storageService.changeMeta(by: meta.metaInfo.uuid, newMeta: meta.metaInfo)
        AppState.sharedInstance.currentWalletInfo = meta*/

        _completion?.onStageCompleted("Success", type: self.type)
    }

    func completed(resultArray: [String]) {
       // print(resultArray)
       // _completion?.onStageCompleted(result: resultArray, type: nil)
    }

    func completed(stage: MultisigStage) {

    }

    func completed(resultJSON: JSON) {}
}
