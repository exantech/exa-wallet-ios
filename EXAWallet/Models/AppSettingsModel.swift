//
// Created by Igor Efremov on 04/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class AppSettingsModel {
    var walletsList: [WalletMetaInfo]?
    var environment: EXAEnvironment

    init() {
#if LIVE
        environment = EXALiveEnvironment()
#else
        environment = EXAStageEnvironment()
#endif
    }
}
