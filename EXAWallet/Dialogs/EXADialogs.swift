//
// Created by Igor Efremov on 21/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SDCAlertView

class EXADialogs {
    class func showMessage(_ message: String, title: String, buttonTitle: String, dismissTimeout: Double? = nil,
                           completionAction: (() -> Void)? = nil, dismissAction: (() -> Void)? = nil) {
        let alert = AlertController(title: title, message: message, preferredStyle: .alert)
        alert.visualStyle = EXAInputDialogVisualStyle(alertStyle: .alert)
        let OKAction = AlertAction(title: buttonTitle, style: .preferred, handler: {
            (action) -> Void in
            completionAction?()
            dismissAction?()
        })

        alert.addAction(OKAction)
        alert.present()

        if let theDismissTimeout = dismissTimeout {
            delay(theDismissTimeout, closure: {
                alert.dismiss(animated: true,completion: {
                    dismissAction?()
                })
            })
        }
    }

    class func showMessage(_ message: EXADialogMessage, dismissTimeout: Double? = nil, completionAction: (() -> Void)? = nil, dismissAction: (() -> Void)? = nil) {
        EXADialogs.showMessage(message.description, title: message.title, buttonTitle: message.buttonTitle,
                dismissTimeout: dismissTimeout, completionAction: completionAction, dismissAction: dismissAction)
    }

    class func showError(_ error: Error, title: String = "Error", buttonTitle: String = "OK", completionAction: (() -> Void)? = nil) {
        var message = error.localizedDescription
        var localTitle = title

        if error is EXAError {
            message = (error as? EXAError)?.description ?? ""
            localTitle = (error as? EXAError)?.title ?? title
        }

        EXADialogs.showMessage(message, title: localTitle, buttonTitle: buttonTitle, completionAction: completionAction)
    }

    class func showEnterWalletPassword(completion: ((String) -> Void)? = nil, cancel: (() -> Void)? = nil) {
        let alert = AlertController(title: l10n(.commonEnterPassword), message: "", preferredStyle: .alert)
        alert.visualStyle = EXAInputDialogVisualStyle(alertStyle: .alert)
        let OKAction = AlertAction(title: l10n(.commonContinue), style: .preferred, handler: {
            (action) -> Void in
            if let thePass = alert.textFields![0].text {
                completion?(thePass)
            }
        })
        let cancelAction = AlertAction(title: l10n(.commonCancel), style: .normal , handler: {
            (action) -> Void in
            cancel?()
        })

        alert.addTextField(withHandler: {
            (textField) -> Void in
            textField.isSecureTextEntry = true
            textField.textColor = UIColor.invertedTitleLabelColor
            textField.font = UIFont.systemFont(ofSize: 16.0)
            textField.borderStyle = .none
            textField.placeholder = "Wallet Password"
            textField.keyboardAppearance = .dark
            textField.tintColor = UIColor.invertedTitleLabelColor
        })

        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        alert.present()
    }
}
