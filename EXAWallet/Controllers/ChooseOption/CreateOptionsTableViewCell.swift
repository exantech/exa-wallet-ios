//
// Created by Igor Efremov on 03/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class CreateOptionsTableViewCell: EXATableViewCell {
    private var innerView: CreateOptionView?

    init(option: EXAMoneroWalletCreateOption) {
        super.init(style: .default)
        backgroundColor = UIColor.red

        innerView = CreateOptionView(option: option)
        contentView.addMultipleSubviews(with: [innerView])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        innerView?.selected = selected
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    func applyLayout() {
        guard let v = innerView else {
            return
        }

        v.snp.makeConstraints { (make) in
            make.top.left.width.height.equalToSuperview()
        }

        v.applyLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
    }
}
