//
// Created by Igor Efremov on 22/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

protocol ReceiveViewActionDelegate: class {
    func requestPayment(_ address: String?)
    func copyToClipboard(_ address: String?, prefixMessage: String?)
}

class ReceiveViewController: BaseViewController, ReceiveViewActionDelegate, MultisignatureWalletWorkflowNotification {
    private let receiveHeaderView = ReceiveAddressQRHeaderView()
    private let paymentIdView = PaymentIdInputView()

    private var txProposalService: EXAProposalsService?

    private let headerTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl.textAlignment = .center
        lbl.text = String(format: l10n(.receiveHeadTitle), CryptoTicker.XMR.description)
        return lbl
    }()

    private var publicAddress: String?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tabBarItem = EXATabBarItem(image: EXAGraphicsResources.receiveTab, tag: EXATabScreen.receive.rawValue)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let allSubviews = [receiveHeaderView, paymentIdView]
        view.addMultipleSubviews(with: allSubviews)

        receiveHeaderView.actionDelegate = self

        updateQRCode()
        applyStyles()
        applySizes()

        view.addTapTouch(self, action: #selector(switchFirstResponder))
        paymentIdView.actionDelegate = self
    }

    override func applyStyles() {
        super.applyStyles()

        navigationItem.title = l10n(.receiveTitle)
        view.backgroundColor = UIColor.detailsBackgroundColor

        receiveHeaderView.applyStyles()
        paymentIdView.applyStyles()
    }

    func applySizes() {
        receiveHeaderView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.centerX.equalToSuperview()
            make.height.equalTo(218)
        }

        paymentIdView.snp.makeConstraints { (make) in
            make.top.equalTo(receiveHeaderView.snp.bottom)
            make.left.width.equalToSuperview()
            make.height.equalTo(98)
        }

        receiveHeaderView.applyLayout()
        paymentIdView.applyLayout()
    }

    func requestPayment(_ address: String?) {
        _ = paymentIdView.resignFirstResponder()
        let service = SharingService()
        service.share(address)
    }

    func copyToClipboard(_ address: String?, prefixMessage: String? = nil) {
        _ = paymentIdView.resignFirstResponder()
        guard let address = address else { return }
        EXAAppUtils.copy(toClipboard: address, prefixMessage: prefixMessage)
    }

    @objc func switchFirstResponder() {
        _ = paymentIdView.resignFirstResponder()
        view.becomeFirstResponder()
    }

    func updateQRCode() {
        if let theWallet = AppState.sharedInstance.currentWallet {
            if let thePaymentId = paymentIdView.paymentID, thePaymentId.length > 0 {
                receiveHeaderView.publicAddress = theWallet.publicAddress()
                receiveHeaderView.qrCodeString = theWallet.publicAddress() + "?tx_payment_id=\(thePaymentId)"
            } else {
                receiveHeaderView.setupPublicAddressAndQR(theWallet.publicAddress())
            }
        }

    }

    func onUpdate(_ text: String, _ invitePhase: Bool) {

    }

    func onUpdate(stage: MultisigStage, result: [Any]?) {

    }

    func onFinish() {

    }

    func onComplete() {}

}

extension ReceiveViewController: PaymentIdInputViewActionDelegate {

    func onGeneratePaymentId() {
        let generator = EXAPaymentIdGenerator()
        paymentIdView.paymentID = generator.generatePaymentId()
        copyToClipboard(paymentIdView.paymentID, prefixMessage: "Payment ID")
        updateQRCode()
    }
}
