//
// Created by Igor Efremov on 21/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class EXABaseHttpAPI {
    init() {}

    class func error(_ response: HTTPURLResponse) -> Bool {
        return (400 <= response.statusCode)
    }

    class func prepareError(_ data: Data?, statusCode: Int) -> String {
        var err: String = "Error during request"
        if let data = data {
            let json = JSON(data)
            if let error = json["error"].string {
                err = error
            }
        }

        err += " (Status Code: \(statusCode))"
        return err
    }

    class func success(_ response: HTTPURLResponse) -> Bool {
        return (200...299 ~= response.statusCode)
    }

    class func prepareHeader(with signature: String) -> [String: String]? {
        let apiBuilder = EXAWalletAPIBuilder()
        return apiBuilder.buildSessionRequestHeaders(nonce: EXANonceService.shared.currentNonce, signature: signature)
    }

    class func prepareSignature(payload: Jsonable? = nil) -> String? {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return nil }
        guard let wallet = AppState.sharedInstance.currentWallet else { return nil }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id not defined")
            return nil
        }

        let payloadString = payload?.rawUTF8String() ?? ""
        let messageBuilder = EXAMultisignatureMessageBuilder()

        let msg = messageBuilder.buildMessage(data: payloadString,
                sessionId: sessionId,
                nonce: EXANonceService.shared.nonceAndIncrement())

        let signer = EXAMessageSignatureBuilder(wallet)
        let signature = signer.multiSign(message: msg) ?? ""

        return signature
    }
}
