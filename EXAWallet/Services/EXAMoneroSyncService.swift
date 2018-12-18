//
// Created by Igor Efremov on 24/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum SyncState: Int {
    case synched, nosynched
}

class EXAMoneroSyncService {
    private var syncActive: Bool = false

    init() {
        print("==== init EXAMoneroSyncService")
    }

    func initialize() -> Bool {
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            print("Wallet is not exist")
            return false
        }

        print("====== initialize EXAMoneroSyncService")

        if !theWallet.initializeSync() {
            return false
        }

        syncActive = true
        return true
    }

    func startSync(from block: UInt64 = 0) {
        let test = Thread.current.isMainThread ? "Main" : "Background"
        print("START Monero Sync Service in \(Thread.current.description) thread. This is \(test) thread")
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            print("Wallet is not exist")
            return
        }

        // TODO: Check result
        _ = theWallet.sync(from: block)
    }

    func test() {
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            print("Wallet is not exist")
            return
        }

        theWallet.cancelSync()
    }

    func currentSyncBlock() -> UInt64 {
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            print("Wallet is not exist")
            return 0
        }

        return theWallet.currentSyncBlock()
    }

    func hasUnconfirmed() -> Bool {
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            print("Wallet is not exist")
            return false
        }

        return theWallet.hasUnconfirmed()
    }

    func isConnected() -> Bool {
        if !syncActive {
            return false
        }

        print("CHECK Monero Sync Service State...")

        guard let theWallet = AppState.sharedInstance.currentWallet else {
            print("Wallet is not exist")
            return false
        }

        return theWallet.isConnectedToSync()
    }

    func pauseSync() {
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            print("Wallet is not exist")
            return
        }

        print("PAUSE Monero Sync Service")
        theWallet.pauseSync()

        AppState.sharedInstance.tempSyncNeeded = true
    }

    func stopSync() {
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            print("Wallet is not exist")
            return
        }

        print("STOP Monero Sync Service")
        //theWallet.pauseSync()
        theWallet.store()
        syncActive = false

        AppState.sharedInstance.tempSyncNeeded = true
    }
    
    func clear() {
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            return
        }
        
        theWallet.clear()
    }

    func syncState() -> SyncState {
        guard let theWallet = AppState.sharedInstance.currentWallet else { return .nosynched }

        return theWallet.isSynched() ? .synched : .nosynched
    }

    deinit {
        print("==== deinit EXAMoneroSyncService")
        stopSync()
    }
}
