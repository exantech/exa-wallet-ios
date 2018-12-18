//
// Created by Igor Efremov on 2019-02-08.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class SecureDataWorker: APIBaseDataWorker<[String]> {

    override func process(_ data: Data?) -> [String] {
        return postProcess(preProcess(data))
    }

    private func preProcess(_ data: Data?) -> [String: EncodedMessage]? {
        var result = [String: EncodedMessage]() // for saving only one and last message for every sender

        if let data = data {
            let json = JSON(data)
            if let items = json["secure_data"].array {
                for item in items {
                    if let sender = item["sender"].string, let seed = item["seed"].uInt32,
                       let payload = item["payload"].string, let recipient = item["participant"].string {
                        let encodedMessage = EncodedMessage(sender: sender, seed: seed, payload: [recipient: payload])
                        result[sender] = encodedMessage
                    } else {
                        return nil
                    }
                }

                return result
            }
        }

        return nil
    }

    private func postProcess(_ data: [String: EncodedMessage]?) -> [String] {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return [] }
        guard let data = data else { return [] }

        let v = Array(data.values)
        let keyPair = MessageKeyPair(keyProvider: MessageKeyPairStorage(), for: meta.metaInfo.uuid)

        return MoneroWalletMessageService.shared.decode(v, keyPair: keyPair)
    }
}
