//
// Created by Igor Efremov on 06/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import QuartzCore
import SnapKit

class WalletsDashboardTableHeaderView: UIView {
    weak var actionDelegate: WalletsDashboardActionDelegate?

    static let defaultHeight: CGFloat = 80.0

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 16.0)
        lbl.textColor = UIColor.titleLabelColor
        lbl.textAlignment = .left
        return lbl
    }()

    private let addActionView: UIImageView = {
        let iv = UIImageView(image: EXAGraphicsResources.addImage)
        iv.size = EXAGraphicsResources.addImage.size
        return iv
    }()

    convenience init(width: CGFloat, title: String) {
        self.init(frame: CGRect(origin: CGPoint.zero,
                size: CGSize(width: width,
                        height: WalletsDashboardTableHeaderView.defaultHeight)))
        titleLabel.text = title
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initControl()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }

    func applyLayout() {
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(30)
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }

        let sz = EXAGraphicsResources.addImage.size
        addActionView.snp.makeConstraints { (make) in
            make.width.equalTo(sz.width)
            make.height.equalTo(sz.height)
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
        }
    }

    @objc func onTapAdd() {
        actionDelegate?.addWallet()
    }

    private func initControl() {
        backgroundColor = UIColor.mainColor
        addSubview(titleLabel)
        addSubview(addActionView)

        addActionView.addTapTouch(self, action: #selector(onTapAdd))
    }
}
