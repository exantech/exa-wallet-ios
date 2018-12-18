//
// Created by Igor Efremov on 27/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class TransactionShortInfoView: UIView {
    private let imageView: UIImageView = UIImageView(image: nil)
    private let dateLabel = UILabel("DATE")
    private let sideImageWidth = EXAGraphicsResources.transactionType(.sent).size.width
    private var directionTypeLabel = UILabel("DIRECTION")
    private var amountLabel: AmountTransactionLabel?
    private var infoLabel: EXALabel = EXALabel("", textColor: UIColor.mainColor, font: UIFont.systemFont(ofSize: 12.0))

    convenience init(transaction: Transaction) {
        self.init(frame: CGRect.zero)

        self.backgroundColor = UIColor.clear
        self.size = CGSize(width: 250, height: 50)

        imageView.image = EXAGraphicsResources.transactionType(transaction.type)
        imageView.size = imageView.image!.size
        dateLabel.font = UIFont.systemFont(ofSize: 11.0)
        dateLabel.textColor = UIColor.grayTitleColor
        dateLabel.textAlignment = .right

        let amountString: String = EXAWalletFormatter.formattedAmount(transaction.amountString) ?? "?"
        amountLabel = AmountTransactionLabel(amountString, ticker: transaction.ticker)
        for v in [imageView, directionTypeLabel, amountLabel!, dateLabel, infoLabel] as [UIView] {
            addSubview(v)
        }

        directionTypeLabel.text = transaction.type.description
        directionTypeLabel.textAlignment = .left
        directionTypeLabel.sizeToText()

        dateLabel.text = transaction.date
        dateLabel.sizeToText()

        if transaction.confirmations == 0 {
            infoLabel.text = "Unconfirmed"
            infoLabel.textColor = UIColor.mainColor
        } else {
            if transaction.confirmations < 10 {
                infoLabel.text = "Pending (\(transaction.confirmations) of 10)"
                infoLabel.textColor = UIColor.mainColor
            } else {
                infoLabel.text = ""
                infoLabel.textColor = UIColor.mainColor
            }
        }

        infoLabel.sizeToText()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
    }

    override func layoutSubviews() {
        let sideOffset: CGFloat = 20
        let rc = self.bounds

        imageView.origin = CGPoint(x: sideOffset, y: self.center.y - imageView.size.height / 2)
        if let theAmountLabel = amountLabel {
            theAmountLabel.origin = CGPoint(x: rc.width - 20 - theAmountLabel.width, y: imageView.top)
        }

        directionTypeLabel.origin = CGPoint(x: imageView.right + 20, y: self.center.y - directionTypeLabel.height/2)
        dateLabel.origin = CGPoint(x: rc.width - 20 - dateLabel.width, y: 35)
        dateLabel.bottom = imageView.bottom

        infoLabel.origin = CGPoint(x: imageView.right + 20, y: self.center.y - directionTypeLabel.height/2)
        infoLabel.top = directionTypeLabel.bottom + 4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

