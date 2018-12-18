//
// Created by Igor Efremov on 06/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

fileprivate struct SizeConstants {
    static let qrSize: CGFloat = 90.0
    static let iconSize: CGFloat = 70.0
    static let sideOffset: CGFloat = 20.0
}

fileprivate typealias sizes = SizeConstants

class ReceiveQRHeaderView: UIView {
    private let qrHolderView: ContainerCornerRoundView = ContainerCornerRoundView()
    private let recipientQRCodeImageView: UIImageView = UIImageView(image: nil)
    private let shareImageView: UIImageView = UIImageView(image: EXAGraphicsResources.share)
    private let copyImageView: UIImageView = UIImageView(image: EXAGraphicsResources.copy)
    private let recipientAddressValue: EXALabel = {
        let lbl = EXALabel()
        lbl.numberOfLines = 4
        lbl.font = UIFont.systemFont(ofSize: 11.0)
        lbl.textAlignment = .center
        return lbl
    }()

    weak var actionDelegate: ReceiveViewActionDelegate?

    var publicAddress: String? {
        didSet {
            recipientAddressValue.text = publicAddress
        }
    }

    var qrCodeString: String? {
        didSet {
            if let theQRCodeString = qrCodeString {
                var qrCode = QRCode(theQRCodeString)
                if qrCode != nil {
                    qrCode!.size = CGSize(width: sizes.qrSize, height: sizes.qrSize)
                    recipientQRCodeImageView.size = CGSize(width: sizes.qrSize, height: sizes.qrSize)
                    recipientQRCodeImageView.image =  qrCode!.image
                }
            }
        }
    }

    convenience init() {
        self.init(frame: CGRect.zero)

        addMultipleSubviews(with: [qrHolderView, shareImageView, copyImageView, recipientAddressValue])
        qrHolderView.addSubview(recipientQRCodeImageView)

        copyImageView.addTapTouch(self, action: #selector(onCopyToClipboardTap))
        qrHolderView.addTapTouch(self, action: #selector(onCopyToClipboardTap))
        recipientAddressValue.addTapTouch(self, action: #selector(onCopyToClipboardTap))
        shareImageView.addTapTouch(self, action: #selector(onTapShare))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func setupPublicAddressAndQR(_ value: String) {
        publicAddress = value
        qrCodeString = value
        afterCopyAction(qrCodeString)
    }

    func applyStyles(_ style: ComponentStyle = .light) {
        backgroundColor = style == .light ? UIColor.headerColor : UIColor.clear
        recipientAddressValue.textColor = style == .light ? UIColor.invertedTitleLabelColor : UIColor.titleLabelColor
    }

    func applyLayout() {
        qrHolderView.snp.makeConstraints { (make) in
            make.width.height.equalTo(120)
            make.top.equalToSuperview().offset(sizes.sideOffset)
            make.centerX.equalToSuperview()
        }

        recipientQRCodeImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(sizes.qrSize)
            make.center.equalToSuperview()
        }

        shareImageView.snp.makeConstraints{ (make) in
            make.width.height.equalTo(sizes.iconSize)
            make.top.left.equalToSuperview()
        }

        copyImageView.snp.makeConstraints{ (make) in
            make.width.height.equalTo(sizes.iconSize)
            make.top.right.equalToSuperview()
        }

        recipientAddressValue.snp.makeConstraints{ (make) in
            make.width.equalToSuperview().inset(sizes.sideOffset)
            make.centerX.equalToSuperview()
            make.top.equalTo(qrHolderView.snp.bottom).offset(sizes.sideOffset)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func onTapShare() {
        actionDelegate?.requestPayment(qrCodeString)
    }

    @objc func onCopyToClipboardTap() {
        actionDelegate?.copyToClipboard(qrCodeString, prefixMessage: nil)
        afterCopyAction(qrCodeString)
    }

    func afterCopyAction(_ value: String?) {
#if TEST
        EXACommon.saveTestInfo(value, storageFileName: MoneroCommonConstants.inviteCodeTxt)
#endif
    }
}
