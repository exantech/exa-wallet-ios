//
// Created by Igor Efremov on 2019-04-16.
// Copyright (c) 2019 EXANTE. All rights reserved.
//

import Foundation
import KeychainAccess

class SafeStorage {
    private let appKeychain = Keychain(service: "eu.exante.exawallet")

    func save(key: String, value: String) {
        do {
            try appKeychain
                    .accessibility(.whenUnlocked)
                    .set(value, key: key)
        } catch let error {
            print("error: \(error)")
        }
    }

    func load(_ key: String) -> String? {
        if let value = try? appKeychain.get(key), let theValue = value {
            return theValue
        }

        return nil
    }
}
