//
// Created by Igor Efremov on 13/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON

fileprivate struct SizeConstants {

    static let sideOffset: CGFloat = 20.0
}

fileprivate typealias sizes = SizeConstants

final class InviteParticipantsViewController: UIViewController, MultisignatureWalletWorkflowNotification, ReceiveViewActionDelegate {
    private var workflowCoordinator: MultisignatureWalletWorkflow?
    private let titleLabel: EXALabel = {
        let lbl = EXALabel(l10n(.shareInvitation))
        lbl.numberOfLines = 0
        lbl.style = .title
        return lbl
    }()

    private let noteLabel: EXALabel = {
        let lbl = EXALabel(l10n(.shareNote))
        lbl.style = .note
        lbl.numberOfLines = 0
        return lbl
    }()

    private let statusLabel: EXALabel = {
        let lbl = EXALabel("")
        lbl.style = .title
        lbl.numberOfLines = 0
        return lbl
    }()

    private let invitesStateLabel: EXALabel = {
        let lbl = EXALabel("")
        lbl.style = .note
        lbl.numberOfLines = 0
        return lbl
    }()

    private let continueButton: EXAButton = {
        let btn = EXAButton(with: l10n(.commonOk))
        btn.addTarget(self, action: #selector(onTapContinue), for: .touchUpInside)
        return btn
    }()

    private var afterCreate: Bool = false

    private let inviteCodeView = ReceiveQRHeaderView()

    convenience init(afterCreate: Bool) {
        self.init(nibName: nil, bundle: nil)
        self.afterCreate = afterCreate

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: EXAGraphicsResources.close,
                style: .plain,
                target: self,
                action: #selector(onTapContinue))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = l10n(.invitesVcTitle)

        let allSubviews = [titleLabel, noteLabel, inviteCodeView, statusLabel, invitesStateLabel, continueButton]
        view.addMultipleSubviews(with: allSubviews)

        setupBackButton()
        applyStyles()
        applyLayout()

        inviteCodeView.actionDelegate = self
        inviteCodeView.isHidden = true

        workflowCoordinator = MultisignatureWalletWorkflowCoordinator(.create)
        workflowCoordinator?.notifier = self
        workflowCoordinator?.start()

        continueButton.isEnabled = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func applyLayout() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(sizes.sideOffset)
            make.left.width.equalToSuperview()
            make.height.equalTo(48)
        }

        noteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(sizes.sideOffset)
            make.left.equalToSuperview().offset(sizes.sideOffset)
            make.width.equalToSuperview().inset(sizes.sideOffset)
        }

        inviteCodeView.snp.makeConstraints { (make) in
            make.top.equalTo(noteLabel.snp.bottom).offset(sizes.sideOffset)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(218)
        }

        statusLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(continueButton.snp.top).offset(sizes.sideOffset)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(sizes.sideOffset)
            make.height.equalTo(40)
        }

        let bottomPadding: CGFloat = DeviceType.isiPhoneXOrBetter ? 34.0 : 0.0
        continueButton.snp.makeConstraints{ (make) in
            make.width.equalToSuperview().inset(sizes.sideOffset)
            make.height.equalTo(EXAButton.defaultHeight)
            make.bottom.equalTo(view.snp.bottom).offset(-sizes.sideOffset - bottomPadding)
            make.centerX.equalToSuperview()
        }

        invitesStateLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(continueButton.snp.top).offset(-sizes.sideOffset)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(22)
        }

        inviteCodeView.applyLayout()
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.screenBackgroundColor

        inviteCodeView.applyStyles(.dark)
    }

    @objc func onTapContinue(_ sender: UIButton) {
        moveToDashboard()
    }

    private func moveToDashboard() {
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        _ = wallet.close()

        if afterCreate {
            moveToDashboardAfterCreate()
        } else {
            returnToDashboard()
        }
    }

    private func moveToDashboardAfterCreate() {
        EXAAppNavigationDispatcher.sharedInstance.showWalletAfterCreate()
    }

    private func returnToDashboard() {
        navigationController?.popViewController(animated: true)
    }

    @objc func onTapCheckState(_ sender: UIButton) {
        //workflowCoordinator.start()
        //checkJoinedState()
        workflowCoordinator = MultisignatureWalletWorkflowCoordinator(.check)
        workflowCoordinator?.notifier = self
        workflowCoordinator?.start()
    }

    func onUpdate(_ text: String, _ invitePhase: Bool = false) {
        if invitePhase == true {
            inviteCodeView.setupPublicAddressAndQR(text)
            inviteCodeView.isHidden = false
            continueButton.isHidden = true
        } else {
            statusLabel.text = text
        }
    }

    func onUpdate(stage: MultisigStage, result: [Any]?) {
        if stage == .check_join {
            guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
            guard let info = result as? [String] else { return }

            invitesStateLabel.text = "Participants joined \(info.count) of \(meta.metaInfo.participants)"

            if info.count == meta.metaInfo.participants {
                statusLabel.text = "Ready to change public key"
            }
        }
    }

    func onFinish() {
        inviteCodeView.isHidden = false
    }

    func onComplete() {
        doAfterComplete()
    }

    private func doAfterComplete() {
        inviteCodeView.isHidden = true
        continueButton.isHidden = false
        continueButton.isEnabled = true
        statusLabel.text = l10n(.sharedWalletReady)
        delay(2.0, closure: { [weak self] in
            self?.moveToDashboard()
        })
    }

    func requestPayment(_ address: String?) {
        let service = SharingService()
        service.share(address)
    }

    func copyToClipboard(_ address: String?, prefixMessage: String? = nil) {
        guard let theChecksumAddress = address else { return }
        EXAAppUtils.copy(toClipboard: theChecksumAddress)
    }
}


extension InviteParticipantsViewController: MultisignatureWalletAPIResultCallback {
    func failure(error: String) {
        print(error)
    }

    func completed(result: String) {
        print(result)
        statusLabel.text = result
    }

    func completed(resultArray: [String]) {
        print(resultArray)

        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        
        // TODO: Check result
        _ = wallet.transformationIntoSharedWallet(participantsInfo: resultArray, signers: UInt(resultArray.count))
    }

    func completed(stage: MultisigStage) {

    }

    func completed(resultJSON: JSON) {}
}
