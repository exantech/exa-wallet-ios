//
//  PasswordStrengthIndicator.swift
//  EXAWallet
//
//  Created by Igor Efremov on 21/02/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import QuartzCore

enum PasswordStrength: Int {
    case empty, weak, med, strong
}

class PasswordStrengthIndicator: UIView {
    var lineFilledView: UIView = UIView(frame: CGRect.zero)
    var strength: PasswordStrength = .empty {
        didSet {
            let rc = self.bounds
            var toColor: UIColor = UIColor.clear
            var toWidth: CGFloat = 0.0
            
            switch strength {
                case .weak:
                    toColor = UIColor.rgb(0xff4100)
                    toWidth = rc.size.width / 3
                case .med:
                    toColor = UIColor.rgb(0xffb400)
                    toWidth = 2 * rc.size.width / 3
                case .strong:
                    toColor = UIColor.rgb(0x46be00)
                    toWidth = rc.size.width
                default:
                    noop()
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self.lineFilledView.backgroundColor = toColor
                self.lineFilledView.width = toWidth
                self.lineFilledView.origin = CGPoint.zero
            })
        }
    }
    
    var indicatorHeight: CGFloat {
        get {
            return 2.0
        }
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        initControl()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }
    
    func initControl() {
        lineFilledView.height = indicatorHeight
        lineFilledView.backgroundColor = UIColor.red
        addSubview(lineFilledView)
        backgroundColor = UIColor.clear
    }
}
