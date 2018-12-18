//
// Created by Igor Efremov on 31/01/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class EXALocalConfiguration: EXAConfiguration {
    var apiVersion: APIVersion {
        return .v1
    }

    var apiSecure: Bool {
        return false
    }

    var apiHost: String {
        return "localhost"
    }

    var apiPort: Int? {
        return 5000
    }
}
