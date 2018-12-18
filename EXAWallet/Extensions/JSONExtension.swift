//
// Created by Igor Efremov on 04/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    public init(_ jsonArray:[JSON]) {
        self.init(jsonArray.map { $0.object })
    }
}
