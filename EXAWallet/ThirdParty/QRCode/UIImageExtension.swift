//
// Created by Igor Efremov on 27/03/15.
// Copyright (c) 2015 Exantech. All rights reserved.
//

import UIKit

extension UIImage {
    func tintImage(_ tintColor: UIColor?) -> UIImage {
        if tintColor == nil {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)

        if let context: CGContext = UIGraphicsGetCurrentContext() {
            let imageRect: CGRect = CGRect(x: CGPoint.zero.x, y: CGPoint.zero.y, width: self.size.width, height: self.size.height)

            context.saveGState()
            context.setBlendMode(.multiply)
            context.setFillColor(tintColor!.cgColor)
            context.fill(imageRect)

            self.draw(in: imageRect, blendMode: .destinationIn, alpha: 1)

            context.restoreGState()

            let outputImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return outputImage
        } else {
            return self
        }
    }
}
