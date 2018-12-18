//
// Created by Igor Efremov on 01/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class EXAView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initControl()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }

    func initControl() {
        backgroundColor = UIColor.white
    }
}
