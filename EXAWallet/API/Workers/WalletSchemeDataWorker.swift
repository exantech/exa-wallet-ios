//
// Created by Igor Efremov on 2019-02-25.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class WalletSchemeDataWorker {

    func process(_ data: Data?) -> SharedWalletScheme {
        if let data = data {
            let json = JSON(data)

            let signers = json["signers"].uIntValue
            let participants = json["participants"].uIntValue

            return SharedWalletScheme(signers, participants)
        }

        return SharedWalletScheme.None
    }
}
