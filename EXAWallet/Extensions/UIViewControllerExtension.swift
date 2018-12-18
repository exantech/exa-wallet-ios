//
//  UIViewControllerExtension.swift
//  EXAWallet
//
//  Created by Igor Efremov on 21/02/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit

extension UIViewController: EXAUIStylesSupport {
    func setupBackButton() {
        let customBackButton = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = customBackButton
    }

    func applyStyles() {
        setupBackButton()
    }
}
