//
// Created by Igor Efremov on 22/05/15.
// Copyright (c) 2015 Exantech. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(_ text: String?) {
        self.init(frame: CGRect.zero)
        self.sizeToText(text)
    }

    convenience init(_ text: String?, textColor: UIColor, font: UIFont) {
        self.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        self.textColor = textColor
        self.font = font

        self.sizeToText(text)
    }

    func sizeOfText() -> CGSize {
        if self.text != nil {
            let string = NSString(string: self.text!)
            return string.size(withAttributes: [NSAttributedString.Key.font: self.font])
        }

        return CGSize.zero
    }

    func heightToText() {
        self.size.height = self.sizeOfText().height
    }

    func sizeToText() {
        self.size = self.sizeOfText()
    }

    func sizeToText(_ string: String?) {
        self.text = string
        self.size = self.sizeOfText()
    }
}
