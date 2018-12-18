//
// Created by Igor Efremov on 20/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import XCTest

class EXAWalletTestUtils {
    class func isWalletWithSameNameAlreadyExist(_ walletName: String) -> Bool {
        let service = EXAWalletMetaInfoStorageService()
        guard service.load() == true else {
            XCTAssert(false, "Meta not loaded")
            return true
        }

        return service.isAlreadyExist(walletName)
    }
}
