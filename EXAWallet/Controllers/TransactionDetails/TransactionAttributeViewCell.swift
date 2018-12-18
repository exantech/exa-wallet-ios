//
// Created by Igor Efremov on 01/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class TransactionAttributeViewCell: EXATableViewCell {
    var view: TransactionAttributeView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let view = view else { return }
            contentView.addSubview(view)
        }
    }

    init(attributeList: TransactionAttributesList, attribute: TransactionAttribute, actionDelegate: TransactionDetailsActionDelegate? = nil) {
        super.init(style: .default, reuseIdentifier: "TransactionAttributeViewCell")
        let view = TransactionAttributeView(attributeList: attributeList, attribute: attribute)
        view.actionDelegate = actionDelegate
        self.view = view
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(view)
    }

    init(view: TransactionAttributeView) {
        super.init(style: .default, reuseIdentifier: "TransactionAttributeViewCell")
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
