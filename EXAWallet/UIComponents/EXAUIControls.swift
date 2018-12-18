//
//  EXAUIControls.swift
//  EXAWallet
//
//  Created by Igor Efremov on 02/02/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import QuartzCore

enum EXAButtonStyle: UInt {
    case filled = 0, hollow
}

class EXAUIControlsKit {
    class func createAddressLabel(_ font: UIFont = UIFont.systemFont(ofSize: 14.0)) -> UILabel {
        let label = UILabel("", textColor: UIColor.titleLabelColor, font: font)
        label.lineBreakMode = .byTruncatingMiddle
        
        return label
    }
}

class EXAPhraseTextView: UITextView {
    private var restoreMode: Bool = false

    var valid: Bool = true {
        didSet {
            layer.borderColor = valid ? UIColor.placeholderDarkColor.cgColor : UIColor.localRed.cgColor
        }
    }

    convenience init(restoreMode value: Bool) {
        self.init(frame: CGRect.zero)
        self.restoreMode = value
        initControl()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }
    
    private func initControl() {
        backgroundColor = UIColor.clear

        textAlignment = .center
        font = UIFont.boldSystemFont(ofSize: 16.0)
        textColor = UIColor.titleLabelColor
        isEditable = restoreMode
        isScrollEnabled = false
        isSelectable = restoreMode
#if TEST
        isSelectable = true
#endif
        showsVerticalScrollIndicator = false
        keyboardAppearance = .dark

        if restoreMode {
            layer.borderColor = UIColor.placeholderDarkColor.cgColor
            layer.borderWidth = 1
            layer.cornerRadius = 10.0
            autocapitalizationType = .none
            autocorrectionType = .no
            textAlignment = .left
            keyboardType = .alphabet
            becomeFirstResponder()
        }
    }
}

class EXAButton: UIButton {
    private var color: UIColor = UIColor.mainColor
    static let defaultHeight: CGFloat = 44.0
    
    var style: EXAButtonStyle = .filled {
        didSet {
            if .hollow == style {
                backgroundColor = UIColor.white
                setTitleColor(color, for: .normal)
                
                layer.borderColor = color.cgColor
                layer.borderWidth = 1
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = color
            } else {
                backgroundColor = UIColor.inactiveColor
            }
        }
    }
    
    convenience init(with title: String?, color: UIColor = UIColor.mainColor, height: CGFloat = EXAButton.defaultHeight) {
        self.init(frame: CGRect.zero)
        self.color = color
        self.height = height
        initControl()
        setTitle(title, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initControl()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }
    
    fileprivate func initControl() {
        layer.cornerRadius = height / 2
        titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        backgroundColor = color
    }
}

class EXACircleView: UIView {
    private var _radius: CGFloat = 0.0
    var imageView: UIImageView = UIImageView(image: nil)
    var hasImgOffset: Bool = false

    var radius: CGFloat {
        return _radius
    }

    convenience init(color value: UIColor, radius: CGFloat) {
        self.init(frame: CGRect.zero)
        backgroundColor = value
        _radius = radius
        initControl()
    }

    func applyLayout() {
        layer.cornerRadius = _radius
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }

    fileprivate func initControl() {
        size = CGSize(width: _radius * 2, height: _radius * 2)
        imageView.contentMode = .scaleAspectFit

        addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.center.y = self.bounds.height / 2
        imageView.center.x = self.bounds.width / 2 + (hasImgOffset ? 2 : 0)
    }
}
