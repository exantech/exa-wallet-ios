//
// Created by Igor Efremov on 24/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit
import QuickTableViewController

class SettingsViewController: QuickTableViewController {
    private let preferencesWalletSection: Section = Section(title: "Security", rows: [])
    private let aboutWalletSection: Section = Section(title: "", rows: [])

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

        preferencesWalletSection.rows = createPreferencesSection()
        aboutWalletSection.rows = createAboutWalletSection()
        tableContents = [ preferencesWalletSection, aboutWalletSection ]
    }

    override func applyStyles() {
        super.applyStyles()

        navigationItem.title = l10n(.settingsTitle)
        view.backgroundColor = UIColor.detailsScreenBackgroundColor
    }

    private func createPreferencesSection() -> [Row & RowStyle] {
        return [ NavigationRow(text: "Change PIN", detailText: .none, icon: .image(EXAGraphicsResources.changePin),
                action: { [weak self] (row) -> () in self?.onChangePin()}) ]
    }

    private func createAboutWalletSection() -> [Row & RowStyle] {
        return [ NavigationRow(text: "About EXA Wallet", detailText: .none, icon: .image(EXAGraphicsResources.about), action: { [weak self] (row) -> () in self?.onAboutWallet()}) ]
    }

    private func onChangePin() {
        setupPIN()
    }

    private func setupPIN() {
        let pinCodeMode: PinCodeMode
        if let _ = UserDefaults.standard.string(forKey: PinCodeConstants.kPincodeDefaultsKey) {
            pinCodeMode = .change
        } else {
            pinCodeMode = .create
        }
        _ = PinCodeViewController().present(with: pinCodeMode, delegate: self)
    }

    private func onAboutWallet() {
        let vc = AboutViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
}

extension SettingsViewController: PinCodeDismissDelegate {

    func onDismiss() {

    }
}

extension SettingsViewController {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}
