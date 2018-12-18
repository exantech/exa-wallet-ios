//
// Created by Igor Efremov on 01/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

class AmountHeaderView: UIView {
    static let defaultHeight: CGFloat = 60.0

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        let fontSize: CGFloat = DeviceType.isWideScreen ? 36.0 : 28.0
        lbl.font = UIFont.boldSystemFont(ofSize: fontSize)
        lbl.textColor = UIColor.invertedTitleLabelColor
        lbl.textAlignment = .center
        return lbl
    }()

    convenience init(width: CGFloat, title: String?, color: UIColor = UIColor.mainColor, textColor: UIColor = UIColor.white) {
        self.init(frame: CGRect(origin: CGPoint.zero,
                size: CGSize(width: width,
                        height: WalletsDashboardTableHeaderView.defaultHeight)))
        titleLabel.text = title
        backgroundColor = color
        titleLabel.textColor = textColor
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
            make.height.equalTo(40)
            make.top.equalTo(20)
        }
    }

    func initControl() {
        backgroundColor = UIColor.mainColor
        addSubview(titleLabel)
    }
}
