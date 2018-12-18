//
// Created by Igor Efremov on 04/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class AuthWorkflowStage: BaseMultisignatureWalletWorkflowStage, MultisignatureWalletAPIResultCallback {
    private var _api: MultisignatureAuthWalletAPI?
    private var _payload: APIParam?

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Auth"
    }

    override var completedMessage: String {
        return "Auth success"
    }

    override func execute() {
        super.execute()
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }

        _api = MultisignatureAuthWalletAPIImpl(resultCallback: self)
        let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid)
        if let _ = sessionId {
            print("Skip \(name) Stage")
            _completion?.onStageSkipped(result: true, reason: "")
            return
        }

        if preparePayload() {
            if let thePayload = _payload {
                _api?.auth(thePayload)
            }
        }
    }

    override init() {
        super.init()
    }

    private func preparePayload() -> Bool {
        guard let theWallet = AppState.sharedInstance.currentWallet else { return false }
        let B = theWallet.publicSpendKey()

        _payload = APIParamsBuilder.shared.prepareParamsUsingCurrentAPI(method: .open_session,
                rawParams: ["key": B, "agent": "EXA Wallet iOS ver. \(EXAAppInfoService.appVersion)"])

        return _payload != nil
    }

    func failure(error: String) {
        print("auth stage failure: \(error)")
    }

    func completed(result: String) {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }

        print("Session Id: \(result)")
        AppState.sharedInstance.setupSessionId(result, for: meta.metaInfo.uuid)
        _completion?.onStageCompleted(nil, type: nil)
    }

    func completed(resultArray: [String]) {

    }

    func completed(stage: MultisigStage) {}
    func completed(resultJSON: JSON) {}
}
