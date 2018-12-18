//
//  PinCodeViewController.swift
//
//
//  Created by Igor Efremov on 04/02/2018.
//  Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import LocalAuthentication
import AudioToolbox
import SnapKit

enum PinCodeConstants {
    static let nibName = "PinCodeViewController"
    static let kPincodeDefaultsKey = "pincode"
    static let kPincodeCurrentAttempt = "currentAttempt"
    static let kPincodeCurrentAttemptChanged = "currentAttemptChanged"
    static let kPincodeWaitingInSeconds = "waitingInSeconds"
    static let duration = 0.3
    static let maxPinLength = 4

    enum button: Int {
        case delete = 1000
        case cancel = 1001
    }
}

protocol PinCodeDismissDelegate: class {
    func onDismiss()
}

class PinCodeViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var submessageLabel: UILabel!
    @IBOutlet var pinIndicators: [Indicator]!
    @IBOutlet var keyboardView: UIView!
    
    @IBOutlet weak var cancelButton: Button!
    var onBioAuthSelected: DefaultCallback?
    var onCorrectPin: DefaultCallback?
    var onCancelCreate: DefaultCallback?
    var onPresent: DefaultCallback?
    
    weak var dismissDelegate: PinCodeDismissDelegate?
    
    private let bioAuth = AppBioAuthentication()
    private var controllerReference: UIViewController?
    
    var isPrevChange = false

    private var pin = ""
    private var reservedPin = ""
    private var isFirstCreationStep = true
    private var savedPin: String? {
        get {
            return UserDefaults.standard.string(forKey: PinCodeConstants.kPincodeDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PinCodeConstants.kPincodeDefaultsKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    private let maxAttempts = 3
    private var currentAttempt: UInt {
        get {
            return UInt(UserDefaults.standard.integer(forKey: PinCodeConstants.kPincodeCurrentAttempt))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PinCodeConstants.kPincodeCurrentAttempt)
            UserDefaults.standard.synchronize()
        }
    }
    private var currentAttemptChanged: UInt {
        get {
            return UInt(UserDefaults.standard.integer(forKey: PinCodeConstants.kPincodeCurrentAttemptChanged))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PinCodeConstants.kPincodeCurrentAttemptChanged)
            UserDefaults.standard.synchronize()
        }
    }
    private var waitingInSeconds: UInt = 30
    private var keysBlocked: Bool = false
    
    private var timer: Timer?
    
    var presentEnd: DefaultCallback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyStyles()
        applyLayout()
        
        cancelButton.addTarget(self, action: #selector(bioAuthButtonPressed), for: .touchUpInside)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func bioAuthButtonPressed() {
        onBioAuthSelected?()
    }
    
    override func applyStyles() {
        for subview in keyboardView.subviews {
            (subview as? EXAUIStylesSupport)?.applyStyles()
        }
    }
    
    func applyLayout() {
        photoImageView.snp.makeConstraints { (make) in
            make.width.equalTo(EXAGraphicsResources.logoPin.size.width)
            make.height.equalTo(EXAGraphicsResources.logoPin.size.height)
            make.bottom.equalTo(submessageLabel.snp.top).offset(-30)
            make.centerX.equalToSuperview()
        }
    }
    
    private var mode: PinCodeMode? {
        didSet {
            let mode = self.mode ?? .validate
            let msgText: String
            switch mode {
            case .create:
                transformCancelButtonToDefault()
                msgText = l10n(.pinCodeCreate)
            case .change:
                transformCancelButtonToDefault()
                msgText = l10n(.pinCodeEnter)
                
                isPrevChange = true
                
                if bioAuth.isEnrolled() || bioAuth.isBiometryAvaible() {
                    AppState.sharedInstance.isBiometryPresent = true
                    bioAuth.proccess()
                }
                bioAuth.onResult = { [weak self] (state, type) in
                    if state == .success {
                        self?.precreateSettings()
                        AppState.sharedInstance.isBiometryPresent = false
                    }
                }
                
                if maxAttempts <= currentAttemptChanged {
                    startDelayProcess()
                }
            
            case .deactive:
                msgText = l10n(.pinCodeEnter)
            case .validate:
                
                if !AppBioAuthenticationControl().value() || !AppBioAuthentication().isBiometryAvaible() {
                    cancelButton.isHidden = true
                }
                
                msgText = l10n(.pinCodeEnter)
                isFirstCreationStep = false
                
                if maxAttempts <= currentAttempt {
                    startDelayProcess()
                }
            }

            submessageLabel.text = msgText
        }
    }
    
    private func pincodeChecker(_ pinNumber: Int) {
        if pin.count < PinCodeConstants.maxPinLength {
            pin.append("\(pinNumber)")
            if pin.count == PinCodeConstants.maxPinLength {
                switch mode ?? .validate {
                case .create:
                    createModeAction()
                case .change:
                    changeModeAction()
                    noop()
                case .deactive:
                    //deactiveModeAction()
                    noop()
                case .validate:
                    validateModeAction()
                }
            }
        }
    }
    
    private func transformCancelButtonToDefault() {
        cancelButton.setImage(nil, for: .normal)
        cancelButton.setTitle(l10n(.commonCancel), for: .normal)
        cancelButton.removeTarget(self, action: #selector(bioAuthButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(keyboardPressed), for: .touchUpInside)
    }
    
    private func onCorrectPinEntered() {
        currentAttempt = 0
        onCorrectPin?()
        dismiss(animated: false, completion: {
            [weak self] in
            if let wSelf = self {
                wSelf.dismissDelegate?.onDismiss()
            }})
    }
    
    private func onIncorrectPinEntered() {
        currentAttempt += 1
        if maxAttempts <= currentAttempt {
            startDelayProcess()
        }
        incorrectPinAnimation()
    }
    
    private func onIncorrectChangedPincodeEntered() {
        currentAttemptChanged += 1
        if maxAttempts <= currentAttemptChanged {
            startDelayProcess()
        }
        incorrectPinAnimation()
    }
    
    private func startDelayProcess() {
        keysBlocked = true
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(PinCodeViewController.updateWaiting),
                                     userInfo: nil,
                                     repeats: true)
        timer?.fire()
    }
    
    private func stopDelayProcess() {
        submessageLabel.text = l10n(.pinCodeEnter)
        keysBlocked = false
        waitingInSeconds = 30
        timer?.invalidate()
        currentAttemptChanged = 0
        timer = nil
    }
    
    @objc private func updateWaiting() {
        submessageLabel.text = "Waiting \(waitingInSeconds) seconds..."
        if waitingInSeconds > 0 {
            waitingInSeconds -= 1
        } else {
            stopDelayProcess()
        }
    }
    
    private func validateModeAction() {
        pin == savedPin ? onCorrectPinEntered() : onIncorrectPinEntered()
    }

    
    private func createModeAction() {
        if isFirstCreationStep {
            isFirstCreationStep = false
            reservedPin = pin
            clearPin()
            submessageLabel.text = l10n(.pinCodeConfirm)
        } else {
            confirmPin()
        }
    }
    
    private func precreateSettings () {
        currentAttemptChanged = 0
        mode = .create
        onCorrectPin?()
        clearPin()
    }
    
    private func changeModeAction() {
        pin == savedPin ? precreateSettings() : onIncorrectChangedPincodeEntered()
    }
    
    private func confirmPin() {
        if pin == reservedPin {
            savedPin = pin
            onCorrectPin?()
            AppState.sharedInstance.isBiometryPresent = false
            dismiss(animated: false, completion: {
                [weak self] in
                if let wSelf = self {
                    wSelf.dismissDelegate?.onDismiss()
                }})
            if AppBioAuthentication().isBiometryAvaible() && !isPrevChange {
                let presenter = AppBioAuthViewPresenter()
                presenter.present()
                presenter.dismissHandler = { [weak self] in
                    self?.presentEnd?()
                }
            } else {
                presentEnd?()
            }
        } else {
            incorrectPinAnimation()
        }
    }
    
    private func incorrectPinAnimation() {
        pinIndicators.forEach { view in
            view.shake(delegate: self)
            view.alpha = 0.25
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    private func clearPin() {
        pin = ""
        pinIndicators.forEach { view in
            view.isNeedClear = false
            UIView.animate(withDuration: PinCodeConstants.duration, animations: {
                view.alpha = 0.25
            })
        }
    }
    
    private func drawing(isNeedClear: Bool, tag: Int? = nil) {
        let results = pinIndicators.filter { $0.isNeedClear == isNeedClear }
        let pinView = isNeedClear ? results.last : results.first
        pinView?.isNeedClear = !isNeedClear
        
        UIView.animate(withDuration: PinCodeConstants.duration, animations: {
            pinView?.alpha = isNeedClear ? 0.25 : 1.0
        }) { _ in
            isNeedClear ? self.pin = String(self.pin.dropLast()) : self.pincodeChecker(tag ?? 0)
        }
    }

    @IBAction func keyboardPressed(_ sender: UIButton) {
        switch sender.tag {
        case PinCodeConstants.button.delete.rawValue:
            if !keysBlocked {
                drawing(isNeedClear: true)
            }
        case PinCodeConstants.button.cancel.rawValue:
            AppState.sharedInstance.isBiometryPresent = false
            guard let mode = mode else { return }
            if mode == .create {
                onCancelCreate?()
            }
            clearPin()
            if timer == nil {
                currentAttempt = 0
            }
            dismiss(animated: true, completion: {
                [weak self] in
                if let wSelf = self {
                    wSelf.presentEnd?()
                    wSelf.dismissDelegate?.onDismiss()
                }})
        default:
            if !keysBlocked {
                drawing(isNeedClear: false, tag: sender.tag)
            }
        }
    }
    
    @available(iOS 11.0, *)
    func updateIcon() {
        cancelButton.setImage(#imageLiteral(resourceName: "face_id"), for: .normal)
    }
}

extension PinCodeViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        clearPin()
    }
}

extension PinCodeViewController {
    
    func present(with mode: PinCodeMode, delegate: PinCodeDismissDelegate?) -> PinCodeViewController? {
        guard let root = UIApplication.shared.keyWindow?.rootViewController,
            let locker = Bundle.main.loadNibNamed(PinCodeConstants.nibName, owner: self, options: nil)?.first as? PinCodeViewController else {
                return nil
        }
        
        controllerReference = locker
        
        locker.dismissDelegate = delegate
        locker.messageLabel.text = ""
        locker.submessageLabel.text = ""
        locker.view.backgroundColor = UIColor.exaBlack
        locker.mode = mode
        locker.modalPresentationStyle = .popover
        locker.photoImageView.image = EXAGraphicsResources.logoPin
        
        root.present(locker, animated: false) {
            self.onPresent?()
        }
        
        return locker
    }
    
    func dismiss() {
        AppState.sharedInstance.isBiometryPresent = false
        controllerReference?.dismiss(animated: true, completion: nil)
    }
}
