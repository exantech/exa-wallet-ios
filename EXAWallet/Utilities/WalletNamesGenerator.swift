//
// Created by Igor Efremov on 29/01/2019.
// Copyright (c) 2019 EXANTE. All rights reserved.
//

import Foundation
#if TEST
    import SwiftRandom
#endif

final class WalletNamesGenerator {

    class func generatedName() -> String {
#if TEST
        return Randoms.randomFakeName() + " Shared " + String(Randoms.randomInt(1, 9))
#else
        return ""
#endif
    }
}
