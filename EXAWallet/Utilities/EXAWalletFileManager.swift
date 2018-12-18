//
// Created by Igor Efremov on 17/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class EXAWalletFileManager {
    static let shared = EXAWalletFileManager()

    private let tempPrefix = "temp_"
    private let walletExtension = "wal"
    private let walletKeysExtension = "wal.keys"
    private let walletAddressExtension = "wal.address.txt"

    func walletPath(to walletFileName: String) -> String? {
        guard let theDocumentDirectory = EXACommon.documentsDirectory else { return nil }
        guard let path = theDocumentDirectory.appendPathComponent(walletFileName).appendPathExtension(walletExtension) else { return nil }
        print("Wallet Path: \(path)")

        return path
    }

    func tempWalletPath(to walletFileName: String) -> String? {
        guard let theDocumentDirectory = EXACommon.documentsDirectory else { return nil }
        guard let path = theDocumentDirectory.appendPathComponent(tempPrefix + walletFileName).appendPathExtension(walletExtension) else { return nil }
        print("Temp wallet Path: \(path)")

        return path
    }

    func walletKeysPath(to walletFileName: String) -> String? {
        guard let theDocumentDirectory = EXACommon.documentsDirectory else { return nil }
        guard let path = theDocumentDirectory.appendPathComponent(walletFileName).appendPathExtension(walletKeysExtension) else { return nil }
        print("Wallet Keys Path: \(path)")

        return path
    }

    func tempWalletKeysPath(to walletFileName: String) -> String? {
        guard let theDocumentDirectory = EXACommon.documentsDirectory else { return nil }
        guard let path = theDocumentDirectory.appendPathComponent(tempPrefix + walletFileName).appendPathExtension(walletKeysExtension) else { return nil }
        print("Temp Wallet Keys Path: \(path)")

        return path
    }

    func walletAddressTxtPath(to walletFileName: String) -> String? {
        guard let theDocumentDirectory = EXACommon.documentsDirectory else { return nil }
        guard let path = theDocumentDirectory.appendPathComponent(walletFileName).appendPathExtension(walletAddressExtension) else { return nil }
        print("Wallet Address Path: \(path)")

        return path
    }

    func isWalletFileExist(_ walletFileName: String) -> Bool {
        guard let path = walletPath(to: walletFileName) else { return false }
        return FileManager.default.fileExists(atPath: path)
    }

    func isWalletKeysFileExist(_ walletFileName: String) -> Bool {
        guard let path = walletKeysPath(to: walletFileName) else { return false }
        return FileManager.default.fileExists(atPath: path)
    }

    func isWalletAddressTxtFileExist(_ walletFileName: String) -> Bool {
        guard let path = walletAddressTxtPath(to: walletFileName) else { return false }
        return FileManager.default.fileExists(atPath: path)
    }

    func copyWalletFile(_ walletFileName: String) -> Bool {
        guard let walletPath = walletPath(to: walletFileName) else { return false }
        guard let walletKeysPath = walletKeysPath(to: walletFileName) else { return false }
        guard let tempWalletPath = tempWalletPath(to: walletFileName) else { return false }
        guard let tempWalletKeysPath = tempWalletKeysPath(to: walletFileName) else { return false }

        var result: Bool = false

        if isWalletFileExist(walletFileName) {
            do {
                try FileManager.default.copyItem(atPath: walletPath, toPath: tempWalletPath)
                print("Personal Wallet file copied")
                result = true
            }
            catch {
                return false
            }
        }

        if isWalletKeysFileExist(walletFileName) {
            do {
                try FileManager.default.copyItem(atPath: walletKeysPath, toPath: tempWalletKeysPath)
                print("Personal Wallet keys file copied")
                result = result && true
            }
            catch {
                return false
            }
        }

        return result
    }

    func removeWalletFile(_ walletFileName: String) -> Bool {
        guard let walletPath = walletPath(to: walletFileName) else { return false }
        guard let walletKeysPath = walletKeysPath(to: walletFileName) else { return false }
        guard let walletAddressPath = walletAddressTxtPath(to: walletFileName) else { return false }

        var result: Bool = false

        if isWalletFileExist(walletFileName) {
            do {
                try FileManager.default.removeItem(atPath: walletPath)
                print("Wallet file removed")
                result = true
            }
            catch {
                return false
            }
        }

        if isWalletKeysFileExist(walletFileName) {
            do {
                try FileManager.default.removeItem(atPath: walletKeysPath)
                print("Wallet keys file removed")
                result = result && true
            }
            catch {
                return false
            }
        }

        if isWalletAddressTxtFileExist(walletFileName) {
            do {
                try FileManager.default.removeItem(atPath: walletAddressPath)
                print("Wallet address txt file removed")
                result = result && true
            }
            catch {
                return false
            }
        }

        return result
    }
}

