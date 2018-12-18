//
// Created by Igor Efremov on 2019-02-05.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class EXAMath {

    class func seed() -> UInt32 {
        return arc4random_uniform(UInt32.max)
    }
}
