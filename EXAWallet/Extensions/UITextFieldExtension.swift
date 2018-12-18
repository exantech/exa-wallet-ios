//
// Created by Igor Efremov on 29/03/16.
// Copyright (c) 2016 Exantech. All rights reserved.
//

import UIKit
import QuartzCore

class CAUnderlineLayer: CALayer {
    static let borderWidth = CGFloat(2.0)
    
    convenience init(lineColor: UIColor = UIColor.placeholderDarkColor) {
        self.init()
        self.borderColor = lineColor.cgColor
    }
    
    override init() {
        super.init()
        self.borderColor = UIColor.placeholderDarkColor.cgColor
    }

    override init(layer: Any) {
        super.init(layer: layer)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension UITextField {
    func useUnderline(color: UIColor = UIColor.placeholderDarkColor) {
        removeUnderlineLine()
        let border = createAndAddBorderLayer(color: color)
        border.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.size.height - CAUnderlineLayer.borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
    }

    func activeUnderlineLine(color: UIColor = UIColor.placeholderDarkColor) {
        removeUnderlineLine()
        let border = createAndAddBorderLayer(color: color)
        border.frame = CGRect(x: 0, y: self.frame.size.height - CAUnderlineLayer.borderWidth, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    private func createAndAddBorderLayer(color: UIColor) -> CAUnderlineLayer {
        let border = CAUnderlineLayer(lineColor: color)
        border.borderWidth = CAUnderlineLayer.borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
        return border
    }

    private func removeUnderlineLine() {
        if let theSublayers = self.layer.sublayers {
            for l in theSublayers {
                if l is CAUnderlineLayer {
                    l.removeFromSuperlayer()
                    break
                }
            }
        }
    }
}
