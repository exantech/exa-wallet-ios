//
// Created by Igor Efremov on 04/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

class EXAWalletMetaInfoStorageService {
    private let metaInfoJSON = "metainfo.json"
    private var _walletsList: [WalletMetaInfo]?
    private var _loaded: Bool = false

    var walletsList: [WalletMetaInfo]? {
        return _walletsList
    }

    init() {
        if !isMetaExists() {
            print("Meta info file not yet created")
            print("Creating empty meta info... ")
            if createMetaInfo() {
                print("Empty meta info created")
            } else {
                // TODO: implement init?()
                // fatalError("Can't create Meta info")
            }
        }
    }

    func addNew(_ info: WalletMetaInfo) {
        if _walletsList == nil {
            _walletsList = [WalletMetaInfo]()
        }

        info.addedTimestamp = Date().timeIntervalSince1970
        _walletsList?.append(info)
    }

    func removeMeta(by uuid: String) {
        guard let theWalletList = _walletsList else { return }
        guard let index = theWalletList.index(where: {$0.uuid == uuid}) else { return }

        let removeItemIndex = theWalletList.startIndex.distance(to: index)
        _walletsList?.remove(at: removeItemIndex)

        self.save(true)
    }

    func changeMeta(by uuid: String, name: String, color: WalletColor) -> WalletMetaInfo? {
        guard let theWalletList = _walletsList else { return nil }
        guard let index = theWalletList.index(where: {$0.uuid == uuid}) else { return nil }

        let changeItemIndex = theWalletList.startIndex.distance(to: index)
        (_walletsList?[changeItemIndex])?.name = name
        (_walletsList?[changeItemIndex])?.color = color

        self.save(true)

        return _walletsList?[changeItemIndex]
    }

    func changeMeta(by uuid: String, newMeta: WalletMetaInfo) -> WalletMetaInfo? {
        guard let theWalletList = _walletsList else { return nil }
        guard let index = theWalletList.index(where: {$0.uuid == uuid}) else { return nil }

        let changeItemIndex = theWalletList.startIndex.distance(to: index)
        _walletsList?[changeItemIndex] = newMeta

        self.save(true)

        return _walletsList?[changeItemIndex]
    }

    func isMetaExists() -> Bool {
        if let theDocumentsDirectory = EXACommon.documentsDirectory {
            let metaInfoFilePath = theDocumentsDirectory.appendPathComponent(metaInfoJSON)
            return FileManager.default.fileExists(atPath: metaInfoFilePath)
        }

        return false
    }

    private func createMetaInfo() -> Bool {
        if let theDocumentsDirectory = EXACommon.documentsDirectory {
            let metaInfoFilePath = theDocumentsDirectory.appendPathComponent(metaInfoJSON)
            return FileManager.default.createFile(atPath: metaInfoFilePath, contents: nil)
        }

        return false
    }

    // TODO: Bool result & Int count of loaded wallets
    func load() -> Bool {
        var result: Bool = false
        var metas = [WalletMetaInfo]()

        if let theDocumentsDirectory = EXACommon.documentsDirectory {
            let metaInfoFilePath = theDocumentsDirectory.appendPathComponent(metaInfoJSON)
            if FileManager.default.fileExists(atPath: metaInfoFilePath) {
                if let data: Data = try? Data(contentsOf: URL(fileURLWithPath: metaInfoFilePath)) {
                    if data.count == 0 {
                        print("Meta is empty")
                        _loaded = true
                        return true
                    }

                    if let json = try? JSON(data: data) {
                        print("Meta found in \(metaInfoFilePath)")

                        if let arr = json.array {
                            for item in arr {
                                let name = item["name"].stringValue
                                let uuid = item["uuid"].stringValue

                                // TODO Working with wallet type
                                let rawValue = item["type"].int ?? 0
                                let rawColor = item["color"].int ?? 0
                                let walletType = WalletType(rawValue: rawValue) ?? WalletType.shared
                                let walletColor = WalletColor(rawValue: rawColor) ?? WalletColor.orange

                                var signatures: Int = 0
                                var participants: Int = 0
                                var creator: Bool = false
                                var sharedReady: Bool = false

                                if rawValue == 1 { // .shared
                                    let scheme = item["scheme"]
                                    signatures = scheme["signatures"].int ?? 0
                                    participants = scheme["participants"].int ?? 0
                                    creator = item["creator"].bool ?? false
                                    sharedReady = item["sharedReady"].bool ?? false
                                }

                                let skippedPass = item["skippedPass"].bool ?? false
                                let hideBalance = item["hideBalance"].bool ?? false
                                let requiredPasswordWhenOpening = item["requiredPasswordWhenOpening"].bool ?? false

                                guard let metaInfo = WalletMetaInfo(name, uuid: uuid, type: walletType, color: walletColor,
                                        signatures: UInt(signatures), participants: UInt(participants)) else {

                                    print("Error during loading meta... Skip")
                                    return false
                                }

                                metaInfo.blockHeight = item["blockHeight"].uInt64 ?? 0
                                metaInfo.hideBalance = hideBalance
                                metaInfo.skippedPass = skippedPass
                                metaInfo.requiredPasswordWhenOpening = requiredPasswordWhenOpening
                                metaInfo.addedTimestamp = item["addedTimestamp"].double ?? 0
                                metaInfo.creator = creator
                                metaInfo.sharedReady = sharedReady
                                metas.append(metaInfo)
                            }
                        }

                        _walletsList = metas
                        _loaded = true
                        result = true
                    } else {
                        print(metaInfoJSON + " not found")
                        return result
                    }
                }
            } else {
                print("Meta info file not yet created")
                return false
            }
        }

        return result
    }

    func save(_ sync: Bool = false) {
        guard let theWalletsList = _walletsList else { return }
        let jsons = theWalletsList.compactMap{$0.json()}
        let json: JSON = JSON(jsons)

        if let theDocumentsDirectory = EXACommon.documentsDirectory {
            let metaInfoFilePath = theDocumentsDirectory.appendPathComponent(metaInfoJSON)
            if let rawData = try? json.rawData() {
                if sync {
                    try? rawData.write(to: URL(fileURLWithPath: metaInfoFilePath), options: [.atomic])
                    print("Wallet meta info saved sync")
                } else {
                    DispatchQueue.global(qos: .background).async(execute: { () -> Void in
                        try? rawData.write(to: URL(fileURLWithPath: metaInfoFilePath), options: [.atomic])
                        print("Wallet meta info saved async")
                    })
                }
            }
        }
    }

    func isAlreadyExist(_ walletName: String) -> Bool {
        guard _loaded == true else {
            print("Meta not loaded. Cant't check wallet exist")
            return true
        }

        guard let theWalletsList = _walletsList else {
            print("Empty wallet list")
            return false
        }

        return theWalletsList.map{$0.name}.contains(walletName)
    }
}
