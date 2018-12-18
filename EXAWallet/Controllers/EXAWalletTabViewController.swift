//
//  EXAWalletTabViewController.swift
//  EXAWallet
//
//  Created by Igor Efremov on 06/02/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit

enum EXATabScreen: Int {
    case walletHome = 0, receive, send, walletSettings
    static let all = [walletHome, receive, send, walletSettings]

    var viewController: UIViewController {
        let vc: UIViewController
        switch self {
            case .receive:
                vc = ReceiveViewController()
            case .send:
                vc = SendViewController()
            case .walletHome:
                vc = WalletHomeViewController()
            case .walletSettings:
                vc = WalletSettingsViewController()
        }

        return vc
    }
}

class EXAWalletTabViewController: UITabBarController, UITabBarControllerDelegate {
    private let scrollingDelegate = ScrollingTabBarControllerDelegate()
    private var needStartSync: Bool = true
    
    private let loadingView: EXACircleStrokeLoadingIndicator = EXACircleStrokeLoadingIndicator("Stopping sync process... Please wait")

    convenience init(title: String) {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: EXAGraphicsResources.close,
                style: .plain,
                target: self,
                action: #selector(onCloseTap))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = EXATabScreen.walletHome.rawValue
        self.delegate = scrollingDelegate

        updateTitle()
        
        view.addSubview(loadingView)
        
        loadingView.fullScreenMode = true
        loadingView.isHidden = true
        loadingView.frame = self.view.frame
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if needStartSync {
            delay(0.5, closure: {
                AppState.sharedInstance.syncManager.startSync()
                self.needStartSync = false
            })
        }

        UIApplication.shared.isIdleTimerDisabled = true

        NotificationCenter.default.addObserver(self, selector: #selector(updateTitle),
                name: NSNotification.Name(rawValue: Notification.Name.WalletNameChanged), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
        super.viewWillDisappear(animated)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    @objc func updateTitle() {
        if let theWalletInfo = AppState.sharedInstance.currentWalletInfo {
            navigationItem.title = theWalletInfo.metaInfo.name
        }
    }

    private func commonInit() {
        self.edgesForExtendedLayout = UIRectEdge()
        self.viewControllers = composeViewController()
    }

    private func composeViewController() -> [UIViewController] {
        return EXATabScreen.all.map{$0.viewController}
    }

    @objc func onCloseTap() {
        showCloseWalletDialog()
    }

    private func showCloseWalletDialog() {
        let alertStyle: UIAlertController.Style = .alert
        let alert = UIAlertController(title: l10n(.commonWarning), message: "Do you want to close this wallet?", preferredStyle: alertStyle)
        let OKAction = UIAlertAction(title: l10n(.commonOk), style: .destructive) {
            [weak self] (_) in
            if let wSelf = self {
                wSelf.loadingView.startAnimating()
                delay(0.5, closure: {
                    wSelf.needStartSync = false
                    AppState.sharedInstance.syncManager.stopSync(true)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name.CloseCurrentWallet), object: nil)
                    
                    wSelf.loadingView.stopAnimating()
                    EXAAppNavigationDispatcher.sharedInstance.showDashboard()
                })
            }
        }
        alert.addAction(OKAction)

        let cancelAction = UIAlertAction(title: l10n(.commonCancel), style: .default)
        alert.addAction(cancelAction)
        alert.preferredAction = cancelAction

        self.present(alert, animated: true)
    }
}
