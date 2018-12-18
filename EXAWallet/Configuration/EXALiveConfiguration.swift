//
// Created by Igor Efremov on 2019-05-25.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class EXALiveConfiguration: EXAConfiguration {
    var apiVersion: APIVersion {
        return .v1
    }

    var apiSecure: Bool {
        return true
    }

    var apiHost: String {
        return "mws.exan.tech"
    }

    var apiPort: Int? {
        return nil
    }
}
