//
// Created by Igor Efremov on 04/02/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class WalletStateDataWorker {

    func process(_ data: Data?) -> SharedWalletState {
        var state = SharedWalletState()

        if let data = data {
            let json = JSON(data)
            state.status = json["status"].stringValue
            state.participants = json["participants"].uIntValue
            state.signers = json["signers"].uIntValue
            state.joined = json["joined"].uIntValue
            state.publicKeys = json["public_keys"].array?.compactMap{$0.stringValue}
        }

        return state
    }
}
