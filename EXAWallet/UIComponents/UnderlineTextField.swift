//
//  UnderlineTextField.swift
//  EXAWallet
//
//  Created by Igor Efremov on 07/02/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit

class UnderlineTextField: UITextField {
    private var placeholderColor: UIColor = UIColor.placeholderDarkColor
    
    convenience init(_ placeholder: String, color: UIColor = UIColor.placeholderDarkColor) {
        self.init(frame: CGRect.zero)
        placeholderColor = color
        attributedPlaceholder = NSAttributedString(string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor : color])
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initControl()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }

    func initControl() {
        applyStyles()
    }

    func applyStyles() {
        backgroundColor = UIColor.clear
        textColor = UIColor.titleLabelColor
        keyboardAppearance = .dark
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        useUnderline(color: placeholderColor)
    }
}


