//
// Created by Igor Efremov on 26/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import QuartzCore

class ContainerCornerRoundView: UIView {
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
        layer.cornerRadius = 6.0
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowColor = UIColor.black.cgColor
    }
}
