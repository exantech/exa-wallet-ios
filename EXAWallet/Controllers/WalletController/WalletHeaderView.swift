//
// Created by Igor Efremov on 06/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

class WalletHeaderView: UIView {
    static let defaultHeight: CGFloat = 100.0

    private let walletTypeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 16.0)
        lbl.textColor = UIColor.invertedTitleLabelColor
        lbl.textAlignment = .center
        return lbl
    }()

    private let walletBalance: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 36.0)
        lbl.textColor = UIColor.titleLabelColor
        lbl.textAlignment = .center
        return lbl
    }()

    private let lockedWalletBalance: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12.0)
        lbl.textColor = UIColor.exaBlack
        lbl.textAlignment = .center
        return lbl
    }()

    var walletInfo: WalletInfo? {
        didSet {
            walletTypeLabel.text = walletInfo?.metaInfo.type.description

            // TODO update balance separate
            if let theBalance = walletInfo?.balance {
                walletBalance.attributedText = attributedBalance(theBalance)
            }

            lockedBalance = walletInfo?.lockedBalance
        }
    }

    var balance: String? {
        didSet {
            if let theBalance = balance {
                let value = "\(theBalance) \(CryptoTicker.XMR)"
                walletBalance.attributedText = attributedBalance(value)
            }
        }
    }

    var lockedBalance: String? {
        didSet {
            if let theBalance = lockedBalance {
                if theBalance == "0.00" {
                    lockedWalletBalance.text = ""
                } else {
                    let value = "+ \(theBalance) \(CryptoTicker.XMR) locked"
                    lockedWalletBalance.text = value
                }
            }
        }
    }

    private func attributedBalance(_ balance: String) -> NSMutableAttributedString? {
        guard balance.length > 4 else { return nil }

        let fontSize: CGFloat = DeviceType.isWideScreen ? 36.0 : 28.0
        let fractFontSize: CGFloat = DeviceType.isWideScreen ? 24.0 : 16.0

        let attributedBalance: NSMutableAttributedString = NSMutableAttributedString(string: balance)
        let wholePartAttributes:[NSAttributedString.Key:Any] = [.foregroundColor: UIColor.titleLabelColor, .font: UIFont.boldSystemFont(ofSize: fontSize)]
        let fractAttributes:[NSAttributedString.Key:Any] = [.foregroundColor: UIColor.titleLabelColor, .font: UIFont.boldSystemFont(ofSize: fractFontSize)]
        let tickerAttributes:[NSAttributedString.Key:Any] = [.foregroundColor: UIColor.titleLabelColor, .font: UIFont.boldSystemFont(ofSize: fontSize)]

        if balance.hasPrefix(WalletInfo.hiddenBalance) {
            attributedBalance.addAttributes(tickerAttributes, range: NSRange(location: 0, length: balance.length))
            return attributedBalance
        }

        let index = balance.index(of: ".")
        let indexValue = balance.distance(from: balance.startIndex, to: index!)
        
        attributedBalance.addAttributes(wholePartAttributes, range: NSRange(location: 0, length: indexValue))
        attributedBalance.addAttributes(fractAttributes, range: NSRange(location: indexValue + 1, length: balance.length - (indexValue + 1 + 3)))
        attributedBalance.addAttributes(tickerAttributes, range: NSRange(location: balance.length - 3, length: 3))

        return attributedBalance
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initControl()
    }

    func applyStyles() {
        backgroundColor = UIColor.mainColor
    }

    func applyLayout() {
        walletTypeLabel.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }

        walletBalance.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.top.equalTo(walletTypeLabel.snp.bottom).offset(4)
            make.height.equalTo(40)
        }

        lockedWalletBalance.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(16)
        }
    }

    private func initControl() {
        addSubview(walletTypeLabel)
        addSubview(walletBalance)
        addSubview(lockedWalletBalance)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initControl()
    }
}
