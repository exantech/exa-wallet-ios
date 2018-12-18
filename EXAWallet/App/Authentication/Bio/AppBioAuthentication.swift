//
//  AppLocalAuthentication.swift
//
//
//  Created by Vladimir Malakhov on 06/06/2018.
//  Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import LocalAuthentication

protocol AppBioAuthenticationProtocol {
    
    var onResult: AppAuthenticationStateHandler? { get set }
    func proccess()
    func isFaceID() -> Bool
    func isEnrolled() -> Bool
    func isBiometryAvaible() -> Bool
}

final class AppBioAuthentication {
    
    var onResult: AppAuthenticationStateHandler?
    
    private let localAuthenticationContext = LAContext()
    private let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
    private let control = AppBioAuthenticationControl()
}

extension AppBioAuthentication: AppBioAuthenticationProtocol {
    
    func isBiometryAvaible() -> Bool {
        return reviewEvaluatePolicy(handleError: false)
    }
    
    func isEnrolled() -> Bool {
        return reviewEvaluatePolicyForEnrolled()
    }
    
    func proccess() {
        guard control.value() else {
            return
        }
        let reviewStatus = reviewEvaluatePolicy(handleError: true)
        if  reviewStatus {
            setupLAContext()
            authentication()
        }
    }
    
    func isFaceID() -> Bool {
        if #available(iOS 11.0, *) {
            _ = reviewEvaluatePolicy(handleError: false)
            if localAuthenticationContext.biometryType == .faceID {
                return true
            } else {
                return false
            }
        } else {
            // Fallback on earlier versions
        }
        return false
    }
}

private extension AppBioAuthentication {
    
    func reviewEvaluatePolicy(handleError: Bool) -> Bool {
        var error: NSError?
        if localAuthenticationContext.canEvaluatePolicy(policy, error: &error) {
            return true
        } else {
            if handleError {
                let errorHandler = AppBioAuthenticationErrorHandler()
                errorHandler.handle(for: error)
            }
            return false
        }
    }
    
    func reviewEvaluatePolicyForEnrolled() -> Bool {
        var error: NSError?
        if localAuthenticationContext.canEvaluatePolicy(policy, error: &error) {
            return true
        } else {
            guard let error = error else { return false }
            switch error {
            case LAError.touchIDNotAvailable:
                return false
            default:
                return true
            }
        }
    }
    
    func setupLAContext() {
        localAuthenticationContext.localizedFallbackTitle = l10n(.authBioEnterPassword)
    }
    
    func authentication() {
        localAuthenticationContext.evaluatePolicy(policy, localizedReason: localizedReason()) { (success, authError) in
            if success {
                DispatchQueue.main.async {
                    self.onResult?(.success, .bio)
                }
            } else {
                guard let error = authError else {
                    return
                }
                DispatchQueue.main.async {
                    self.onResult?(.error, .bio)
                }
                
                print("AppLocalAuthentication: Error - \(error)")
            }
        }
    }
    
    func localizedReason() -> String {
        var localString = l10n(.authBioTouchId)
        if #available(iOS 11.0, *) {
            if localAuthenticationContext.biometryType == .faceID {
                localString = l10n(.authBioFaceId)
            }
        } else {
            print("AppBioAuthentication: Device is under iOS 11.0")
        }
        return localString
    }
}
