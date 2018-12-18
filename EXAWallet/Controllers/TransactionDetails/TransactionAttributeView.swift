//
// Created by Igor Efremov on 01/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class TransactionAttributeView: UIView {
    private let imageView: UIImageView = UIImageView(image: nil)
    private let sideImageWidth = EXAGraphicsResources.transactionType(.sent).size.width

    private var viewBtn: EXAButton? = nil
    private var _attribute: TransactionAttribute?

    weak var actionDelegate: TransactionDetailsActionDelegate?

    private let titleLabel: UILabel = {
        let lb = UILabel("", textColor: UIColor.grayTitleColor, font: UIFont.systemFont(ofSize: 16.0))
        lb.textAlignment = .left
        return lb
    }()

    private let valueLabel: UILabel = {
        let lb = UILabel("", textColor: UIColor.invertedTitleLabelColor, font: UIFont.boldSystemFont(ofSize: 16.0))
        lb.lineBreakMode = .byCharWrapping
        lb.numberOfLines = 3
        lb.textAlignment = .right
        lb.height = 48
        return lb
    }()

    convenience init(attributeList: TransactionAttributesList, attribute: TransactionAttribute) {
        self.init(frame: CGRect.zero)

        self.backgroundColor = UIColor.clear
        self.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]

        _attribute = attribute

        if attribute.type == .action {
            viewBtn = EXAButton(with: attribute.description)
            viewBtn?.addTarget(self, action: #selector(onTapViewInBlockchain), for: .touchUpInside)
        } else {
            titleLabel.text = attribute.description
            valueLabel.text = attributeList.txAttribute(by: attribute)
            valueLabel.textColor = UIColor.invertedTitleLabelColor
            if attribute == .paymentId || attribute == .txHash || attribute == .destination {
                imageView.image = EXAGraphicsResources.copy
                imageView.size = EXAGraphicsResources.copy.size
                imageView.addTapTouch(self, action: #selector(onCopyToClipboardTap))
                self.addTapTouch(self, action: #selector(onCopyToClipboardTap))

                valueLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
                valueLabel.textAlignment = .left
            }
        }

        [titleLabel, valueLabel, imageView, viewBtn].compactMap{$0}.forEach{addSubview($0)}
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
    }

    override func layoutSubviews() {
        guard let theAttribute = _attribute else { return }

        let sideOffset: CGFloat = 20
        let rc = self.bounds

        titleLabel.top = sideOffset
        titleLabel.left = sideOffset
        titleLabel.width = rc.width

        if theAttribute == .paymentId || theAttribute == .txHash || theAttribute == .destination {
            imageView.top = self.center.y - imageView.size.height / 2
            imageView.right = 0

            valueLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            valueLabel.textAlignment = .left

            valueLabel.width = rc.width - 100
            valueLabel.height = 48
            valueLabel.top = 50
            valueLabel.left = sideOffset
        } else {
            valueLabel.top = sideOffset
            valueLabel.height = 20
            valueLabel.width = rc.width
            valueLabel.right = sideOffset
        }

        viewBtn?.width = rc.width - 2 * sideOffset
        viewBtn?.height = EXAButton.defaultHeight
        viewBtn?.center = self.center
    }

    @objc func onTapViewInBlockchain() {
        actionDelegate?.showCurrentTxInBlockchain()
    }

    @objc func onCopyToClipboardTap() {
        actionDelegate?.copyToClipboard(valueLabel.text)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
