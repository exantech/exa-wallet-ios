//
// Created by Igor Efremov on 24/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

class SendViewController: BaseViewController, RecipientViewActionDelegate, AddressScannerActionDelegate {
    private let lineViewAddress = UIView(frame: CGRect.zero)
    private let sendBtn = EXAButton(with: l10n(.commonSend))
    private let lineViewAmount = UIView(frame: CGRect.zero)
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let outputsStatus: EXALabel = {
        let lb = EXALabel("Outputs are not synced. Please waiting participants")
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 12.0)
        lb.textColor = .localRed
        lb.numberOfLines = 0
        return lb
    }()

    private let recipientView = RecipientView()
    private let amountView = AmountInputView()
    private let proposalDescriptionView: EXAHeaderTextFieldView = {
        let tf = EXAHeaderTextFieldView("Enter some text", header: "Proposal description",
                textColor: UIColor.invertedTitleLabelColor, placeHolderColor: UIColor.placeholderLightColor)
        tf.textField.tintColor = UIColor.invertedTitleLabelColor
        tf.textField.returnKeyType = .next
        return tf
    }()

    private let paymentIdView = PaymentIdInputView()

    private var sendingTransactionDetails: MoneroSendingTransactionDetails?

    private let sendingService = MoneroTransactionsService()

    private var loadingView: EXACircleStrokeLoadingIndicator = EXACircleStrokeLoadingIndicator()

    private var txProposalService: EXAProposalsService?

    private var walletType: WalletType = .personal

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tabBarItem = EXATabBarItem(image: EXAGraphicsResources.sendTab, tag: EXATabScreen.send.rawValue)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let meta = AppState.sharedInstance.currentWalletMetaInfo else {
            return
        }

        walletType = meta.type

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let allSubviews = [recipientView, amountView, proposalDescriptionView, paymentIdView, sendBtn, outputsStatus, loadingView]
        contentView.addMultipleSubviews(with: allSubviews)

        loadingView.fullScreenMode = true
        loadingView.isHidden = true
        loadingView.frame = self.view.frame

        recipientView.actionDelegate = self

#if TEST
        if let theSendInfo = EXACommon.loadTestInfo(MoneroCommonConstants.receiveAddressTxt) {
            parseSendInfoAndFill(theSendInfo)
        }
#endif

        applyStyles()
        view.addTapTouch(self, action: #selector(switchFirstResponder))
        paymentIdView.actionDelegate = self

        checkStatus()

        recipientView.updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: ScreenSize.screenWidth, height: ScreenSize.screenHeight + 20.0)
        updateConstraints()
    }

    private func updateConstraints() {
        applySizes()
    }

    override func applyStyles() {
        super.applyStyles()

        navigationItem.title = l10n(.sendTitle)
        view.backgroundColor = UIColor.detailsBackgroundColor

        if walletType == .personal {
            proposalDescriptionView.isHidden = true
            sendBtn.setTitle(l10n(.commonSend), for: .normal)
        } else {
            sendBtn.setTitle(l10n(.proposalCreate), for: .normal)
        }

        recipientView.applyStyles()
        amountView.applyStyles()
        proposalDescriptionView.applyStyles()
        paymentIdView.applyStyles()

        sendBtn.addTarget(self, action: #selector(onTapSend), for: .touchUpInside)
    }

    func applySizes() {
        let leftOffset: CGFloat = 20
        let topOffset: CGFloat = 20

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view).inset(UIEdgeInsets.zero)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView).inset(UIEdgeInsets.zero)
            make.width.equalTo(scrollView)
            make.height.equalTo(scrollView.contentSize.height)
        }

        recipientView.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.height.equalTo(97)
            make.top.equalTo(topOffset)
        }

        amountView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(90)
            make.top.equalTo(recipientView.snp.bottom).offset(20)
        }

        if walletType == .shared {
            proposalDescriptionView.snp.makeConstraints { (make) in
                make.width.equalToSuperview().inset(20)
                make.centerX.equalToSuperview()
                make.height.equalTo(80)
                make.top.equalTo(amountView.snp.bottom).offset(20)
            }
            paymentIdView.snp.makeConstraints { (make) in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(97)
                make.top.equalTo(proposalDescriptionView.snp.bottom).offset(20)
            }

            proposalDescriptionView.applyLayout()
        } else {
            paymentIdView.snp.makeConstraints { (make) in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(97)
                make.top.equalTo(amountView.snp.bottom).offset(20)
            }
        }

        recipientView.applyLayout()
        amountView.applyLayout()
        paymentIdView.applyLayout()

        sendBtn.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-2 * leftOffset)
            make.height.equalTo(EXAButton.defaultHeight)
            make.centerX.equalToSuperview()
            make.top.equalTo(paymentIdView.snp.bottom).offset(20)
        }

        outputsStatus.snp.makeConstraints { (make) in
            make.width.equalToSuperview().inset(leftOffset)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.top.equalTo(sendBtn.snp.bottom).offset(10)
        }
    }

    private func checkStatus() {
        guard let meta = AppState.sharedInstance.currentWalletMetaInfo else {
            return
        }
        guard let wallet = AppState.sharedInstance.currentWallet else {
            return
        }

        let isReady = !wallet.isMultisigOutputsReady()
        outputsStatus.isHidden = isReady
        sendBtn.isEnabled = (isReady || meta.type == .personal)
    }

    @objc func switchFirstResponder() {
        for v in [recipientView, amountView, proposalDescriptionView, paymentIdView] as [UIView] {
            _ = v.resignFirstResponder()
        }
        _ = view.becomeFirstResponder()
    }

    @objc func onTapPrepare() {

    }

    private func validateAmount() -> Bool {
        let amountValueString = amountView.amountValue
        guard let amount = amountValueString.toDouble() else {
            amountView.incorrect = true
            return false
        }

        if amount < 0 {
            amountView.incorrect = true
            return false
        }

        return true
    }

    private func validateAddress(_ value: String) -> Bool {
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            return false
        }

        return theWallet.isAddressValid(value)
    }

    private func validatePaymentId(_ value: String?) -> Bool {
        guard let thePaymentId = value else {
            return true // nil payment id is true
        }
        return thePaymentId != "0000000000000000"
    }

    private func stopLoader() {
        loadingView.stopAnimating()
    }

    private func validateAll() -> Bool {
        guard validateAmount() else {
            return false
        }

        guard validateAddress(recipientView.addressValue) else {
            recipientView.incorrect = true
            return false
        }

        guard validatePaymentId(paymentIdView.paymentID) else {
            paymentIdView.incorrect = true
            return false
        }

        return true
    }

    private func validateAndSend() {
        if !validateAll() {
            sendBtn.isEnabled = true
            stopLoader()
        } else {
            guard let meta = AppState.sharedInstance.currentWalletMetaInfo else {
                return
            }

            guard let wallet = AppState.sharedInstance.currentWallet else {
                return
            }

            if .shared == meta.type {
                if fillTransactionDetails() {
                    txProposalService = EXAProposalsService(transactionService: sendingService)

                    sendingService.prepare()
                    let proposalDescription = proposalDescriptionView.text
                    if let theSendingDetails = self.sendingTransactionDetails {
                        if let txps = self.txProposalService?.createTransactionProposal(theSendingDetails) {
                            debugPrint(txps)

                            let amount = wallet.amount(from: theSendingDetails.amount)
                            let params = TxProposalParam(theSendingDetails.to!.addressString, proposalDescription, txps, amount!, 0)

                            self.txProposalService?.setupTransactionProposalPayload(params)
                            self.txProposalService?.sendTransactionProposal()
                        }

                        self.sendBtn.isEnabled = true
                        self.loadingView.stopAnimating()
                    }
                }
            } else {
                if fillTransactionDetails() {
                    sendingService.prepare()
                    if let theSendingDetails = self.sendingTransactionDetails {
                        delay(2.5, closure: {
                            let result = self.sendingService.sendTransaction(CryptoCurrency.XMR, details: theSendingDetails)
                            if result.0 {
                                EXADialogs.showMessage("Transaction successfully sent", title: EXAAppInfoService.appTitle, buttonTitle: l10n(.commonOk))
                            } else {
                                EXADialogs.showError(EXAError.TransactionSendFailed(message: result.1))
                            }

                            self.sendBtn.isEnabled = true
                            self.loadingView.stopAnimating()
                        })
                    }
                }
            }
        }
    }

    @objc func onTapSend() {
        sendBtn.isEnabled = false
        loadingView.startAnimating()

        delay(0.3, closure: {
            self.validateAndSend()
        })
    }

    private func fillTransactionDetails() -> Bool {
        let amountValueString = amountView.amountValue
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            return false
        }

        let to = MoneroAddress(recipientView.addressValue)
        let from = MoneroAddress(theWallet.publicAddress())
        let paymentId = paymentIdView.paymentID
        
        guard to.isValid && from.isValid else {
            return false
        }

        if let result = amountValueString.toDouble() {
            sendingTransactionDetails = MoneroSendingTransactionDetails(amount: result, to: to, from: from)
            sendingTransactionDetails?.paymentId = paymentId

            return true
        }

        return false
    }

    func scanQR() {
        showCamera()
    }

    private func showCamera() {
        let vc = AddressScannerViewController()
        vc.actionDelegate = self
        let nvc = UINavigationController(rootViewController: vc)
        weak var wvc = vc
        self.present(nvc, animated: true, completion: {
            wvc?.startScanningQR()
        })
    }

    func onAddressRecognized(_ address: String) {
        parseSendInfoAndFill(address)
        
        // TODO: Check result
        _ = validateAddress(recipientView.addressValue)
    }
}

// Auxiliary methods
// TODO Moving to separate class

extension SendViewController {

    private func parseSendInfoAndFill(_ value: String) {
        let parts = value.components(separatedBy: "?")
        if parts.count > 1 {
            recipientView.addressValue = parts[0]
            let paymentIdParts = parts[1].components(separatedBy: "=")
            if paymentIdParts.count > 1 {
                paymentIdView.paymentID = paymentIdParts[1]
            } else {
                paymentIdView.paymentID = parts[1]
            }
        } else {
            recipientView.addressValue = value
        }
    }
}

extension SendViewController: PaymentIdInputViewActionDelegate {

    func onGeneratePaymentId() {
        let generator = EXAPaymentIdGenerator()
        paymentIdView.paymentID = generator.generatePaymentId()
        EXAAppUtils.copy(toClipboard: paymentIdView.paymentID, prefixMessage: "Payment ID")
    }
}
