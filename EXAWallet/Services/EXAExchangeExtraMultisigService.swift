//
// Created by Igor Efremov on 2019-03-14.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

/*class EXAExchangeExtraMultisigServiceResultCallbackImpl: SharedWalletAPIResultCallback {
    typealias T = MultisignatureWorkflowState
    //weak var completionDelegate: StageCompletion?

    init() {}

    func completed(result: T) {
        print(result)
        //completionDelegate?.onStageCompleted("Success", type: .wallet_state)
    }

    func failure(error: String) {
        EXADialogs.showMessage(error, title: l10n(.commonError), buttonTitle: l10n(.commonOk))
    }
}*/


class EXAExchangeExtraMultisigService {
    private var _api: MultisignatureKeyExchangeWalletAPI = MultisignatureKeyExchangeWalletAPIImpl()
    private var _requestHeaderPreparation: EXAAPIRequestHeaderPreparation!

    init(_ apiVersion: APIVersion, wallet: WalletSignerProtocol & DecoderBase58Protocol) {
        _requestHeaderPreparation = EXAAPIRequestHeaderPreparation(apiVersion, wallet: wallet)
    }

    func sendExtraMultisigInfo(_ value: String, level: Int, completionAction: ((String) -> Void)? = nil, failureAction: ((String) -> Void)? = nil) {
        let payload = ExtraMultiSigInfoParam(value)
        let result = _requestHeaderPreparation.prepareRequestHeader(payload)
        if result.0 {
            if let theHeaders = result.1 {
                _api.completionAction = completionAction
                _api.failureAction = failureAction
                _api.sendExtraMultiSigInfo(theHeaders, level: level, payload: payload)
            }
        }
    }
}
