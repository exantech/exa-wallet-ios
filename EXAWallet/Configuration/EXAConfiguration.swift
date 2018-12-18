//
// Created by Igor Efremov on 14/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol EXAConfiguration {
    var apiVersion: APIVersion { get }
    var apiSecure: Bool { get }
    var apiHost: String { get }
    var apiPort: Int? { get }
}
