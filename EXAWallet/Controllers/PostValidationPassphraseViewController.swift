//
// Created by Igor Efremov on 05/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit
import SDCAlertView

fileprivate struct SizeConstants {

    static let sideOffset  = 20.0
}

fileprivate typealias sizes = SizeConstants

final class PostValidationPassphraseViewController: UIViewController {
    private let successValidation: UIImageView = UIImageView(image: EXAGraphicsResources.validationSuccess)
    //private var workflowCoordinator: MultisignatureWalletWorkflow?
    //private var joinWorkflowCoordinator: MultisignatureWalletWorkflow?

    private let titleLabel: EXALabel = {
        let lbl = EXALabel("Wallet passphrase\nhas been validated")
        lbl.numberOfLines = 0
        lbl.style = .title
        return lbl
    }()

    private let noteLabel: EXALabel = {
        let lbl = EXALabel(l10n(.commonSafeNote))
        lbl.style = .note
        lbl.numberOfLines = 0
        return lbl
    }()

    private let continueButton: EXAButton = {
        let btn = EXAButton(with: l10n(.commonOk))
        btn.addTarget(self, action: #selector(onTapContinue), for: .touchUpInside)
        return btn
    }()

    private let joinButton: EXAButton = {
        let btn = EXAButton(with: l10n(.commonJoin))
        btn.addTarget(self, action: #selector(onTapJoin), for: .touchUpInside)
        return btn
    }()

    private let currentStepLabel: EXALabel = {
        let lbl = EXALabel("")
        lbl.numberOfLines = 0
        lbl.style = .title
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = l10n(.createVcTitle)

        let allSubviews = [successValidation, titleLabel, noteLabel, currentStepLabel, joinButton, continueButton]
        view.addMultipleSubviews(with: allSubviews)

        setupBackButton()
        applyStyles()
        applySizes()

        if AppState.sharedInstance.tempCurrentOption == .joinShared {
            joinButton.isHidden = false
            continueButton.isHidden = true
        } else {
            joinButton.isHidden = true
        }

        /*if AppState.sharedInstance.tempCurrentOption == .createShared {
            workflowCoordinator = MultisignatureWalletWorkflowCoordinator(.create)
            workflowCoordinator?.notifier = self
            workflowCoordinator?.start()
        }*/
    }

    private func applySizes() {
        let bottomPadding = DeviceType.isiPhoneXOrBetter ? 34.0 : 0.0

        let imageSize = successValidation.image?.size ?? CGSize.zero
        successValidation.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(sizes.sideOffset)
            make.centerX.equalToSuperview()
            make.width.equalTo(imageSize.width)
            make.width.equalTo(imageSize.height)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(successValidation.snp.bottom).offset(sizes.sideOffset)
            make.left.width.equalToSuperview()
            make.height.equalTo(48)
        }

        noteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(sizes.sideOffset)
            make.left.equalToSuperview().offset(sizes.sideOffset)
            make.width.equalToSuperview().inset(sizes.sideOffset)
        }

        currentStepLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.width.equalToSuperview()
            make.height.equalTo(48)
        }

        continueButton.snp.makeConstraints{ (make) in
            make.width.equalToSuperview().inset(sizes.sideOffset)
            make.height.equalTo(EXAButton.defaultHeight)
            make.bottom.equalTo(view.snp.bottom).offset(-sizes.sideOffset - bottomPadding)
            make.centerX.equalToSuperview()
        }

        joinButton.snp.makeConstraints{ (make) in
            make.width.equalToSuperview().inset(sizes.sideOffset)
            make.height.equalTo(EXAButton.defaultHeight)
            make.bottom.equalTo(continueButton.snp.top).offset(-sizes.sideOffset)
            make.centerX.equalToSuperview()
        }
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.screenBackgroundColor
    }

    @objc func onTapContinue(_ sender: UIButton) {
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        _ = wallet.close()
        EXAAppNavigationDispatcher.sharedInstance.showWalletAfterCreate()
    }

    @objc func onTapJoin(_ sender: UIButton) {
        _ = AppState.sharedInstance.currentWallet?.close()
        AppState.sharedInstance.currentWallet = nil
        EXAAppNavigationDispatcher.sharedInstance.showWalletAfterCreate()
    }
}

extension PostValidationPassphraseViewController: MultisignatureWalletWorkflowNotification {

    func onUpdate(_ text: String, _ invitePhase: Bool = false) {
        currentStepLabel.text = text
        view.layoutSubviews()
    }

    func onUpdate(stage: MultisigStage, result: [Any]?) {}

    func onFinish() {
        print("Do nothing")
    }

    func onComplete() {}
}
