//
// Created by Igor Efremov on 2019-03-14.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

typealias APIRequestHeader = [String: String]?

class EXAAPIRequestHeaderPreparation {
    private let _messageBuilder = EXAMultisignatureMessageBuilder()
    private var _signer: MessageSigner!
    private let _apiBuilder = EXAWalletAPIBuilder()

    init(_ apiVersion: APIVersion, wallet: WalletSignerProtocol & DecoderBase58Protocol) {
        _signer = MessageSigner(wallet, apiVersion: apiVersion)
    }

    func prepareRequestHeader(_ payload: APIParam) -> (Bool, APIRequestHeader) {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return (false, nil) }
        guard let wallet = AppState.sharedInstance.currentWallet else { return (false, nil) }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return (false, nil)
        }

        if let thePayloadContent = payload.rawString() {
            let msg = _messageBuilder.buildMessage(data: thePayloadContent,
                    sessionId: sessionId,
                    nonce: EXANonceService.shared.nonceAndIncrement())
            let signer = MessageSigner(wallet, apiVersion: ConfigurationSelector.shared.currentConfiguration.apiVersion)
            let signature = _signer.sign(message: msg) ?? ""
            let header = _apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature)

            return (true, header)
        }

        return (false, nil)
    }
}
