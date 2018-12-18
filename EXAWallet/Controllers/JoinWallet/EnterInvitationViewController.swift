//
// Created by Igor Efremov on 20/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit
import PKHUD

class EnterInvitationViewController: BaseViewController {
    private let titleLabel = UILabel("Paste, scan or enter\ninvite code here",
            textColor: UIColor.grayTitleColor, font: UIFont.systemFont(ofSize: 16.0))

    private let scanQRImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "scan_qr"))

    private let inviteTextView: UITextView = {
        let tv = UITextView()

        tv.backgroundColor = UIColor.clear
        tv.font = UIFont.systemFont(ofSize: 16.0)
        tv.textColor = UIColor.titleLabelColor

        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 10.0
        tv.layer.borderColor = UIColor.white.cgColor

        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        tv.keyboardAppearance = .dark

        return tv
    }()

    private let continueButton: EXAButton = EXAButton(with: l10n(.commonContinue))


    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = l10n(.joinWallet)

        [titleLabel, scanQRImageView, inviteTextView, continueButton].compactMap{$0}.forEach{view.addSubview($0)}
        scanQRImageView.addTapTouch(self, action: #selector(onTapScan))
        continueButton.addTarget(self, action: #selector(onTapContinue), for: .touchUpInside)

        self.view.addTapTouch(self, action: #selector(switchFirstResponder))

        applyStyles()
        applyLayout()
        applyDefaultValues()
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.screenBackgroundColor

        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        scanQRImageView.contentMode = .center
    }

    func applyLayout() {
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.width.equalToSuperview().offset(-80)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(40)
        }

        scanQRImageView.snp.makeConstraints { (make) in
            make.right.equalTo(inviteTextView.snp.right)
            make.width.height.equalTo(40)
            make.top.equalToSuperview().offset(10)
        }

        inviteTextView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(200)
            make.top.equalTo(scanQRImageView.snp.bottom).offset(10)
        }

        continueButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(EXAButton.defaultHeight)
            make.top.equalTo(inviteTextView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }

    private func applyDefaultValues() {
#if TEST
        if let theInviteCode = EXACommon.loadTestInfo(MoneroCommonConstants.inviteCodeTxt) {
            inviteTextView.text = theInviteCode
            validateAndProcessInviteCode()
        }
#endif
    }

    @objc func onTapContinue() {
        validateAndProcessInviteCode()
    }

    private func validateAndProcessInviteCode() {
        guard let inviteCode = InviteCode(value: inviteTextView.text) else {
            EXADialogs.showMessage("Invalid invite code", title: EXAAppInfoService.appTitle, buttonTitle: l10n(.commonOk))
            return
        }

        HUD.flash(.success, delay: 0.35) { [weak self] success in
            self?.processInviteCode(inviteCode)
        }
    }

    @objc func onTapScan() {
        scanQR()
    }

    private func scanQR() {
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

    private func processInviteCode(_ inviteCode: InviteCode) {
        EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(navigationController, step: .joinSharedWalletAfterInviteCode(inviteCode: inviteCode))
    }

    @objc func switchFirstResponder() {
        inviteTextView.resignFirstResponder()
        self.view.becomeFirstResponder()
    }
}

extension EnterInvitationViewController: AddressScannerActionDelegate {

    func onAddressRecognized(_ address: String) {
        inviteTextView.text = address
        validateAndProcessInviteCode()
    }
}
