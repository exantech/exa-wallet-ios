//
// Created by Igor Efremov on 20/05/15.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import QuartzCore

extension UIView {
    var width: CGFloat {
        get {
            return self.bounds.size.width
        }
        set {
            var bounds = self.bounds
            bounds.size.width = newValue
            self.bounds = bounds
        }
    }

    var height: CGFloat {
        get {
            return self.bounds.size.height
        }
        set {
            var bounds = self.bounds
            bounds.size.height = newValue
            self.bounds = bounds
        }
    }

    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }

    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.height
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue - self.height
            self.frame = frame
        }
    }

    var right: CGFloat {
        get {
            return self.frame.origin.x + self.width
        }
        set {
            if self.superview != nil {
                let r = self.superview!.width - newValue
                
                var frame = self.frame
                frame.origin.x = r - self.width
                self.frame = frame
            }
        }
    }

    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }

    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }

    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }

    func addTapTouch(_ target: AnyObject, action: Selector) {
        self.isUserInteractionEnabled = true

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }

    func addTapTouchAndReturnRecognizer(_ target: AnyObject, action: Selector) -> UITapGestureRecognizer {
        self.isUserInteractionEnabled = true

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)

        return tap
    }

    func removeTapTouch(_ tapRecognizer: UITapGestureRecognizer) {
        self.removeGestureRecognizer(tapRecognizer)
    }

    func addPanTouch(_ target: AnyObject, action: Selector) {
        self.isUserInteractionEnabled = true
        let tap: UIPanGestureRecognizer = UIPanGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(tap)
    }

    func animateBackgroundColor(_ color: UIColor) {
        UIView.animate(withDuration: 0.3, animations: {
            self.layer.backgroundColor = color.cgColor
        })
    }
    
    @available(iOS 10.0, *)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

    func snapshotImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            return self.asImage()
        }
        else {
            if let theWindow = self.window {
                 UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, theWindow.screen.scale)
                 self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
                 let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
                 UIGraphicsEndImageContext()
                 return snapshotImage
            }
            
            return nil
        }
    }

    func configureGradientBackground(_ colors: CGColor...) {
        let gradient: CAGradientLayer = CAGradientLayer()
        let maxWidth = max(self.bounds.size.height, self.bounds.size.width)
        let squareFrame = CGRect(origin: self.bounds.origin, size: CGSize(width: maxWidth, height: maxWidth))
        gradient.frame = squareFrame

        gradient.colors = colors
        self.layer.insertSublayer(gradient, at: 0)
    }

    func frameOfCenteredView(_ viewToCenter: UIView) -> CGRect {
        let containerViewSize = self.bounds.size
        let viewSize = viewToCenter.frame.size

        var p: CGPoint = CGPoint.zero
        p.x = floor((containerViewSize.width - viewSize.width)/2)
        p.y = floor((containerViewSize.height - viewSize.height)/2)

        return CGRect(origin: p, size: viewSize)
    }
    
    func rounded(_ opaqueBorderColor: Bool = false) {
        layer.cornerRadius = frame.width/2
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }

    func shake(delegate: CAAnimationDelegate) {
        let animationKeyPath = "transform.translation.x"
        let shakeAnimation = "shake"
        let duration = 0.6
        let animation = CAKeyframeAnimation(keyPath: animationKeyPath)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        animation.delegate = delegate
        layer.add(animation, forKey: shakeAnimation)
    }
    
    func mask(withPath path: UIBezierPath) {
        let path = path
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    func addMultipleSubviews(with subviews: [UIView?]) {
        subviews.compactMap{$0}.forEach{addSubview($0)}
    }
}

class Indicator: UIView {
    
    var isNeedClear = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rounded()
    }
}

class ImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class Button: UIButton, EXAUIStylesSupport {
    func applyStyles() {
        titleLabel?.font = UIFont.systemFont(ofSize: 32.0, weight: .thin)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
