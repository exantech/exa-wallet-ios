//
//  WalletMetaInfoWalletViewController.swift
//  EXAWallet
//
//  Created by Igor Efremov on 10/01/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit
import SDCAlertView

import PKHUD

final class WalletMetaInfoWalletViewController: BaseViewController, UITextFieldDelegate {
    var currentOption: EXAMoneroWalletCreateOption = .createPersonal
    private var mode: EXAWalletMetaMode = .create

    static let minPassSymbols = 8

    private let defaultKeyboardOffset: CGFloat = 120.0
    private var topViewOffset: CGFloat = 0.0
    private var isKeyboardPresent: Bool = false

    private let colorPicker: WalletColorPickerView = {
        let cpv = WalletColorPickerView()
        return cpv
    }()

    private let walletNameTextField: EXAHeaderTextFieldView = {
        let tf = EXAHeaderTextFieldView("Wallet name", header: "Enter wallet name")
        tf.textField.addTarget(self, action: #selector(tfDidChangeOnEditMode), for: .editingChanged)
        tf.textField.autocorrectionType = .no
        tf.textField.returnKeyType = .next
        return tf
    }()

    private let passTextField: EXAHeaderTextFieldView = {
        let minPassSymbolsString = "\(minPassSymbols)"
        let tf = EXAHeaderTextFieldView("Enter password", header: String(format: l10n(.setupPassEnterPass), minPassSymbolsString))
        tf.textField.addTarget(self, action: #selector(tfDidChange), for: .editingChanged)
        tf.textField.keyboardType = .asciiCapable
        tf.textField.returnKeyType = .next
        tf.isSecure = true
        return tf
    }()

    private let verifyPassTextField: EXAHeaderTextFieldView = {
        let tf = EXAHeaderTextFieldView("Enter password again", header: l10n(.setupPassVerifyPass))
        tf.textField.addTarget(self, action: #selector(verifyTfDidChange), for: .editingChanged)
        tf.textField.keyboardType = .asciiCapable
        tf.textField.returnKeyType = .continue
        tf.isSecure = true
        return tf
    }()

    private let remoteNodeTextField = RemoteNodeTextField()

    private let currentSchemeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        lbl.textColor = UIColor.grayTitleColor
        lbl.textAlignment = .center
        return lbl
    }()

    private let signersLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        lbl.textColor = UIColor.grayTitleColor
        lbl.textAlignment = .left
        lbl.text = "Signers"
        return lbl
    }()

    private let participantsLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        lbl.textColor = UIColor.grayTitleColor
        lbl.textAlignment = .right
        lbl.text = "Participants"
        return lbl
    }()

    private let signersStepper: GMStepper = GMStepper()
    private let participantsStepper: GMStepper = GMStepper()

    private let continueButton: EXAButton = EXAButton(with: l10n(.commonContinue))
    
    private var loadingView: EXACircleStrokeLoadingIndicator = EXACircleStrokeLoadingIndicator()
    
    private var passwordIndicator: PasswordStrengthIndicator = PasswordStrengthIndicator()
    private let validator = Validator()
    
    //var existingAccount: Account?
    var isChangePassword: Bool = false
    
    private let walletManager: WalletManager = WalletManager()

    private let storageService: EXAWalletMetaInfoStorageService = EXAWalletMetaInfoStorageService()

    private var inviteCode: InviteCode?

    private var currentScheme = AppState.sharedInstance.defaultSharedScheme

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private var _schemeStage: EXAWalletSchemeStage?
    private let schemeService = EXAWalletSchemeService()

    convenience init(_ currentOption: EXAMoneroWalletCreateOption, inviteCode: InviteCode? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.currentOption = currentOption
        self.inviteCode = inviteCode

        AppState.sharedInstance.tempCurrentOption = currentOption
    }

    convenience init(mode: EXAWalletMetaMode) {
        self.init(nibName: nil, bundle: nil)
        self.currentOption = .createPersonal
        self.mode = .edit
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

        subscriptions(true)

        navigationItem.title = currentOption.screenTitle

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let allSubviews = [colorPicker, walletNameTextField, passwordIndicator, passTextField, verifyPassTextField,
                           /*remoteNodeTextField,*/ currentSchemeLabel, signersLabel, signersStepper, participantsLabel,
                           participantsStepper, continueButton, loadingView]
        contentView.addMultipleSubviews(with: allSubviews)
        
        loadingView.isHidden = true
        loadingView.frame = self.view.frame

        colorPicker.actionDelegate = self
        
        applyStyles()
        applyDefaultValues()

        // TODO: check this or/and move
        _ = storageService.load()

        walletNameTextField.textField.delegate = self
        passTextField.textField.delegate = self
        verifyPassTextField.textField.delegate = self
        
        self.view.addTapTouch(self, action: #selector(switchFirstResponder))
        continueButton.addTarget(self, action: #selector(onTapContinue), for: .touchUpInside)

        setupStepper(signersStepper)
        updateStepperValues(signersStepper, current: currentScheme.signers, max: currentScheme.participants)

        setupStepper(participantsStepper)
        updateStepperValues(participantsStepper, current: currentScheme.participants, min: currentScheme.minParticipants,  max: currentScheme.maxParticipants)

        signersStepper.addTarget(self, action: #selector(didValueChanged), for: .valueChanged)
        participantsStepper.addTarget(self, action: #selector(didValueChanged), for: .valueChanged)

        if currentOption == .joinShared {
            requestScheme(.by_invite_code, info: inviteCode?.value)
        }

        if currentOption == .restore {
            requestScheme(.by_public_key)
        }
    }

    private func requestScheme(_ schemeMethod: WalletSchemeMethod, info: String? = nil) {
        guard let info = info else { return }

        _schemeStage = EXAWalletSchemeStage(callback: WalletSchemeAPIResultCallbackImpl(completionDelegate: self))
        _schemeStage?.setupSchemeMethod(schemeMethod)
        _schemeStage?.setupInfo(info)
        _schemeStage?.execute()
    }

    private func setupStepper(_ s: GMStepper) {
        s.buttonsTextColor = UIColor.mainColor
        s.buttonsInactiveTextColor = UIColor.inactiveColor
        s.borderColor = UIColor.rgb(0x4b4b4b)
        s.borderWidth = 0.5
        s.labelBackgroundColor = UIColor.clear
        s.buttonsBackgroundColor = UIColor.clear
        s.stepValue = 1
        s.labelWidthWeight = 0.34
        s.labelFont = UIFont.systemFont(ofSize: 16.0)
        s.limitHitAnimationColor = UIColor.grayTitleColor
    }

    private func updateStepperValues(_ s: GMStepper, current: UInt? = nil, min: UInt = 2, max: UInt = 7) {
        s.minimumValue = Double(min)
        s.maximumValue = Double(max)
        if let theCurrent = current {
            s.value = Double(theCurrent)
        }
    }

    private func updateScheme(_ signers: UInt, participants: UInt) {
        currentSchemeLabel.text = "Scheme: (\(signers) of \(participants))"
        currentScheme = SharedWalletScheme(signers, participants)
    }

    @objc private func didValueChanged(_ sender: GMStepper) {
        let s = UInt(signersStepper.value)
        let p = UInt(participantsStepper.value)

        var currentValue: UInt? = nil
        var maxValue: UInt = p

        if s == p || s > p {
            currentValue = p
            maxValue = p
        }

        if p > s && (p - s) > 1 {
            currentValue = s
            maxValue = p
        }

        updateStepperValues(signersStepper, current: currentValue, max: maxValue)
        updateStepperValues(participantsStepper, current: p, max: currentScheme.maxParticipants)
        updateScheme(UInt(signersStepper.value), participants: UInt(participantsStepper.value))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topViewOffset = self.view.top
        subscriptions(true)
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

        colorPicker.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(60)
            make.top.equalTo(topOffset)
            make.centerX.equalToSuperview()
        }

        walletNameTextField.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview().offset(-2 * leftOffset)
            make.height.equalTo(walletNameTextField.defaultHeight)
            make.top.equalTo(colorPicker.snp.bottom).offset(42)
            make.left.equalTo(leftOffset)
        }
        
        passTextField.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview().offset(-2 * leftOffset)
            make.height.equalTo(passTextField.defaultHeight)
            make.top.equalTo(walletNameTextField.snp.bottom).offset(32)
            make.left.equalTo(leftOffset)
        }
        
        passwordIndicator.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview().offset(-2 * leftOffset)
            make.height.equalTo(passwordIndicator.indicatorHeight)
            make.top.equalTo(passTextField.snp.bottom).offset(4)
            make.left.equalTo(leftOffset)
        }
        
        verifyPassTextField.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview().offset(-2 * leftOffset)
            make.height.equalTo(verifyPassTextField.defaultHeight)
            make.top.equalTo(passTextField.snp.bottom).offset(32)
            make.left.equalTo(leftOffset)
        }

        let schemeOffset = DeviceType.isWideScreen ? 32 : 0
        currentSchemeLabel.snp.makeConstraints{ (make) -> Void in
            make.width.left.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(verifyPassTextField.snp.bottom).offset(schemeOffset)
        }

        signersLabel.snp.makeConstraints{ (make) -> Void in
            make.width.equalTo(120)
            make.height.equalTo(20)
            make.top.equalTo(currentSchemeLabel.snp.bottom).offset(10)
            make.left.equalTo(leftOffset)
        }

        signersStepper.snp.makeConstraints{ (make) -> Void in
            make.width.equalTo(90)
            make.height.equalTo(30)
            make.top.equalTo(signersLabel.snp.bottom).offset(4)
            make.left.equalTo(leftOffset)
        }

        participantsLabel.snp.makeConstraints{ (make) -> Void in
            make.width.equalTo(120)
            make.height.equalTo(20)
            make.top.equalTo(currentSchemeLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-20)
        }

        participantsStepper.snp.makeConstraints{ (make) -> Void in
            make.width.equalTo(90)
            make.height.equalTo(30)
            make.top.equalTo(signersLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-20)
        }

        /*remoteNodeTextField.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview().offset(-2 * leftOffset)
            make.height.equalTo(remoteNodeTextField.defaultHeight)
            make.top.equalTo(verifyPassTextField.snp.bottom).offset(32)
            make.left.equalTo(leftOffset)
        }*/

        colorPicker.applyLayout()
        walletNameTextField.applyLayout()
        passTextField.applyLayout()
        verifyPassTextField.applyLayout()
        //remoteNodeTextField.applyLayout()

        continueButton.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview().offset(-2 * leftOffset)
            make.height.equalTo(EXAButton.defaultHeight)
            make.top.equalTo(participantsStepper.snp.bottom).offset(20)
            make.left.equalTo(leftOffset)
        }
    }

    override func applyStyles() {
        super.applyStyles()
        self.view.backgroundColor = UIColor.screenBackgroundColor

        colorPicker.walletType = (currentOption == .createPersonal || currentOption == .restore) ? .personal : .shared

        scrollView.showsVerticalScrollIndicator = false

        walletNameTextField.applyStyles()
        passTextField.applyStyles()
        verifyPassTextField.applyStyles()
        //remoteNodeTextField.applyStyles()

        if .edit == mode {
            passTextField.isHidden = true
            verifyPassTextField.isHidden = true
        }
    }

    private func setupPersonalBlock() {
        for v in [signersLabel, signersStepper, participantsLabel, participantsStepper] {
            v.isHidden = true
        }
    }

    private func setupSharedBlock() {
        let scheme = AppState.sharedInstance.defaultSharedScheme
        updateScheme(scheme.signers, participants: scheme.participants)

        for v in [signersLabel, signersStepper, participantsLabel, participantsStepper] {
            v.isHidden = false
        }
    }

    private func applyDefaultValues() {
        /*if let theInviteCode = inviteCode {
            walletNameTextField.textField.text = theInviteCode.sharedWalletName
            //walletNameTextField.textField.isEnabled = false
        }*/

        if currentOption == .createPersonal || currentOption == .restore {
            setupPersonalBlock()
        }

        if currentOption == .createShared {
            setupSharedBlock()
        }

        if currentOption == .joinShared {
            //if let inviteScheme = inviteCode?.scheme {
                setupPersonalBlock()
                // TODO
                //updateScheme(inviteScheme.signatures, participants: inviteScheme.participants)
            //}
        }

        if .edit == mode {
            guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
            walletNameTextField.textField.text = meta.metaInfo.name
            colorPicker.setupColor(meta.metaInfo.color)
            continueButton.setTitle(l10n(.commonApply), for: .normal)
        }

        continueButton.isEnabled = false

        if currentOption == .createShared {
            walletNameTextField.textField.text = WalletNamesGenerator.generatedName()
        }
#if TEST
        validateProcess()
#endif
    }
    
    @objc func tfDidChange() {
        self.validateProcess()
    }
    
    @objc func verifyTfDidChange() {
        verifyPassTextField.textField.textColor = UIColor.titleLabelColor
        self.validateProcess()
    }

    @objc func tfDidChangeOnEditMode() {
        if .create == mode {
            if walletNameTextField.text.isEmpty {
                continueButton.isEnabled = false
            } else {
                self.validateProcess()
            }
        }

        validateProcessOnlyInEditMode()
    }

    private func validateProcessOnlyInEditMode() {
        if .edit == mode {
            self.validateProcess()
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        /*if !DeviceType.isiPhone6OrMore {
            var newTopOffset: CGFloat = topViewOffset
            if passTextField.isFirstResponder {
                newTopOffset -= 30
            }

            if verifyPassTextField.isFirstResponder {
                newTopOffset -= 104
            }

            UIView.animate(withDuration: 0.2, animations: {
                self.view.top = newTopOffset
            })
        }*/
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == walletNameTextField.textField {
            textField.resignFirstResponder()
            passTextField.textField.becomeFirstResponder()
        }

        if textField == passTextField.textField {
            textField.resignFirstResponder()
            verifyPassTextField.textField.becomeFirstResponder()
        }

        if textField == verifyPassTextField.textField {
            onTapContinue()
        }

        return true
    }

    private func validateProcess() {
#if TEST
        continueButton.isEnabled = !walletNameTextField.text.isEmpty
        return
#else
        if .edit == mode {
            continueButton.isEnabled = true
            return
        }
        
        let result = validate()
        postValidate(result)
#endif
    }
    
    private func validate() -> Validator.Result {
        // Bad but clients want it
        if isEmptyPass() {
            return .ok
        }

        let password = passTextField.text
        let strength = Strength(password: password)

        switch strength {
        case .empty:
            passwordIndicator.strength = .empty
        case .weak, .veryWeak:
            passwordIndicator.strength = .weak
        case .reasonable:
            passwordIndicator.strength = .med
        case .strong, .veryStrong:
            passwordIndicator.strength = .strong
        }

        return validator.validate(password)
    }

    private func postValidate(_ result: Validator.Result) {
        switch result {
        case .ok:
            continueButton.isEnabled = verifyPassTextField.text.length >= WalletMetaInfoWalletViewController.minPassSymbols || isEmptyPass()
        default:
            continueButton.isEnabled = false
        }
    }

    private func createSharedWallet(_ meta: WalletMetaInfo?, password: String) -> MoneroWallet? {
        guard let theMeta = meta else { return nil }
        theMeta.skippedPass = isEmptyPass()
        
        let currentNode = AppState.sharedInstance.settings.environment.nodes.defaultNode
        let walletInfo = WalletCreationInfo(meta: theMeta, password: password, remoteNodeAddress: currentNode)

        let result = WalletManager.shared.createWallet(walletInfo)
        if result.0 {
            // Need to save personal seed in keychain only for shared wallet,
            // because after transform to multisig wallet seed will be empty
            let ss = SharedWalletSeed()
            ss.safeSave(value: result.2?.mnemonic() ?? "", walletId: walletInfo.meta.uuid)
            AppState.sharedInstance.currentWalletMetaInfo = walletInfo.meta
            return result.2
        } else {
            print(result.1)
            return nil
        }
    }
    
    @objc func onTapContinue() {
        if walletNameTextField.text.isEmpty {
            walletNameTextField.textField.textColor = UIColor.localRed

            switchFirstResponder()
            return
        }

        if .edit == mode {
            // TODO: fix edit with exist wallet name
            guard let meta = AppState.sharedInstance.currentWalletInfo else { return }
            if let theNewMeta = storageService.changeMeta(by: meta.metaInfo.uuid, name: walletNameTextField.text, color: colorPicker.selectedColor) {
                AppState.sharedInstance.currentWalletInfo = WalletInfo(theNewMeta, balance: AppState.sharedInstance.currentWalletInfo?.balance ?? "0.00")

                // TODO: temporary
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name.WalletNameChanged), object:
                walletNameTextField.text)
            }

            navigationController?.popViewController(animated: true)

            return
        }

        // TODO: check this case if join shared wallet but wallet with same already exist!
        if storageService.isAlreadyExist(walletNameTextField.text) {
            walletNameTextField.textField.textColor = UIColor.localRed
            switchFirstResponder()

            EXADialogs.showMessage("Wallet with same name already exists.\nPlease type another name",
                    title: EXAAppInfoService.appTitle, buttonTitle: l10n(.commonOk))

            return
        }

        if isEmptyPass() {
            showWarningDialog()
            return
        }

        if passTextField.text != verifyPassTextField.text {
            verifyPassTextField.textField.textColor = UIColor.localRed
            switchFirstResponder()
            return
        }
        
        let thePassword = passTextField.text
        createOrRestoreWallet(thePassword)
    }

    private func createOrRestoreWallet(_ pass: String) {
        defer {
            HUD.hide(animated: true)
        }

        HUD.show(.progress)

        if currentOption == .createShared {
            doActionCreateSharedOptionSelected()
            return
        }

        if currentOption == .joinShared {
            doActionJoinSharedOptionSelected()
            return
        }
        
        var startingBlockHeight: UInt64 = 0
        if let rs = AppState.sharedInstance.restoreWalletState {
            startingBlockHeight = rs.blockHeight ?? 0
            doRestoreSharedOptionSelected(walletNameTextField.text, type: rs.type,
                    color: colorPicker.selectedColor, blockHeight: startingBlockHeight)

        } else {
            startingBlockHeight = AppState.sharedInstance.settings.environment.minStartingBlock

            let walletMetaInfo = WalletMetaInfo(walletNameTextField.text, color: colorPicker.selectedColor, blockHeight: startingBlockHeight)
            walletMetaInfo.skippedPass = isEmptyPass()

            let walletInfo = WalletCreationInfo(meta: walletMetaInfo, password: passTextField.text, remoteNodeAddress: remoteNodeTextField.text)

            let result = WalletManager.shared.createWallet(walletInfo)
            if result.0 {
                AppState.sharedInstance.currentWallet = result.2
                AppState.sharedInstance.currentWalletInfo = WalletInfo(walletMetaInfo, balance: "0.00")
                HUD.flash(.success, delay: 0.35) { [weak self] success in
                    EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(self?.navigationController, step: .showPassphrase)
                }
            } else {
                EXADialogs.showError(EXAError.WalletCreatingError(message: result.1))
            }
        }

    }

    @objc func onTapDelete() {
        if WalletManager.delete() {
            EXADialogs.showMessage(.WalletsSuccessfullyDeleted)
        }
    }

    private func isEmptyPass() -> Bool {
        return (passTextField.text == "" && verifyPassTextField.text == "")
    }

    private func doActionCreateSharedOptionSelected() {
        guard let sharedMetaInfo = WalletMetaInfo(walletNameTextField.text, type: .shared, color: colorPicker.selectedColor,
                blockHeight: AppState.sharedInstance.settings.environment.minStartingBlock, scheme: currentScheme) else {
            print("sharedMetaInfo is nil")
            return
        }

        let thePassword = passTextField.text
        sharedMetaInfo.creator = true

        if AppState.sharedInstance.usingMock {
            mockCreatingCommonWallet()
        } else {
            if let wallet = createSharedWallet(sharedMetaInfo, password: thePassword) {
                AppState.sharedInstance.currentWallet = wallet
                AppState.sharedInstance.currentWalletInfo = WalletInfo(sharedMetaInfo,
                        balance: AppState.sharedInstance.currentWallet?.formattedBalance() ?? "0.00")

                let manager = MessageKeysManager()
                _ = manager.savePersonalWalletKeys(storage: MessageKeyPairStorage())

                switchFirstResponder()
                HUD.hide(animated: true, completion: { [weak self] success in
                    HUD.flash(.success, delay: 0.35) { [weak self] success in
                        EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(self?.navigationController, step: .showPassphrase)
                    }
                })
            }
        }
    }

    private func doActionJoinSharedOptionSelected() {
        guard let theInviteCode = inviteCode else {
            return
        }

        let thePassword = passTextField.text

        // TODO: Determine true blockHeight
        guard let sharedMetaInfo = WalletMetaInfo(walletNameTextField.text, type: .shared, color: colorPicker.selectedColor,
                blockHeight: AppState.sharedInstance.restoreWalletState?.blockHeight, scheme: currentScheme) else {
            // TODO show Error
            print("sharedMetaInfo is nil")
            return
        }

        // TODO: Using this info?
        let _ = WalletCreationInfo(meta: sharedMetaInfo, password: thePassword, remoteNodeAddress: remoteNodeTextField.text)

        let result = createSharedWallet(sharedMetaInfo, password: thePassword)
        if result != nil { // result.0
            AppState.sharedInstance.currentWallet = result //result.2
            AppState.sharedInstance.currentWalletInfo = WalletInfo(sharedMetaInfo,
                    balance: AppState.sharedInstance.currentWallet?.formattedBalance() ?? "0.00")
            AppState.sharedInstance.setupInviteCode(theInviteCode, for: sharedMetaInfo.uuid)

            let manager = MessageKeysManager()
            _ = manager.savePersonalWalletKeys(storage: MessageKeyPairStorage())

            HUD.hide(animated: true, completion: { [weak self] success in
                HUD.flash(.success, delay: 0.35) { [weak self] success in
                    EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(self?.navigationController, step: .showPassphrase)
                }
            })
        } else {
            EXADialogs.showError(EXAError.CommonError(message: "Error create shared wallet"))
        }
    }

    private func doRestoreSharedOptionSelected(_ walletName: String, type: WalletType, color: WalletColor, blockHeight: UInt64) {
        // TODO: loader animating
        let walletMetaInfo = WalletMetaInfo(walletName, type: type, color: color, blockHeight: blockHeight)
        walletMetaInfo?.skippedPass = isEmptyPass()
        guard let wmi = walletMetaInfo else { return }

        let walletInfo = WalletCreationInfo(meta: wmi, password: passTextField.text,
                remoteNodeAddress: remoteNodeTextField.text,
                mnemonic: AppState.sharedInstance.restoreWalletState?.mnemonic)

        let result = WalletManager.shared.restore(walletInfo)
        if result.0 {
            AppState.sharedInstance.currentWallet = result.2
            if type == .shared {
                print("Need Implementation")
                checkExistsSharedWallet(onSuccess: { [weak self] scheme in
                    self?.updateScheme(scheme.signers, participants: scheme.participants)
                    wmi.signatures = scheme.signers
                    wmi.participants = scheme.participants
                    self?.storageService.addNew(wmi)
                    self?.storageService.save()

                    AppState.sharedInstance.currentWalletInfo = WalletInfo(wmi,
                            balance: AppState.sharedInstance.currentWallet?.formattedBalance() ?? "0.00")

                    EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(self?.navigationController, step: .participantScreenAfterCreate)
                })
            } else {
                EXADialogs.showMessage(EXADialogMessage.WalletSuccessfullyRestored, completionAction: {
                    _ = AppState.sharedInstance.currentWallet?.close()
                    EXAAppNavigationDispatcher.sharedInstance.showWalletAfterCreate()
                })
            }
        } else {
            AppState.sharedInstance.restoreWalletState?.status = .fail
            EXADialogs.showError(EXAError.WalletRestoringError(message: result.1), completionAction: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
        }
    }

    private func createPersonalWallet(_ creationInfo: WalletCreationInfo) -> (Bool, String, MoneroWallet?) {
        return WalletManager.shared.createWallet(creationInfo)
    }

    @objc func switchFirstResponder() {
        for item: EXAHeaderTextFieldView in [walletNameTextField, passTextField, verifyPassTextField] as [EXAHeaderTextFieldView] {
            item.textField.resignFirstResponder()
        }
        self.view.becomeFirstResponder()
    }

    /*@objc func keyboardWillHide(_ notification: Notification) {
        if !DeviceType.isiPhone6OrMore {
            let currentTopOffset = topViewOffset
            UIView.animate(withDuration: 0.2, animations: {
                self.view.top = currentTopOffset
            })
        }
    }*/

    private func subscriptions(_ toSubscript: Bool) {
        if toSubscript {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)),
                    name: UIResponder.keyboardDidShowNotification, object: nil)

            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHide(_:)),
                    name: UIResponder.keyboardWillHideNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }

    private func showWarningDialog() {
        let alert = AlertController(title: EXAAppInfoService.appTitle, message: l10n(.setEmptyPass), preferredStyle: .alert)
        alert.visualStyle = EXAAlertVisualStyle(alertStyle: .alert)
        let OKAction = AlertAction(title: l10n(.commonContinue), style: .destructive, handler: { [weak self]
        (action) -> Void in
            if let wSelf = self {
                wSelf.createOrRestoreWallet("")
            }
        })

        let cancelAction = AlertAction(title: l10n(.commonCancel), style: .preferred, handler: nil)
        alert.addAction(OKAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc func keyboardWasShown(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if !isKeyboardPresent {
                if let _ = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
                    isKeyboardPresent = true
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.top -= self.defaultKeyboardOffset
                    })
                }
            }
        }
    }

    @objc func keyboardWasHide(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if isKeyboardPresent {
                if let _ = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
                    isKeyboardPresent = false
                    UIView.animate(withDuration: 0.15, animations: {
                        self.view.top += self.defaultKeyboardOffset
                    })
                }
            }
        }
    }

    private func checkExistsSharedWallet(onSuccess: ((SharedWalletScheme) -> Void)? = nil) {
        guard let wallet = AppState.sharedInstance.currentWallet else { return }
        let B = wallet.publicSpendKey()

        schemeService.requestScheme(.by_public_key, info: B, completionAction: { scheme in
            onSuccess?(scheme)
                }, failureAction: { [weak self] error in
                EXADialogs.showError(EXAError.WalletRestoringError(message: error), completionAction: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                })
        })
    }
}

extension WalletMetaInfoWalletViewController: WalletColorPickerViewActionDelegate {

    func onChangeColor() {
        validateProcessOnlyInEditMode()
    }
}

extension WalletMetaInfoWalletViewController: SchemeCompletionDelegate {

    func completed(scheme: SharedWalletScheme) {
        updateScheme(scheme.signers, participants: scheme.participants)
    }

    func failure(error: String) {

    }
}

// Mock
extension WalletMetaInfoWalletViewController {

    private func mockRestoreRecentlyCreatedWallet(_ recentlyBlockHeight: UInt64) -> Bool {
        let sign = MockObjects.shared.multisigWallet.signatures
        let part = MockObjects.shared.multisigWallet.participants

        let restoreState: RestoreWalletState = RestoreWalletState()
        restoreState.mnemonic = MockObjects.shared.multisigWallet.mnemonic
        restoreState.blockHeight = recentlyBlockHeight
        AppState.sharedInstance.restoreWalletState = restoreState

        guard let walletMetaInfo = WalletMetaInfo(walletNameTextField.text, uuid: nil, type: .shared, color: colorPicker.selectedColor,
                blockHeight: recentlyBlockHeight, signatures: sign, participants: part) else { return false }

        let walletInfo = WalletCreationInfo(meta: walletMetaInfo, password: passTextField.text,
                remoteNodeAddress: remoteNodeTextField.text,
                mnemonic: MockObjects.shared.multisigWallet.mnemonic)

        let result = WalletManager.shared.restore(walletInfo)
        if result.0 {
            AppState.sharedInstance.currentWallet = result.2
            AppState.sharedInstance.currentWalletInfo = WalletInfo(walletMetaInfo,
                    balance: AppState.sharedInstance.currentWallet?.formattedBalance() ?? "0.00")

            switchFirstResponder()
            HUD.flash(.success, delay: 1.0) { [weak self] success in
                EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(self?.navigationController, step: .inviteParticipants)
            }
            return true
        } else {
            AppState.sharedInstance.restoreWalletState?.status = .fail
            EXADialogs.showError(EXAError.WalletRestoringError(message: result.1), completionAction: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })

            return false
        }
    }

    private func mockCreatingCommonWallet() {
        print(">>> mockCreatingCommonWallet")

        let blockHeight: UInt64 = 1626650
        // TODO: Check result
        _ = mockRestoreRecentlyCreatedWallet(blockHeight)
    }
}
