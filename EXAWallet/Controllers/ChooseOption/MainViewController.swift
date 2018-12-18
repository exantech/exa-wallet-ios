//
//  MainViewController.swift
//  EXAWallet
//
//  Created by Igor Efremov on 09/01/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: UIViewController, EXAWalletCreateOptionsActionDelegate {
    private let tableView = EXAWalletCreateOptionsTableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        navigationItem.title = l10n(.chooseOption)

        view.addSubview(tableView)

        applyStyles()
        applyLayout()

        tableView.actionDelegate = self
        tableView.reloadData()
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.screenBackgroundColor
    }
    
    func applyLayout() {
        tableView.snp.makeConstraints { (make) in
            make.top.left.height.width.equalToSuperview()
        }
    }

    func onSelectCreateOption(_ option: EXAMoneroWalletCreateOption) {
        AppState.sharedInstance.currentState = .creating

        switch option {
            case .createPersonal:
                createWalletAction()
            case .restore:
                restoreWalletAction()
            case .createShared:
                createCommonWalletAction()
            case .joinShared:
                joinSharedWalletAction()
        }
    }
    
    private func createWalletAction() {
        EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(navigationController, step: .createWallet)
    }

    private func restoreWalletAction() {
        EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(navigationController, step: .restoreWallet)
    }

    private func createCommonWalletAction() {
        EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(navigationController, step: .createCommonWallet)
    }

    private func joinSharedWalletAction() {
        EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(navigationController, step: .joinSharedWallet)
    }
}
