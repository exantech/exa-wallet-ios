//
// Created by Igor Efremov on 12/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit

class AmountInputView: UIView {
    private let amountStaticLabel: EXALabel = {
        let lbl = EXALabel(l10n(.amountTitlePlaceholder))
        lbl.textColor = UIColor.grayTitleColor
        return lbl
    }()
    
    private let amountValueField: UITextField = {
        let tf = UITextField()
        tf.keyboardAppearance = .dark
        tf.attributedPlaceholder = NSAttributedString(string: l10n(.amountValuePlaceholder),
                                                                    attributes: [NSAttributedString.Key.foregroundColor : UIColor.exaPlaceholderColor])
        tf.textColor = UIColor.invertedTitleLabelColor
        tf.tintColor = UIColor.invertedTitleLabelColor
        tf.autocorrectionType = .no
        tf.keyboardType = .decimalPad
        tf.font = UIFont.systemFont(ofSize: 36.0)
        return tf
    }()

    var incorrect: Bool = false {
        didSet {
            amountValueField.textColor = incorrect ? .localRed : .invertedTitleLabelColor
        }
    }

    var amountValue: String {
        return amountValueField.text ?? ""
    }

    convenience init() {
        self.init(frame: CGRect.zero)
        initControl()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func applyStyles() {}

    func applyLayout() {
        let topOffset: CGFloat = 20

        amountStaticLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(20)
            make.left.top.equalToSuperview().offset(topOffset)
        }

        amountValueField.snp.makeConstraints { (make) in
            make.width.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.top.equalTo(amountStaticLabel.snp.bottom).offset(10)
            make.height.equalTo(36)
        }
    }

    @objc func tfDidChange() {
        incorrect = false
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return amountValueField.resignFirstResponder()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }

    func initControl() {
        addMultipleSubviews(with: [amountStaticLabel, amountValueField])
        amountValueField.addTarget(self, action: #selector(tfDidChange), for: .editingChanged)
    }
}
