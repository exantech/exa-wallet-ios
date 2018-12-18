//
// Created by Igor Efremov on 07/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import QuickTableViewController
import KeychainAccess

class WalletSettingsViewController: QuickTableViewController {
    private let storageService: EXAWalletMetaInfoStorageService = EXAWalletMetaInfoStorageService()

    private let preferencesWalletSection: Section = Section(title: "Preferences", rows: [])
    private let otherWalletSection: Section = Section(title: "Other", rows: [])
    private let deleteWalletSection: Section = Section(title: "", rows: [])
    private var meta = AppState.sharedInstance.currentWalletMetaInfo

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tabBarItem = EXATabBarItem(image: EXAGraphicsResources.walletSettingsTab, tag: EXATabScreen.walletSettings.rawValue)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyles()

        _ = storageService.load()

        preferencesWalletSection.rows = createPreferencesSection()
        otherWalletSection.rows = createOtherSection()
        deleteWalletSection.rows = createDeleteWalletSection()
        tableContents = [ preferencesWalletSection, otherWalletSection, deleteWalletSection ]
    }

    override func applyStyles() {
        super.applyStyles()

        navigationItem.title = l10n(.settingsTitle)
        view.backgroundColor = UIColor.detailsScreenBackgroundColor
    }

    private func createPreferencesSection() -> [Row & RowStyle] {
        return [ NavigationRow(text: l10n(.settingsEditMeta), detailText: .none, icon: .image(EXAGraphicsResources.editMeta),
                action: { [weak self] (row) -> () in self?.onEditWalletMeta()}),
                 NavigationRow(title: l10n(.settingsRememberPassphrase), subtitle: .belowTitle(l10n(.settingsPasswordRequired)), icon: .image(EXAGraphicsResources.remember), customization: { cell, _ in
                    cell.textLabel?.numberOfLines = 2
                 }, action: { [weak self] (row) -> () in self?.onRememberPassPhrase()}),
                 NavigationRow(title: l10n(.settingsChangeWalletPassword), subtitle: .belowTitle(l10n(.settingsPasswordRequired)), icon: .image(EXAGraphicsResources.changePassword), customization: { cell, _ in
                     cell.textLabel?.textColor = UIColor.lightGray
                 }, action: { [weak self] (row) -> () in self?.onChangePassword()})
                 ]
    }
    
    private func createOtherSection() -> [Row & RowStyle] {
        return [ NavigationRow(title: l10n(.settingsNodeAddress), subtitle: .belowTitle(AppState.sharedInstance.settings.environment.nodes.currentNode), action: onEditNodeAddress() ),
                 SwitchRow(title: l10n(.settingsHideBalance), switchValue: meta?.hideBalance ?? false, action: onToggleBalanceVisibility()),
                 SwitchRow(title: l10n(.settingsRequestPasswordWhenOpening), switchValue: meta?.requiredPasswordWhenOpening ?? false, action: onTogglePasswordRequirement()) ]
    }

    private func createDeleteWalletSection() -> [Row & RowStyle] {
        return [ NavigationRow(text: l10n(.settingsDeleteWalletOption), detailText: .none, icon: .image(EXAGraphicsResources.delete), customization: { cell, _ in
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.mainColor
            }, action: { [weak self] (row) -> () in self?.onDeleteWallet()}) ]
    }

    private func onEditWalletMeta() {
        let vc = WalletMetaInfoWalletViewController(mode: .edit)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func onTogglePasswordRequirement() -> (Row) -> (Void) {
        return { [weak self] row in
            if let switchRow = row as? SwitchRowCompatible {
                self?.meta?.requiredPasswordWhenOpening = switchRow.switchValue
                if let theMeta = self?.meta {
                    if let theNewMeta = self?.storageService.changeMeta(by: theMeta.uuid, newMeta: theMeta) {
                        AppState.sharedInstance.currentWalletInfo = WalletInfo(theNewMeta, balance: AppState.sharedInstance.currentWalletInfo?.balance ?? "0.00")
                    }
                }
            }
        }
    }

    private func onToggleBalanceVisibility() -> (Row) -> (Void) {
        return { [weak self] row in
            if let switchRow = row as? SwitchRowCompatible {
                self?.meta?.hideBalance = switchRow.switchValue
                if let theMeta = self?.meta {
                    if let theNewMeta = self?.storageService.changeMeta(by: theMeta.uuid, newMeta: theMeta) {
                        AppState.sharedInstance.currentWalletInfo = WalletInfo(theNewMeta, balance: AppState.sharedInstance.currentWalletInfo?.balance ?? "0.00")
                    }
                }
            }
        }
    }

    private func onEditNodeAddress() -> (Row) -> (Void) {
        return { [weak self] row in
            let vc = BlockchainNodeViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func onRememberPassPhrase() {
        doRequiredPasswordAction({ [weak self] in
            if let wSelf = self {
                let vc = PassphraseViewController(mode: .remember)
                wSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    private func onChangePassword() {
        EXADialogs.showMessage("Not implemented yet", title: l10n(.commonWarning), buttonTitle: l10n(.commonOk))
        /*doRequiredPasswordAction({ [weak self] in
            if let wSelf = self {
                // TODO: Implement change password dialog
            }
        })*/
    }
    
    private func doRequiredPasswordAction(_ action: (() -> Void)? = nil) {
        guard let meta = AppState.sharedInstance.currentWalletMetaInfo else { return }
        
        let keychain = Keychain(service: "eu.exante.exawallet")
        if let password = try? keychain.get(meta.uuid), let thePass = password {
            EXADialogs.showEnterWalletPassword(completion: {
                (pass) -> Void in
                if thePass == pass {
                    action?()
                } else {
                    EXADialogs.showError(EXAError.WrongPassword)
                }
            })
        }
    }

    private func onDeleteWallet() {
        showDeleteWalletDialog()
    }

    private func showDeleteWalletDialog() {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return }

        let alertStyle: UIAlertController.Style = .alert
        let alert = UIAlertController(title: l10n(.commonWarning), message: "Are you sure you want to delete '\(meta.metaInfo.name)' wallet?\n\nYour money will be lost forever unless you have written down the recovery phrase and kept it somewhere safe.\n\nTo view your recovery phrase press “Cancel” then go to Settings – Remember Mnemonic Passphrase.", preferredStyle: alertStyle)
        let OKAction = UIAlertAction(title: l10n(.commonOk), style: .destructive) {
            [weak self] (_) in
            if let wSelf = self {
                wSelf.deleteWalletFiles(meta.metaInfo.uuid)
            }
        }
        alert.addAction(OKAction)

        let cancelAction = UIAlertAction(title: l10n(.commonCancel), style: .default)
        alert.addAction(cancelAction)
        alert.preferredAction = cancelAction

        self.present(alert, animated: true)
    }

    private func deleteWalletFiles(_ walletUUID: String) {
        let storageService: EXAWalletMetaInfoStorageService = EXAWalletMetaInfoStorageService()
        // TODO: Check result
        _ = storageService.load()

        AppState.sharedInstance.syncManager.stopSync()
        delay(2.0, closure: {
            if EXAWalletFileManager.shared.removeWalletFile(walletUUID) {
                storageService.removeMeta(by: walletUUID)
                EXAAppNavigationDispatcher.sharedInstance.showDashboard()
            } else {
                print("Error")
            }
        })
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
}

extension WalletSettingsViewController {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}
