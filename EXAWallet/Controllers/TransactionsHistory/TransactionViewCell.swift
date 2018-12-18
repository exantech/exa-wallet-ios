//
// Created by Igor Efremov on 27/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class TransactionViewCell: EXATableViewCell {
    var view: TransactionShortInfoView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let view = view else { return }
            contentView.addSubview(view)
        }
    }

    init(transaction: Transaction) {
        super.init(style: .default, reuseIdentifier: "TransactionViewCell")
        let view = TransactionShortInfoView(transaction: transaction)
        self.view = view
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(view)
    }

    init(view: TransactionShortInfoView) {
        super.init(style: .default, reuseIdentifier: "TransactionViewCell")
        view.removeFromSuperview()
        self.view = view
        backgroundColor = UIColor.clear
        contentView.addSubview(view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func layoutSubviews() {
        view?.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: frame.width,
                        height: frame.height))
    }
}
