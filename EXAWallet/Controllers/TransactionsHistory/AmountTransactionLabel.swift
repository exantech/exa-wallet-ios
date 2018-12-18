//
// Created by Igor Efremov on 12/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class AmountTransactionLabel: UIView {
    private var valueLabel: UILabel = UILabel("")

    convenience init(_ amount: String, ticker: CryptoTicker) {
        self.init(frame: CGRect.zero)

        self.size = CGSize(width: 120, height: 20)

        valueLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        valueLabel.textAlignment = .right
        valueLabel.textColor = UIColor.invertedTitleLabelColor
        valueLabel.text = "\(amount) \(ticker.description)"

        addSubview(valueLabel)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func layoutSubviews() {
        valueLabel.width = self.width
        valueLabel.origin = CGPoint(x: 0, y: 6)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
