//
// Created by Igor Efremov on 18/12/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

class AboutViewController: BaseViewController {
    private let versionInfoLabel: EXALabel = {
        let lbl = EXALabel("Version: " + EXAAppInfoService.appVersion + (AppState.sharedInstance.settings.environment.isMainNet ? "" : " (STAGE)"))
        lbl.textColor = UIColor.grayTitleColor
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        return lbl
    }()

    private let titleLabel: EXALabel = {
        let fontSize: CGFloat = DeviceType.isWideScreen ? 16.0 : 14.0
        let lbl = EXALabel("The First Secure & Shared Monero Wallet")
        lbl.textColor = UIColor.mainColor
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: fontSize)
        return lbl
    }()

    private let subTitleLabel: EXALabel = {
        let fontSize: CGFloat = DeviceType.isWideScreen ? 14.0 : 12.0
        let lbl = EXALabel("Receive, spend and store your Monero with\nan open-source multisignature wallet")
        lbl.textColor = UIColor.exaBlack
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.font = UIFont.boldSystemFont(ofSize: fontSize)
        return lbl
    }()

    private let aboutText: UITextView = {
        let tv = UITextView(frame: CGRect.zero)
        tv.backgroundColor = UIColor.white
        tv.autocapitalizationType = .none
        tv.autocorrectionType = .no
        tv.textAlignment = .left
        tv.font = UIFont.systemFont(ofSize: 13.0)
        tv.textColor = UIColor.exaBlack
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.showsVerticalScrollIndicator = true
        tv.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return tv
    }()

    private let bottomView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.mainColor
        return v
    }()

    private let logoImageView: UIImageView = UIImageView(image: EXAGraphicsResources.logoWithText)

    private let telegramImageView: UIImageView = UIImageView(image: EXAGraphicsResources.telegram)
    private let telegramImageSize = EXAGraphicsResources.telegram.size
    private let telegramStaticLabel: EXALabel = EXALabel(EXAAppInfoService.telegramChannel, textColor: UIColor.white,
            font: UIFont.systemFont(ofSize: 13.0, weight: .medium))
    private let telegramTapArea: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.clear
        return view
    }()

    private let exantechImageView: UIImageView = UIImageView(image: EXAGraphicsResources.logoExantech)
    private let exantechImageSize = EXAGraphicsResources.logoExantech.size
    private let exantechStaticLabel: EXALabel = {
        let lbl = EXALabel(l10n(.exantech))
        lbl.textColor = UIColor.white
        lbl.textAlignment = .right
        lbl.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
        return lbl
    }()

    private let exantechTapArea: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.clear
        return view
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About EXAWallet"
        view.addMultipleSubviews(with: [logoImageView, titleLabel, subTitleLabel, aboutText,
                                        versionInfoLabel, bottomView/*,
                                        telegramImageView, telegramStaticLabel, telegramTapArea,
                                        exantechImageView, exantechStaticLabel, exantechTapArea*/])

        bottomView.addMultipleSubviews(with: [telegramImageView, telegramStaticLabel, telegramTapArea,
                exantechImageView, exantechStaticLabel, exantechTapArea])

        applyStyles()
        applyLayout()

        telegramTapArea.addTapTouch(self, action: #selector(onTelegramLink))
        exantechTapArea.addTapTouch(self, action: #selector(onExantechLink))
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.detailsScreenBackgroundColor
        versionInfoLabel.textAlignment = .center

        let content = l10n(.aboutText)
        let attrContent = NSMutableAttributedString(string: content)
        for header in [l10n(.aboutFirstHeader), l10n(.aboutSecondHeader), l10n(.aboutThirdHeader)] {
            if let range = content.range(of: header) {
                let nRange = NSRange(range, in: content)
                attrContent.setAttributes([.font: UIFont.boldSystemFont(ofSize: 15.0), .underlineStyle: NSUnderlineStyle.single.rawValue], range: nRange)
            }
        }

        for subHeader in [l10n(.aboutFirstSubHeader), l10n(.aboutSecondSubHeader), l10n(.aboutTextThirdSubHeader)] {
            if let range = content.range(of: subHeader) {
                let nRange = NSRange(range, in: content)
                attrContent.setAttributes([.font: UIFont.boldSystemFont(ofSize: 13.0)], range: nRange)
            }
        }

        aboutText.attributedText = attrContent
    }

    func applyLayout() {
        let topOffset: CGFloat = 30
        let sideOffset: CGFloat = 20

        if let theImage = logoImageView.image {
            logoImageView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(topOffset)
                make.centerX.equalToSuperview()
                make.width.equalTo(theImage.size.width)
                make.height.equalTo(theImage.size.height)
            }
        }

        versionInfoLabel.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(8)
            make.height.equalTo(16)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).offset(topOffset)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(sideOffset)
            make.height.equalTo(20)
        }

        subTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(sideOffset)
            make.height.equalTo(50)
        }

        let pieces: CGFloat = DeviceType.isWideScreen ? 4.0 : 3.0
        aboutText.snp.makeConstraints { (make) in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(topOffset)
            make.width.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom).offset(-pieces * sideOffset)
        }

        bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(aboutText.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom)
        }

        telegramImageView.snp.makeConstraints { (make) in
            make.width.equalTo(telegramImageSize.width)
            make.height.equalTo(telegramImageSize.height)
            make.centerY.equalToSuperview()
            make.left.equalTo(12)
        }

        exantechImageView.snp.makeConstraints { (make) in
            make.width.equalTo(exantechImageSize.width)
            make.height.equalTo(exantechImageSize.height)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }

        exantechStaticLabel.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.right.equalTo(exantechImageView.snp.left).offset(-6)
            make.top.equalTo(telegramStaticLabel.snp.top)
        }

        telegramStaticLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-telegramImageView.right - 15)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
            make.left.equalTo(telegramImageView.snp.right).offset(6)
        }

        telegramTapArea.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview()
            make.left.equalTo(telegramImageView.snp.left).offset(-4)
        }

        exantechTapArea.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview()
            make.left.equalTo(exantechStaticLabel.snp.left).offset(-4)
        }
    }

    @objc func onTelegramLink() {
        guard let url = URL(string: EXAAppInfoService.telegramChannelLink) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func onExantechLink() {
        guard let url = URL(string: EXAAppInfoService.exantechLink) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
