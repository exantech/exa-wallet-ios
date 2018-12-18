//
// Created by Igor Efremov on 19/05/15.
// Copyright (c) 2015 Exantech. All rights reserved.
//

import Foundation

extension Date {
    static func currentTimestamp() -> UInt64 {
        return UInt64(Date().timeIntervalSince1970 * 1000.0)
    }

    func formattedWith(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.dateFormat = format

        return formatter.string(from: self)
    }
}
