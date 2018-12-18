//
// Created by Igor Efremov on 12/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

protocol RecipientViewActionDelegate: class {
    func scanQR()
}

class RecipientView: UIView {
    private var _addressValue: String = ""
    
    private let recipientAddressStaticLabel: UILabel = UILabel("To")
    private let addressValueView: UITextView = {
        let tv = UITextView()
        tv.keyboardAppearance = .dark
        tv.tintColor = UIColor.invertedTitleLabelColor
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        tv.textContainer.lineBreakMode = .byTruncatingMiddle
        return tv
    }()

    private let addressValuePlaceholderLabel: EXALabel = {
        let lb = EXALabel(l10n(.sendAddressPlaceholder))
        lb.textAlignment = .left
        lb.font = UIFont.systemFont(ofSize: 13.0)
        lb.textColor = .exaPlaceholderColor
        return lb
    }()

    private let scanQRImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "scan_qr"))

    weak var actionDelegate: RecipientViewActionDelegate?

    var incorrect: Bool = false {
        didSet {
            addressValueView.textColor = incorrect ? .localRed : .invertedTitleLabelColor
        }
    }

    var addressValue: String {
        get {
            //return _addressValue
            return addressValueView.text!
        }

        set {
            _addressValue = newValue
            addressValueView.text = _addressValue
            tfDidChange()
        }
    }

    convenience init() {
        self.init(frame: CGRect.zero)
        initControl()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func applyStyles() {
        recipientAddressStaticLabel.textColor = UIColor.grayTitleColor
    }

    func updateUI() {
        togglePlaceholderIfNeeded(addressValueView)
    }

    func applyLayout() {
        let topOffset: CGFloat = 20

        recipientAddressStaticLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(20)
            make.left.top.equalToSuperview().offset(topOffset)
        }

        addressValueView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().inset(20)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(recipientAddressStaticLabel.snp.bottom).offset(10)
            make.height.equalTo(52)
        }

        addressValuePlaceholderLabel.snp.makeConstraints { (make) in
            make.width.equalTo(addressValueView)
            make.left.equalTo(addressValueView).offset(4)
            make.top.equalTo(addressValueView).offset(6)
            make.height.equalTo(18)
        }

        scanQRImageView.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }

    func initControl() {
        addMultipleSubviews(with: [recipientAddressStaticLabel, addressValueView, addressValuePlaceholderLabel, scanQRImageView])
        scanQRImageView.addTapTouch(self, action: #selector(onTapScan))
        addressValueView.delegate = self
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return addressValueView.resignFirstResponder()
    }

    @objc func onTapScan() {
        actionDelegate?.scanQR()
    }

    private func tfDidChange() {
        incorrect = false
    }
}

extension RecipientView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        togglePlaceholderIfNeeded(textView)
        tfDidChange()
    }

    private func togglePlaceholderIfNeeded(_ textView: UITextView) {
        let alpha: CGFloat = textView.text.isEmpty ? 1 : 0
        if alpha != addressValuePlaceholderLabel.alpha {
            UIView.animate(withDuration: 0.1) {
                self.addressValuePlaceholderLabel.alpha = alpha
            }
        }
    }
}

