//
// Created by Igor Efremov on 2019-02-12.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol MarkParticipantReadyAPI {
    func markReady(_ headers: [String: String]?)
    var apiBuilder: EXAWalletAPIBuilder { get }
}

class MarkParticipantReadyAPIImpl: MarkParticipantReadyAPI {
    let apiBuilder: EXAWalletAPIBuilder = EXAWalletAPIBuilder()
    private let markReadyEndPoint = EXAMultisignatureWalletAPIEndPoint.ready.rawValue
    weak private var _callBack: MarkParticipantReadyResultCallbackImpl?

    required init(resultCallback: MarkParticipantReadyResultCallbackImpl) {
        _callBack = resultCallback
    }

    func markReady(_ headers: [String: String]?) {
        guard let req = buildRequest(markReadyEndPoint, headers: headers) else { return }
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            if let theResponse = (response as? HTTPURLResponse) {
                if EXABaseHttpAPI.error(theResponse) {
                    let errString = EXABaseHttpAPI.prepareError(data, statusCode: theResponse.statusCode)
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.failure(error: errString)
                    }

                    return
                }

                if EXABaseHttpAPI.success(theResponse) {
                    DispatchQueue.main.async { [weak self] in
                        self?._callBack?.completed(result: .markParticipantReady)
                    }
                }
            }
        }.resume()
    }

    private func buildRequest(_ endPoint: String, headers: [String: String]?) -> URLRequest? {
        return apiBuilder.buildApiRequest(endPoint, method: .post, headers: headers)
    }
}

class EXAWalletMarkParticipantReadyWorkflowStage: BaseMultisignatureWalletWorkflowStage {
    private var _signer: MessageSigner?
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _api: MarkParticipantReadyAPI?
    private let _callback = MarkParticipantReadyResultCallbackImpl()

    override var type: MultisigStage {
        return .wallet_state
    }

    override var status: Bool {
        return false
    }

    override var name: String {
        return "Mark Ready State"
    }

    override var completedMessage: String {
        return "Shared wallet is ready for work"
    }

    override func execute() {
        _callback.completionDelegate = _completion
        _api = MarkParticipantReadyAPIImpl(resultCallback: _callback)

        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return
        }

        guard wallet.isReadyMultiSigWallet() else {
            _completion?.onStageSkipped(result: false, reason: "Not shared wallet yet")
            return
        }

        guard let api = _api else { return }

        print("Execute \(name) Stage")

        _signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
        let msg = _messageBuilder.buildMessage(data: "",
                sessionId: sessionId,
                nonce: EXANonceService.shared.nonceAndIncrement())
        let signature = _signer?.sign(message: msg) ?? ""

        guard let headers = api.apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature) else {
            EXADialogs.showMessage("Can't build request header. Maybe session id is nil", title: l10n(.commonError), buttonTitle: l10n(.commonOk))
            return
        }

        print(headers)

        api.markReady(headers)
    }
}

class MarkParticipantReadyResultCallbackImpl: SharedWalletAPIResultCallback {
    typealias T = MultisignatureWorkflowState
    weak var completionDelegate: StageCompletion?

    init() {}

    func completed(result: T) {
        print(result)
        completionDelegate?.onStageCompleted("Success", type: .wallet_state)
    }

    func failure(error: String) {
        EXADialogs.showMessage(error, title: l10n(.commonError), buttonTitle: l10n(.commonOk))
    }
}
