//
// Created by Igor Efremov on 04/09/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SnapKit
import SDCAlertView
import SwiftyJSON

fileprivate struct SizeConstants {

    static let sideOffset: CGFloat = 20.0
}

fileprivate typealias sizes = SizeConstants

final class JoinSharedWalletViewController: UIViewController, MultisignatureWalletWorkflowNotification, ReceiveViewActionDelegate {
    private var checkWorkflowCoordinator: MultisignatureWalletWorkflow?
    private var joinWorkflowCoordinator: MultisignatureWalletWorkflow?
    private let titleLabel: EXALabel = {
        let lbl = EXALabel(l10n(.joinWallet))
        lbl.numberOfLines = 0
        lbl.style = .title
        return lbl
    }()

    private let noteLabel: EXALabel = {
        let lbl = EXALabel("Just waiting for join...")
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
        let btn = EXAButton(with: l10n(.commonJoin))
        btn.addTarget(self, action: #selector(onTapContinue), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()

    private var afterCreate: Bool = false

    convenience init(afterCreate: Bool) {
        self.init(nibName: nil, bundle: nil)
        self.afterCreate = afterCreate

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: EXAGraphicsResources.close,
                style: .plain,
                target: self,
                action: #selector(onCloseTap))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = l10n(.joinWallet)

        let allSubviews = [titleLabel, noteLabel, statusLabel, invitesStateLabel, continueButton]
        view.addMultipleSubviews(with: allSubviews)

        setupBackButton()
        applyStyles()
        applyLayout()

        //checkWorkflowCoordinator = MultisignatureWalletWorkflowCoordinator(.check)
        //checkWorkflowCoordinator?.notifier = self

        startWorkflowIfNeeded()

        // TODO: uncomment for check 'api/v1/info/multisig'
        //workflowCoordinator?.start()
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
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.screenBackgroundColor
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

    @objc func onTapContinue(_ sender: UIButton) {
        startWorkflowIfNeeded()
    }

    @objc func onCloseTap() {
        moveToDashboard()
    }

    private func startWorkflowIfNeeded() {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
        if meta.metaInfo.sharedReady {
            moveToDashboard()
        } else {
            joinWorkflowCoordinator = MultisignatureWalletWorkflowCoordinator(.join)
            joinWorkflowCoordinator?.notifier = self
            joinWorkflowCoordinator?.start()
        }
    }

    func onUpdate(_ text: String, _ invitePhase: Bool = false) {
        if text.length > 0 {
            statusLabel.text = text
        }
    }

    func onUpdate(stage: MultisigStage, result: [Any]?) {
        if stage == .check_join {
            guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
            guard let info = result as? [String] else { return }

            invitesStateLabel.text = "Participants joined \(info.count) of \(meta.metaInfo.participants)"
        }
    }

    func onFinish() {
        let storageService = EXAWalletMetaInfoStorageService()
        _ = storageService.load()
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }

        if meta.metaInfo.sharedReady {
            continueButton.setTitle(l10n(.commonOk), for: .normal)
        }
    }

    func onComplete() {
        doAfterComplete()
    }

    private func doAfterComplete() {
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


extension JoinSharedWalletViewController: MultisignatureWalletAPIResultCallback {
    func failure(error: String) {
        print(error)
        statusLabel.text = error
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
