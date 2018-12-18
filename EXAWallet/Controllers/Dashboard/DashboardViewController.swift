//
// Created by Igor Efremov on 24/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

import KeychainAccess

protocol WalletsDashboardActionDelegate: class {
    func addWallet()
}

private struct SizeConstants {

    static let leftOffset  = 30.0
    static let widthOffset = -2 * leftOffset
}

private typealias s = SizeConstants

class DashboardViewController: BaseViewController, WalletsDashboardActionDelegate {
    private let walletsView: EXAWalletsListView = EXAWalletsListView()
    private let addActionView: UIImageView = {
        let iv = UIImageView(image: EXAGraphicsResources.addImage)
        iv.size = EXAGraphicsResources.addImage.size
        return iv
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: EXAGraphicsResources.settings, style: .plain,
                target: self, action: #selector(onSettingsTap))

        [walletsView, addActionView].compactMap{$0}.forEach{view.addSubview($0)}

        applyStyles()
        applySizes()

        walletsView.actionDelegate = self
        walletsView.onTapConcreteWallet = { [weak self] (index) in
            self?.selectAndLoadWallet(index)
        }

        if let theWalletMetaInfo = AppState.sharedInstance.walletsMetaInfo {
            walletsView.update(withMeta: theWalletMetaInfo)
        }

        addActionView.addTapTouch(self, action: #selector(onTapAdd))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let theWalletMetaInfo = AppState.sharedInstance.walletsMetaInfo {
            walletsView.update(withMeta: theWalletMetaInfo)
        }
    }

    override func viewDidLayoutSubviews() {
        var h: CGFloat = 0.0
        if let theWalletMetaInfo = AppState.sharedInstance.walletsMetaInfo {
            h = CGFloat(theWalletMetaInfo.count * 80)
        }

        super.viewDidLayoutSubviews()
        walletsView.contentSize = CGSize(width: view.width, height: h)
    }

    override func applyStyles() {
        super.applyStyles()

        navigationItem.title = l10n(.dashboardTitle)
        view.backgroundColor = UIColor.screenBackgroundColor

        walletsView.applyStyles()
    }

    private func applySizes() {
        walletsView.snp.makeConstraints { (make) in
            make.left.width.top.height.equalToSuperview()
        }

        let sz = EXAGraphicsResources.addImage.size
        addActionView.snp.makeConstraints { (make) in
            make.width.equalTo(sz.width)
            make.height.equalTo(sz.height)
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-5)
        }
    }

    private func selectAndLoadWallet(_ index: Int) {
        if let theWalletMetaInfo = AppState.sharedInstance.walletsMetaInfo {
            let sortedMeta = theWalletMetaInfo.sorted(by: {$0.addedTimestamp > $1.addedTimestamp })
            let theMeta = sortedMeta[index]
#if TEST_PASS
            loadConcreteWallet(theMeta, password: MoneroCommonConstants.testDefaultPassword)
#else
            if theMeta.skippedPass {
                // TODO: check result
                _ = loadConcreteWallet(theMeta, password: "")
            } else {
                // check keychain
                let keychain = Keychain(service: "eu.exante.exawallet")
                if !theMeta.requiredPasswordWhenOpening {
                    if let password = try? keychain.get(theMeta.uuid), let thePass = password {
                        // TODO: check result
                        _ = loadConcreteWallet(theMeta, password: thePass)
                        return
                    }
                }

                EXADialogs.showEnterWalletPassword(completion: {
                    [weak self]
                    (pass) -> Void in
                    if let wSelf = self {
                        // TODO: check result
                        _ = wSelf.loadConcreteWallet(theMeta, password: pass)
                    }
                })
            }
#endif
        }
    }

    private func loadConcreteWallet(_ meta: WalletMetaInfo, password: String) -> Bool {
        let wallet = WalletManager.getWallet()
        let result = wallet.open(meta.uuid, password: password)

        if !result.0 {
            EXADialogs.showError(EXAError.WalletOpeningError(message: result.1 ?? ""))
        } else {

            let keychain = Keychain(service: "eu.exante.exawallet")
            do {
                try keychain
                        .accessibility(.whenUnlocked)
                        .set(password, key: meta.uuid)
            } catch let error {
                print("error: \(error)")
            }

            AppState.sharedInstance.currentWallet = wallet
            AppState.sharedInstance.currentWalletMetaInfo = meta
            AppState.sharedInstance.currentWalletInfo = WalletInfo(meta, balance: wallet.formattedBalance(), lockedBalance: wallet.formattedUnconfirmedBalance())

            if isNotReadySharedWallet(wallet, meta: meta) {
                let step: WalletSequenceStep
                if meta.creator == true {
                    step = WalletSequenceStep.inviteParticipantsAfterCreate
                } else {
                    step = WalletSequenceStep.participantScreen
                }
                EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(navigationController, step: step)
                return true
            }

            MoneroWalletMessageService.shared.setupPublicKeys(AppState.sharedInstance.sharedPubKeys(for: meta.uuid))
            EXAAppNavigationDispatcher.sharedInstance.showConcreteWallet()
        }
        
        return true
    }

    private func isNotReadySharedWallet(_ wallet: MoneroWallet, meta: WalletMetaInfo) -> Bool {
        return meta.type == .shared && !wallet.isReadyMultiSigWallet()
        //meta.type == .shared && (!meta.sharedReady || !wallet.isReadyMultiSigWallet())
    }

    @objc func onTapAdd() {
        addWallet()
    }

    @objc func onSettingsTap() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func addWallet() {
        EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(navigationController, step: .chooseOption)
    }
}
