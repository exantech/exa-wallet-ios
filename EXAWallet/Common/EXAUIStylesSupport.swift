//
// Created by Igor Efremov on 25/05/15.
// Copyright (c) 2015 Exantech. All rights reserved.
//

import Foundation

enum ComponentStyle {
    case light, dark
}

@objc
protocol EXAUIStylesSupport: class {
    func applyStyles()
}
