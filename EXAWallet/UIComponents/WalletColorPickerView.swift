//
// Created by Igor Efremov on 11/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

protocol WalletColorPickerViewActionDelegate: class {
    func onChangeColor()
}

class WalletColorPickerView: UIView {
    private let numOfColors = WalletColor.all.count
    private let colors: [UIColor] = WalletColor.all.map{$0.value}
    private var colorOptions: [UIView] = [UIView]()
    private let selectedItemView: EXACircleView = EXACircleView(color: WalletColor.orange.value, radius: 30)
    private var _selectedColor: WalletColor = WalletColor.orange

    weak var actionDelegate: WalletColorPickerViewActionDelegate?

    var selectedColor: WalletColor {
        return _selectedColor
    }

    var walletType: WalletType = .personal {
        didSet {
            selectedItemView.imageView.image = EXAGraphicsResources.walletBigSignImage(walletType)
            selectedItemView.imageView.size = EXAGraphicsResources.walletBigSignImage(walletType).size
        }
    }

    convenience init() {
        self.init(frame: CGRect.zero)
        initControl()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func setupColor(_ color: WalletColor) {
        _selectedColor = color
        selectedItemView.backgroundColor = _selectedColor.value
    }

    func applyLayout() {
        selectedItemView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalTo(selectedItemView.radius * 2)
            make.height.equalTo(selectedItemView.radius * 2)
            make.centerX.equalToSuperview()
        }

        let half = numOfColors/2

        colorOptions[half-1].snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.right.equalTo(selectedItemView.snp.left).offset(-20)
        }

        for index in stride(from: half - 2, through: 0, by: -1) {
            colorOptions[index].snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.width.equalTo(20)
                make.height.equalTo(20)
                make.right.equalTo(colorOptions[index + 1].snp.left).offset(-20)
            }
        }

        colorOptions[half].snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.left.equalTo(selectedItemView.snp.right).offset(20)
        }

        for index in half+1...numOfColors-1 {
            colorOptions[index].snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.width.equalTo(20)
                make.height.equalTo(20)
                make.left.equalTo(colorOptions[index - 1].snp.right).offset(20)
            }
        }

        selectedItemView.applyLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }

    @objc func onTapOption(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        guard let color = WalletColor(rawValue: view.tag) else { return }
        _selectedColor = color
        selectedItemView.backgroundColor = _selectedColor.value

        actionDelegate?.onChangeColor()
    }

    fileprivate func initControl() {
        for index in 0...numOfColors-1 {
            let v = UIView(frame: CGRect.zero)
            v.backgroundColor = WalletColor(rawValue: index)!.value
            v.layer.cornerRadius = 4.0
            v.tag = index
            v.addTapTouch(self, action: #selector(onTapOption(_ :)))

            addSubview(v)
            colorOptions.append(v)
        }

        addSubview(selectedItemView)
    }
}
