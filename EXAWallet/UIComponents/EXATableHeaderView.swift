//
// Created by Igor Efremov on 12/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class EXATableHeaderView: UIView {
    static let defaultHeight: CGFloat = 60.0

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 16.0)
        lbl.textAlignment = .left
        return lbl
    }()

    private let infoLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12.0)
        lbl.textColor = UIColor.valueLabelColor
        lbl.textAlignment = .right
        return lbl
    }()

    var info: String = "" {
        didSet {
            infoLabel.text = info
        }
    }

    convenience init(width: CGFloat, title: String?, info: String? = nil, color: UIColor = UIColor.mainColor, textColor: UIColor = UIColor.white) {
        self.init(frame: CGRect(origin: CGPoint.zero,
                size: CGSize(width: width,
                        height: WalletsDashboardTableHeaderView.defaultHeight)))
        backgroundColor = color

        titleLabel.text = title
        titleLabel.textColor = textColor

        infoLabel.text = info
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

        infoLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }

    func initControl() {
        backgroundColor = UIColor.mainColor
        addSubview(titleLabel)
        addSubview(infoLabel)
    }
}
