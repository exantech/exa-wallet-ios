//
// Created by Igor Efremov on 2019-02-15.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

protocol MessageKeyPairProvider {

    func encodingKeys(for walletId: String) -> (String?, String?)
    func saveEncodingKeys(publicKey: String, secretKey: String, for walletId: String)
}
