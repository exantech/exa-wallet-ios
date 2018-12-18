//
// Created by Igor Efremov on 21/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum AppWorkflowState {
    case normal, creating
}

class AppState {
    static let sharedInstance = AppState()
    var settings: AppSettingsModel = AppSettingsModel()
    var currentWallet: MoneroWallet?
    var currentWalletInfo: WalletInfo? {
        didSet {
            if let theCurrentWalletInfo = currentWalletInfo {
                print("currentWalletInfo: \(theCurrentWalletInfo)")
            }
        }
    }
    var currentWalletMetaInfo: WalletMetaInfo?
    var walletsMetaInfo: [WalletMetaInfo]?

    var currentState: AppWorkflowState = .normal

    var tempSyncNeeded: Bool = true

    var restoreMnemonic: String?

    var restoreWalletState: RestoreWalletState?

    var usingMock: Bool = false

    var syncManager: WalletSyncManager = WalletSyncManager()

    var proposals: [TransactionProposal] = [TransactionProposal]()
    var activeProposal: [TransactionProposal] {
        return proposals.filter { $0.completed == false }
    }

    var isBiometryPresent = false

    func sessionId(for walletId: String) -> String? {
        return UserDefaults.standard.string(forKey: compositeKey(EXAWalletDefaults.sessionId, walletId))
    }

    func setupSessionId(_ sessionId: String, for walletId: String) {
        UserDefaults.standard.set(sessionId, forKey: compositeKey(EXAWalletDefaults.sessionId, walletId))
    }

    func extraMultiInfo(for walletId: String) -> String? {
        return UserDefaults.standard.string(forKey: compositeKey(EXAWalletDefaults.extraMultiInfo, walletId))
    }

    func setupExtraMultiInfo(_ info: String, for walletId: String) {
        UserDefaults.standard.set(info, forKey: compositeKey(EXAWalletDefaults.extraMultiInfo, walletId))
    }

    func walletTransformationCurrentLevel(for walletId: String) -> Int {
        return UserDefaults.standard.integer(forKey: compositeKey(EXAWalletDefaults.walletTransformationCurrentLevel, walletId))
    }

    func setupWalletTransformationCurrentLevel(_ value: Int, for walletId: String) {
        UserDefaults.standard.set(value, forKey: compositeKey(EXAWalletDefaults.walletTransformationCurrentLevel, walletId))
    }

    func changedKey(for walletId: String) -> Bool {
        return UserDefaults.standard.bool(forKey: compositeKey(EXAWalletDefaults.changedKey, walletId))
    }

    func setupChangedKey(_ value: Bool, for walletId: String) {
        UserDefaults.standard.set(value, forKey: compositeKey(EXAWalletDefaults.changedKey, walletId))
    }

    func inviteCode(for walletId: String) -> InviteCode? {
        let value = UserDefaults.standard.string(forKey: compositeKey(EXAWalletDefaults.inviteCode, walletId))
        return InviteCode(value: value)
    }

    func setupInviteCode(_ inviteCode: InviteCode, for walletId: String) {
        UserDefaults.standard.set(inviteCode.value, forKey: compositeKey(EXAWalletDefaults.inviteCode, walletId))
    }

    func sentOutputForTransactionsCount(for walletId: String) -> Int {
        return UserDefaults.standard.integer(forKey: compositeKey(.sentOutputForTransactionsCount, walletId))
    }

    func setupSentOutputForTransactionsCount(_ count: Int, for walletId: String) {
        UserDefaults.standard.set(count, forKey: compositeKey(.sentOutputForTransactionsCount, walletId))
    }

    func lastImportedOutputsHash(for walletId: String) -> String? {
        return UserDefaults.standard.string(forKey: compositeKey(.lastImportedOutputsHash, walletId))
    }

    func lastImportedOutputsHashes(for walletId: String) -> [String]? {
        return UserDefaults.standard.stringArray(forKey: compositeKey(.lastImportedOutputsHashes, walletId))
    }

    func setupLastImportedOutputsHashes(_ value: [String], for walletId: String) {
        UserDefaults.standard.set(value, forKey: compositeKey(.lastImportedOutputsHashes, walletId))
    }

    func setupLastImportedOutputsHash(_ value: String, for walletId: String) {
        UserDefaults.standard.set(value, forKey: compositeKey(.lastImportedOutputsHash, walletId))
    }

    func oldPersonalKey(for walletId: String) -> String? {
        return UserDefaults.standard.string(forKey: compositeKey(.oldPersonalKey, walletId))
    }

    func saveOldPersonal(_ oldPersonalKey: String, for walletId: String) {
        UserDefaults.standard.set(oldPersonalKey, forKey: compositeKey(.oldPersonalKey, walletId))
    }

    func sharedPubKeys(for walletId: String) -> [String]? {
        return UserDefaults.standard.array(forKey: compositeKey(.sharedPubKeys, walletId)) as? [String]
    }

    func saveSharedPublicKeys(_ pubKeys: [String]?, for walletId: String) {
        guard let thePubKeys = pubKeys else { return }
        UserDefaults.standard.set(thePubKeys, forKey: compositeKey(.sharedPubKeys, walletId))
    }

    func token() -> String? {
        return UserDefaults.standard.string(forKey: EXAWalletDefaults.exaWalletDeviceUid.rawValue)
    }

    func saveToken(_ token:String) {
        UserDefaults.standard.set(token, forKey: EXAWalletDefaults.exaWalletDeviceUid.rawValue)
    }

    private func compositeKey(_ key: EXAWalletDefaults, _ walletId: String) -> String {
        return "\(key.rawValue)_\(walletId)"
    }

    // TODO: rewrite
    var tempCurrentOption: EXAMoneroWalletCreateOption = .createPersonal
    var tempInviteCode: String? = nil

    // TODO: some defaults in dev process
    let defaultSharedScheme: SharedWalletScheme = SharedWalletScheme(2, 2)
}
