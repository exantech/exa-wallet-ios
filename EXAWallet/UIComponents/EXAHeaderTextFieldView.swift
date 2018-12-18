//
// Created by Igor Efremov on 04/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

class EXAHeaderStaticLabel: UILabel {
    init(_ text: String) {
        super.init(frame: .zero)
        self.text = text
        font = UIFont.systemFont(ofSize: 14.0)
        textAlignment = .left
        textColor = .grayTitleColor
        sizeToText()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class EXAHeaderTextFieldView: UIView, UITextFieldDelegate {
    private var _headerStaticLabel: EXAHeaderStaticLabel!
    private var _textField: UnderlineTextField!

    var textField: UnderlineTextField {
        return _textField
    }

    var isSecure: Bool = false
    var text: String {
        return textField.text ?? ""
    }

    var defaultHeight: CGFloat {
        return 52
    }

    init(_ placeholder: String, header: String,
                     textColor: UIColor = UIColor.titleLabelColor, placeHolderColor: UIColor = UIColor.placeholderDarkColor) {
        super.init(frame: CGRect.zero)

        initControl()
        _headerStaticLabel = EXAHeaderStaticLabel(header)
        _textField = UnderlineTextField(placeholder, color: placeHolderColor)
        _textField.textColor = textColor
        _textField.delegate = self

        self.addSubview(_headerStaticLabel)
        self.addSubview(_textField)
    }

    func applyStyles() {
        if isSecure {
            _textField.autocorrectionType = .no
            _textField.autocapitalizationType = .none
            _textField.isSecureTextEntry = true
        }
    }

    func applyLayout() {
        _headerStaticLabel.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(16)
            make.top.left.width.equalToSuperview()
        }

        _textField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(_headerStaticLabel.snp.bottom).offset(6)
            make.height.equalTo(30)
            make.left.width.equalToSuperview()
        }
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return _textField.resignFirstResponder()
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = resignFirstResponder()
        return true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }

    private func initControl() {}
}
