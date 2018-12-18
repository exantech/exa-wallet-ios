//
//  AppAuthentication.swift
//
//
//  Created by Vladimir Malakhov on 27/06/2018.
//  Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

typealias AppAuthenticationStateHandler = (AppAuthenticationState, AuthType) -> ()
enum AppAuthenticationState {
    case attempt, success, error
}
enum AuthType {
    case pin, bio
}

final class AppAuthentication {
    
    var state: AppAuthenticationStateHandler?
    var onPresentPin: DefaultCallback?
    var onCancelCreate: DefaultCallback?
    var onDismissBiometryScreen: DefaultCallback?
    
    private var bioAuth: AppBioAuthenticationProtocol?
    private var pinAuth: PinCodeViewController?
}

extension AppAuthentication: AppAuthenticationProtocol {
    
    func proceed(with mode: PinCodeMode) {
        DispatchQueue.main.async { [weak self] in
            self?.proceedPinAuth(with: mode)
        }
        proceedBioAuthIfPossible(with: mode)
        updatePinIconIfNeeded()
    }
}

extension AppAuthentication: PinCodeDismissDelegate {
    
    func proceedPinAuth(with mode: PinCodeMode) {
        state?(.attempt, .pin)
        let pincodeService = PinCodeViewController()
        guard let pinAuthObject = pincodeService.present(with: mode, delegate: self) else {
            print("AppNavigation: Error unable to load pinController")
            return
        }
        pinAuth = pinAuthObject
        pinAuthObject.onBioAuthSelected = { [weak self] in
            self?.proceedBioAuth()
        }
        pinAuthObject.onCorrectPin = { [weak self] in
            self?.state?(.success, .pin)
        }
        pincodeService.onPresent = { [weak self] in
            self?.onPresentPin?()
        }
        pinAuthObject.onCancelCreate = { [weak self] in
            self?.onCancelCreate?()
        }
        pinAuthObject.presentEnd = { [weak self] in
            self?.onDismissBiometryScreen?()
        }
        guard let bioAuth = bioAuth else { return }
        if bioAuth.isFaceID() {
            if #available(iOS 11.0, *) {
                pinAuthObject.updateIcon()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func dismissPin() {
        pinAuth?.dismiss(animated: false, completion: nil)
    }
    
    func onDismiss() {}
    
    func updatePinIconIfNeeded() {
        guard let bioAuth = bioAuth else { return }
        if bioAuth.isFaceID() {
            if #available(iOS 11.0, *) {
                pinAuth?.updateIcon()
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

private extension AppAuthentication {
    
    func proceedBioAuthIfPossible(with mode: PinCodeMode) {
        switch mode {
        case .validate:
            proceedBioAuth()
        case .deactive:
            break
        case .create:
            break
        case .change:
            break
        }
    }
    
    func proceedBioAuth() {
        state?(.attempt, .bio)
        bioAuth = AppBioAuthentication()
        bioAuth?.proccess()
        bioAuth?.onResult = { [weak self] result, type in
            switch result {
            case .attempt:
                break
            case .success:
                self?.dismissPin()
                self?.state?(.success, .bio)
            case .error:
                break
            }
        }
    }
}
