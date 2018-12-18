//
// Created by Igor Efremov on 31/01/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class ConfigurationSelector {
    static let shared = ConfigurationSelector()

    var currentConfiguration: EXAConfiguration {
#if LIVE
        return EXALiveConfiguration()
#else
        return EXABaseConfiguration()
#endif
    }
}
