//
// Created by Igor Efremov on 12/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

protocol PaymentIdInputViewActionDelegate: class {
    func onGeneratePaymentId()
}

class PaymentIdInputView: UIView {
    private let paymentIDTextField: EXAHeaderTextFieldView = {
        let tf = EXAHeaderTextFieldView(l10n(.paymentIdDescription), header: l10n(.paymentIdTitle),
                textColor: UIColor.invertedTitleLabelColor, placeHolderColor: UIColor.exaPlaceholderColor)
        tf.textField.autocorrectionType = .no
        tf.textField.returnKeyType = .continue
        tf.textField.font = UIFont.systemFont(ofSize: 12.0)
        tf.textField.tintColor = UIColor.invertedTitleLabelColor
        return tf
    }()

    private let generatePaymentIdActionLabel: UILabel = {
        let lbl = UILabel(l10n(.paymentIdGenerate), textColor: UIColor.mainColor,
                font: UIFont.boldSystemFont(ofSize: 12.0))
        lbl.textAlignment = .right
        return lbl
    }()

    var incorrect: Bool = false {
        didSet {
            paymentIDTextField.textField.textColor = incorrect ? .localRed : .invertedTitleLabelColor
        }
    }

    var paymentID: String? {
        set {
            paymentIDTextField.textField.text = newValue
        }

        get {
            return paymentIDTextField.textField.text
        }
    }

    weak var actionDelegate: PaymentIdInputViewActionDelegate?

    convenience init() {
        self.init(frame: CGRect.zero)
        initControl()

        generatePaymentIdActionLabel.addTapTouch(self, action: #selector(onGeneratePaymentIdTap))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func applyStyles() {
        paymentIDTextField.applyStyles()
    }

    func applyLayout() {
        let topOffset: CGFloat = 22
        let sideOffset: CGFloat = 20

        paymentIDTextField.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview().inset(sideOffset)
            make.centerX.equalToSuperview()
            make.height.equalTo(paymentIDTextField.defaultHeight)
            make.top.equalToSuperview().offset(topOffset)
        }

        generatePaymentIdActionLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topOffset)
            make.right.equalToSuperview().offset(-sideOffset)
            make.height.equalTo(16)
        }

        paymentIDTextField.applyLayout()
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return paymentIDTextField.resignFirstResponder()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }

    func initControl() {
        let allSubviews = [paymentIDTextField, generatePaymentIdActionLabel]
        addMultipleSubviews(with: allSubviews)
    }

    @objc func onGeneratePaymentIdTap() {
        actionDelegate?.onGeneratePaymentId()
    }
}
