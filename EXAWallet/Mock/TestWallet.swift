//
// Created by Igor Efremov on 08/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class TestWallet {
    class func mnemonic() -> String {
        guard let testMnemonic = EXACommon.loadApiKey(MoneroCommonConstants.testMnemonicFile) else {
            return ""
        }
        
        return testMnemonic
    }
}
