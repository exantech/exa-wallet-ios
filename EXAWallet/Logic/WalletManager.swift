//
// Created by Igor Efremov on 15/06/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class WalletManager {
    private let storageService: EXAWalletMetaInfoStorageService = EXAWalletMetaInfoStorageService()
    private var walletsList: [String] = [String]()

    static let shared = WalletManager()

    init() {


    }

    deinit {
        print("deinit WalletManager")
    }

    class func getWallet()-> MoneroWallet {
        return MoneroWallet()
    }

    class func delete() -> Bool {
        return MoneroWallet.deleteAll()
    }

    /*func addWallet(_ walletName: String) {

    }*/

    func loadWallets() {
        guard storageService.load() == true else {
            NSLog("ERROR: Bad Meta, skip loading")
            return
        }
        AppState.sharedInstance.walletsMetaInfo = storageService.walletsList
        print("== Meta Info loaded ==")
    }

    func createWallet(_ info: WalletCreationInfo) -> (Bool, String, MoneroWallet?) {
        let wallet = WalletManager.getWallet()
        let result = wallet.create(info.meta.uuid, password: info.password)
        if result.0 {
            storageService.addNew(info.meta)
            storageService.save()
        }

        return (result.0, result.1, result.0 == true ? wallet : nil)
    }

    func restore(_ info: WalletCreationInfo) -> (Bool, String, MoneroWallet?) {
        print("== Restore Wallet...")

        let wallet = WalletManager.getWallet()
        let result = wallet.restore(info.meta.uuid, mnemonic: info.mnemonic ?? "", password: info.password, blockHeight: info.meta.blockHeight)
        if result.0 {
            if info.meta.type == .personal {
                storageService.addNew(info.meta)
                storageService.save()
            }
        }

        return (result.0, result.1, result.0 == true ? wallet : nil)
    }


}
