//
// Created by Igor Efremov on 04/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Jsonable {
    func json() -> JSON?
    func rawString() -> String?
    func rawUTF8String() -> String?
    func queryString() -> String?
}

typealias APIParam = Jsonable

extension APIParam {
    func rawString() -> String? {
        return rawUTF8String()
    }

    func rawUTF8String() -> String? {
        if let theJSON = json() {
            if let raw = try? theJSON.rawData() {
                return String(data: raw, encoding: .utf8)
            }
        }

        return nil
    }

    func queryString() -> String? {
        return nil
    }
}
