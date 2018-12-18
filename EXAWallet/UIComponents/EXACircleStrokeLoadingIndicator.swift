//
//  EXACircleStrokeLoadingIndicator.swift
//  EXAWallet
//
//  Created by Igor Efremov on 26/02/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit

class EXACircleStrokeLoadingIndicator: UIView {
    private let innerSize: CGSize = CGSize(width: 44, height: 44)
    private let loaderView: UIView = UIView(frame: CGRect.zero)
    private let logoImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "sync_progress"))
    private let strokeCircleColor: UIColor = UIColor.rgb(0x8d8d90)
    
    private(set) public var isAnimating: Bool = false
    private var strokeCircleLayer: CALayer?
    private let textLabel: EXALabel = {
        let lbl = EXALabel("")
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 20.0)
        return lbl
    }()

    var fullScreenMode: Bool = false
    
    convenience init(_ text: String? = nil) {
        self.init(frame: CGRect.zero)
        if let theText = text {
            textLabel.text = theText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loaderView.frame = CGRect(origin: CGPoint.zero, size: innerSize)
        loaderView.backgroundColor = UIColor.clear
        self.addSubview(loaderView)
        self.backgroundColor = UIColor.clear
        initControl()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loaderView.center = convert(self.center, from: self.superview)
        textLabel.center = CGPoint(x: loaderView.center.x, y: loaderView.center.y - 60)
        textLabel.width = self.bounds.width
        textLabel.height = 24
    }
    
    func startAnimating() {
        isHidden = false
        isAnimating = true
        loaderView.layer.speed = 1
        setUpAnimation()

        if fullScreenMode {
            animateBackgroundColor(UIColor.rgba(0x000000de))
        }
    }
    
    func stopAnimating() {
        isHidden = true
        isAnimating = false
        strokeCircleLayer?.removeAllAnimations()
        strokeCircleLayer?.removeFromSuperlayer()

        if fullScreenMode {
            animateBackgroundColor(UIColor.clear)
        }
    }
    
    private func initControl() {
        let theLoaderImage = #imageLiteral(resourceName: "sync_progress")
        guard let outerCircle = outerCircleLayer(UIColor.rgb(0xe5e5e5)) else { return }

        logoImageView.size = theLoaderImage.size
        logoImageView.center = convert(loaderView.center, from: loaderView.superview)
        loaderView.addSubview(logoImageView)
        self.addSubview(textLabel)

        applyCircleMask()
        loaderView.layer.addSublayer(outerCircle)
    }
    
    private func outerCircleLayer(_ color: UIColor) -> CALayer? {
        let theLoaderImage = #imageLiteral(resourceName: "sync_progress")

        let outerCircleDistance: CGFloat = 4
        let imgSize = theLoaderImage.size
        let imgSizeExt = CGSize(width: imgSize.width + outerCircleDistance, height: imgSize.height + outerCircleDistance)
        
        let outerCircle = layerWith(size: imgSizeExt, color: color)
        let outerCircleFrame = CGRect(
            x: (loaderView.layer.bounds.width - imgSizeExt.width)/2,
            y: (loaderView.layer.bounds.height - imgSizeExt.height)/2,
            width: imgSizeExt.width,
            height: imgSizeExt.height
        )
        
        outerCircle.frame = outerCircleFrame
        return outerCircle
    }
    
    private func applyCircleMask() {
        let c = convert(loaderView.center, from: loaderView.superview)
        let w = loaderView.frame.size.width
        let radius: CGFloat = ceil(w / 2)
        let circle = UIBezierPath(arcCenter: c, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        loaderView.mask(withPath: circle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpAnimation() {
        let beginTime: Double = 0.5
        let strokeStartDuration: Double = 1.2
        let strokeEndDuration: Double = 0.7
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.byValue = Float.pi * 2
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = strokeEndDuration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = strokeStartDuration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.beginTime = beginTime
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation, strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = strokeStartDuration + beginTime
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        strokeCircleLayer = outerCircleLayer(strokeCircleColor)
        if let theStrokeCircle = strokeCircleLayer {
            theStrokeCircle.add(groupAnimation, forKey: "animation")
            loaderView.layer.addSublayer(theStrokeCircle)
        }
    }
    
    fileprivate func layerWith(size: CGSize, color: UIColor) -> CALayer {
        let layer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        let lineWidth: CGFloat = 2
        
        path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
        radius: size.width / 2,
        startAngle: -(.pi / 2),
        endAngle: .pi + .pi / 2,
        clockwise: true)
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
    
        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
        return layer
    }
}
