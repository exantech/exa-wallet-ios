//
// Created by Igor Efremov on 03/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

fileprivate struct SizeConstants {
    static let leftOffset: CGFloat = 132.0
}

fileprivate typealias sizes = SizeConstants

class CreateOptionView: UIView {
    private let imageView: UIImageView = UIImageView(image: nil)

    private let titleLabel: EXALabel = {
        let lbl = EXALabel("")
        lbl.textAlignment = .left
        lbl.numberOfLines = 2
        lbl.font = UIFont.boldSystemFont(ofSize: 18.0)
        return lbl
    }()

    private var _option: EXAMoneroWalletCreateOption = .createPersonal

    var selected: Bool = false {
        didSet {
            imageView.image = EXAGraphicsResources.walletCreationOptionImage(_option, inverted: selected)
        }
    }

    convenience init(option: EXAMoneroWalletCreateOption) {
        self.init(frame: CGRect.zero)

        _option = option

        self.backgroundColor = UIColor.clear

        imageView.image = EXAGraphicsResources.walletCreationOptionImage(option)
        imageView.size = imageView.image!.size

        for v in [imageView, titleLabel] as [UIView] {
            addSubview(v)
        }

        titleLabel.text = option.description
        titleLabel.textColor = option.isActive ? UIColor.titleLabelColor : UIColor.gray
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func applyLayout() {
        if let imgSize = imageView.image?.size {
            imageView.snp.makeConstraints { (make) in
                make.width.equalTo(imgSize.width)
                make.height.equalTo(imgSize.height)
                make.centerX.equalTo(68)
                make.centerY.equalToSuperview()
            }
        }

        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(80)
            make.left.equalToSuperview().offset(sizes.leftOffset)
            make.centerY.right.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
