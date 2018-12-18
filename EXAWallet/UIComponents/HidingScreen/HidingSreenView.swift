//
//  HidingScreenView.swift
//
//  Created by Vladimir Malakhov on 20/06/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

final class HidingScreenView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension HidingScreenView {
    
    func setup() {
        setupLogo()
        setupStyle()
    }
    
    func setupLogo() {
        let imageView = UIImageView(image: EXAGraphicsResources.logoImage)
        addSubview(imageView)

        if let theImage = EXAGraphicsResources.logoImage {
            imageView.snp.makeConstraints { (make) in
                make.width.height.equalTo(theImage.size.width)
                make.centerY.centerX.equalToSuperview()
            }
        }
    }
    
    func setupStyle() {
        backgroundColor = UIColor.exaBlack
    }
}
