//
//  AppBioAuthenticationErrorHandler.swift
//
//
//  Created by Vladimir Malakhov on 28/06/2018.
//  Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import LocalAuthentication

final class AppBioAuthenticationErrorHandler {
    
    func handle(for error: NSError?) {
        
        guard let error = error else {
            return
        }
        
        if #available(iOS 11.0, *) {
            handleErrorAfter11iOS(error)
        }
    }
}

private extension AppBioAuthenticationErrorHandler {
    
    @available(iOS 11.0, *)
    func handleErrorAfter11iOS(_ error: NSError) {
        switch error {
        case LAError.biometryLockout:
            notify(with: l10n(.authErrorBioLockout))
        case LAError.passcodeNotSet:
            notify(with: l10n(.authErrorPasscodeNotSet))
        default:
            break
        }
    }
}

private extension AppBioAuthenticationErrorHandler {
    
    func notify(with message: String) {
        DispatchQueue.main.async {
            EXADialogs.showMessage(message, title: l10n(.commonError), buttonTitle: l10n(.commonOk))
        }
    }
}
