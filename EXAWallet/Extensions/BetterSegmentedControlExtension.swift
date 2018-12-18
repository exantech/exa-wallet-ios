//
// Created by Igor Efremov on 27/11/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import BetterSegmentedControl

extension BetterSegmentedControl: EXAUIStylesSupport {

    func applyStyles() {
        layer.cornerRadius = 4.0
        indicatorViewInset = 0.0
        layer.borderColor = UIColor.mainColor.cgColor
        layer.borderWidth = 2.0
    }
}
