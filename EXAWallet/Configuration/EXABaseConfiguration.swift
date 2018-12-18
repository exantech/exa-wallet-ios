//
// Created by Igor Efremov on 14/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class EXABaseConfiguration: EXAConfiguration {
    var apiVersion: APIVersion {
        return .v1
    }

    var apiSecure: Bool {
        return true
    }

    var apiHost: String {
        return "mws-stage.exan.tech"
    }

    var apiPort: Int? {
        return nil
    }
}
