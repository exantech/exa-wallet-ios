//
// Created by Igor Efremov on 09/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol WalletSyncManagerNotifier: class {
    func connectionError()
    func connecting()
    func connected()
    func syncCompleted()
}

class WalletSyncManager {
    private var _inSync: Bool = false

    private var syncService: EXAMoneroSyncService?
    private var timer: Timer?

    private var wh: UInt64?
    private var queue = OperationQueue()

    weak var notifier: WalletSyncManagerNotifier?

    var progress = ProgressInfo()

    private var savedBlockHeight: UInt64 = 0
    private var attemptsCount: UInt = 0

    init() {
        NSLog("== Create WalletSyncManager ==")
    }

    func startSync() {
        NSLog("== startSync ==")

        guard let theMeta = AppState.sharedInstance.currentWalletInfo else {
            return
        }

        _inSync = true
        attemptsCount = 0
        progress.reset()

        wh = AppState.sharedInstance.currentWallet?.blockHeight()
        let minBlock = theMeta.metaInfo.blockHeight ?? AppState.sharedInstance.settings.environment.minStartingBlock
        wh = max(wh ?? 0, UInt64(minBlock))
        
        progress.currentBlock = wh ?? 0

        syncService = EXAMoneroSyncService()
        if let theResult = syncService?.initialize(), theResult == true {
            NSLog("==== Sync Service initialized  ====")
        }

        print("==== Check connection to daemon...")
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self,
                selector: #selector(checkConnect), userInfo: nil, repeats: true)
    }

    @objc private func checkConnect() {
        guard let theSyncService = syncService else {
            return
        }
        guard let theWallet = AppState.sharedInstance.currentWallet else {
            return
        }

        notifier?.connecting()

        if theSyncService.isConnected() {
            print("Connected to node: ")
            timer?.invalidate()

            notifier?.connected()
            self.progress.setupTotalBlock(theWallet.networkBlockHeight())

            /*DispatchQueue.main.async { [weak self] in
                if let theSelf = self {
                    theSelf.syncService.startSync(from:theSelf.wh)
                }
            }*/

            /*let currWH = self.progress.currentBlock
            NSLog("Start sync with %u block", currWH)
            NSLog("Remaining %u", self.progress.remaining)

            syncView.state = .syncing*/

            /*workItem = DispatchWorkItem {
                [weak self] in
                //try? rawData.write(to: URL(fileURLWithPath: walletFilePath), options: [.atomic])
                //print("Wallet info saved")
                if let theSelf = self {
                    theSelf.syncService.startSync(from:currWH)
                    DispatchQueue.main.async { [weak self] in
                        self?.timerSync?.invalidate()
                        self?.onSyncStop()
                    }
                }
            }*/

            /*workItem = DispatchWorkItem {
                self.syncService.startSync(from:currWH)
                DispatchQueue.main.async { [weak self] in
                    self?.timerSync?.invalidate()
                    self?.onSyncStop()
                }
            }*/

            attemptsCount = 0
            if let currWH = wh {
                queue.addOperation {
                    self.syncService?.startSync(from: currWH)
                    DispatchQueue.main.async { [weak self] in
                        self?.onSyncCompleted()
                    }
                }
            }


            //DispatchQueue.global(qos: .background).async(execute: workItem!)

            /*DispatchQueue.global(qos: .background).async(execute: { [weak self] in
                //try? rawData.write(to: URL(fileURLWithPath: walletFilePath), options: [.atomic])
                //print("Wallet info saved")
                if let theSelf = self {
                    theSelf.syncService.startSync(from:currWH)
                    DispatchQueue.main.async { [weak self] in
                        self?.timerSync?.invalidate()
                        self?.onSyncStop()
                    }
                }
            })*/

            /*self.timerSync = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                    selector: #selector(syncStep), userInfo: nil, repeats: true)*/
        } else {
            if attemptsCount > 3 {
                timer?.invalidate()
                notifier?.connectionError()
            }
            print("Not connect yet... waiting")
            attemptsCount += 1
        }
    }

    func onSyncCompleted() {
        progress.setupCurrentBlock(currentSyncBlock())
        notifier?.syncCompleted()
    }

    func stopSync(_ close: Bool = false) {
        timer?.invalidate()
        syncService?.stopSync()
        if close {
            syncService?.clear()
        }

        syncService = nil
        _inSync = false

        NSLog("== stopSync ==")
    }

    var isSync: Bool {
        return _inSync
    }

    func isNeedToUpdateProgress() -> (Bool, UInt64) {
        let currentBlock = currentSyncBlock()
        if hasUnconfirmed() {
            return (true, currentBlock)
        }

        if currentBlock > 0 {
            if savedBlockHeight != currentBlock {
                savedBlockHeight = currentBlock

                return (true, currentBlock)
            }
        }

        return (false, 0)
    }

    func updateProgress(_ block: UInt64) {
        print("\(Date().formattedWith("HH:mm:ss")): Current block height is \(block)")
        progress.currentBlock = block
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name.CurrentBlockHeightChanged), object: block)
    }

    func currentSyncBlock() -> UInt64 {
        guard let theService = syncService else {
            print("syncService not exist")
            return 0
        }

        return theService.currentSyncBlock()
    }

    func hasUnconfirmed() -> Bool {
        guard let theService = syncService else {
            print("syncService not exist")
            return false
        }

        return theService.hasUnconfirmed()
    }
}
