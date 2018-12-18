//
// Created by Igor Efremov on 08/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit
import BetterSegmentedControl
import SDCAlertView

private struct SizeConstants {
    static let sideOffset  = 20.0
    static let topOffset   = 20.0
}

private typealias sizes = SizeConstants

final class RestoreWalletViewController: UIViewController, UITextViewDelegate {
    private let validator = PassphrasePreValidator()

    var currentOption: EXAMoneroWalletCreateOption = .createPersonal

    private let blockHeightTextField: EXAHeaderTextFieldView = {
        let tf = EXAHeaderTextFieldView(l10n(.restoreEnterBlockHeight), header: l10n(.restoreBlockHeightOptional))
        tf.textField.autocorrectionType = .no
        tf.textField.returnKeyType = .next
        tf.textField.keyboardType = .numberPad
        return tf
    }()

    private let headerPhraseLabel = EXAHeaderStaticLabel(l10n(.commonPassphrase))
    private var phraseTextView = EXAPhraseTextView(restoreMode: true)
    private let remoteNodeTextField = RemoteNodeTextField()

    private let walletTypeSelectorControl = BetterSegmentedControl(
            frame: CGRect(x: 20, y: 0, width: 300, height: 36),
            segments: LabelSegment.segments(withTitles: [l10n(.personal), l10n(.shared)],
                    normalFont: UIFont.systemFont(ofSize: 16.0, weight: .medium),
                    normalTextColor: UIColor.mainColor,
                    selectedFont: UIFont.systemFont(ofSize: 16.0),
                    selectedTextColor: UIColor.white),
            index: 0, options: [.backgroundColor(.clear), .indicatorViewBackgroundColor(UIColor.mainColor)])

    private let continueButton: EXAButton = {
        let btn = EXAButton(with: l10n(.commonContinue))
        btn.addTarget(self, action: #selector(onTapContinue), for: .touchUpInside)
        return btn
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let storageService: EXAWalletMetaInfoStorageService = EXAWalletMetaInfoStorageService()

    convenience init(_ currentOption: EXAMoneroWalletCreateOption) {
        self.init(nibName: nil, bundle: nil)
        self.currentOption = currentOption
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: ScreenSize.screenWidth, height: ScreenSize.screenHeight + 20.0)
        updateConstraints()
    }

    private func updateConstraints() {
        applySizes()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = l10n(.restoreWallet)
        headerPhraseLabel.text = (currentOption == .createPersonal) ? l10n(.commonPassphrase) : l10n(.commonPassphraseEnter)

        phraseTextView.delegate = self

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let allSubviews = [blockHeightTextField, headerPhraseLabel, phraseTextView, remoteNodeTextField, continueButton, walletTypeSelectorControl]
        contentView.addMultipleSubviews(with: allSubviews)

        configPassphrase()
        setupBackButton()
        applyStyles()

        self.view.addTapTouch(self, action: #selector(switchFirstResponder))

        validateProcess()
    }

    func textViewDidChange(_ textView: UITextView) {
        validateProcess()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let theRestoreState = AppState.sharedInstance.restoreWalletState {
            phraseTextView.valid = (theRestoreState.status != .fail)
        }
    }

    private func validateProcess() {
        postValidate(validate())
    }

    private func validate() -> Bool {
        return validator.validate(preparedMnemonic())
    }

    private func postValidate(_ result: Bool) {
        continueButton.isEnabled = result
    }

    private func preparedMnemonic() -> String {
        return phraseTextView.text.replacingOccurrences(of: "\n", with: " ")
    }

    private func configPassphrase() {
        var result: String = ""
        if currentOption != .restore {
            result = AppState.sharedInstance.currentWallet?.mnemonic() ?? ""
        }
#if DEBUG
        if let restoreMnemonic = EXACommon.loadApiKey(MoneroCommonConstants.restoreMnemonicFile) {
            result = restoreMnemonic
        }
#endif
        phraseTextView.text = result
    }

    private func applySizes() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view).inset(UIEdgeInsets.zero)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView).inset(UIEdgeInsets.zero)
            make.width.equalTo(scrollView)
            make.height.equalTo(scrollView.contentSize.height)
        }

        blockHeightTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(sizes.topOffset)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(sizes.sideOffset)
            make.height.equalTo(blockHeightTextField.defaultHeight)
        }

        headerPhraseLabel.snp.makeConstraints { (make) in
            make.top.equalTo(blockHeightTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(sizes.sideOffset)
        }

        phraseTextView.snp.makeConstraints { (make) in
            make.top.equalTo(headerPhraseLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(sizes.sideOffset)
            make.height.equalTo(180)
        }

        walletTypeSelectorControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(phraseTextView.snp.bottom).offset(10)
            make.width.equalToSuperview().inset(sizes.sideOffset)
            make.height.equalTo(36)
        }

        remoteNodeTextField.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview().inset(sizes.sideOffset)
            make.height.equalTo(remoteNodeTextField.defaultHeight)
            make.top.equalTo(walletTypeSelectorControl.snp.bottom).offset(sizes.topOffset)
            make.centerX.equalToSuperview()
        }

        continueButton.snp.makeConstraints{ (make) in
            make.top.equalTo(remoteNodeTextField.snp.bottom).offset(sizes.topOffset)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(sizes.sideOffset)
            make.height.equalTo(EXAButton.defaultHeight)
        }

        blockHeightTextField.applyLayout()
        remoteNodeTextField.applyLayout()
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.screenBackgroundColor

        blockHeightTextField.applyStyles()
        walletTypeSelectorControl.applyStyles()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc func onTapContinue(_ sender: UIButton) {
        let blockHeight = UInt64(blockHeightTextField.text) ?? 0
        if blockHeight == 0 {
            showWarningDialog()
        } else {
            doRestore(blockHeight)
        }
    }

    @objc func switchFirstResponder() {
        _ = blockHeightTextField.resignFirstResponder()
        _ = phraseTextView.resignFirstResponder()
        self.view.becomeFirstResponder()
    }

    private func doRestore(_ blockHeight: UInt64 = 0) {
        AppState.sharedInstance.restoreWalletState = createRestoreState(blockHeight: blockHeight)
        EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(navigationController, step: .fillMetaInfo)
    }

    private func createRestoreState(blockHeight: UInt64) -> RestoreWalletState {
        let restoreState: RestoreWalletState = RestoreWalletState()
        restoreState.mnemonic = preparedMnemonic()
        restoreState.blockHeight = UInt64(blockHeightTextField.text) ?? 0
        restoreState.type = WalletType(rawValue: Int(walletTypeSelectorControl.index)) ?? WalletType.personal

        return restoreState
    }

    private func showWarningDialog() {
        let alert = AlertController(title: EXAAppInfoService.appTitle, message: l10n(.restoreWarning), preferredStyle: .alert)
        alert.visualStyle = EXAAlertVisualStyle(alertStyle: .alert)
        let OKAction = AlertAction(title: l10n(.commonMiss), style: .destructive, handler: { [weak self]
        (action) -> Void in
            if let wSelf = self {
                wSelf.doRestore()
            }
        })

        let cancelAction = AlertAction(title: l10n(.commonSetup), style: .preferred, handler: nil)
        alert.addAction(OKAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true)
    }
}

