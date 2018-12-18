//
//  EXAAppInfoService.swift
//  EXAWallet
//
//  Created by Igor Efremov on 22/02/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

class EXAAppInfoService {
    static var appTitle: String {
        return l10n(.commonAppTitle)
    }

    static var appVersion: String {
        var version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            version += ".\(build)"
        }
        return version
    }

#if LIVE
    static let txInfoServiceBaseUrl = "https://monero.exan.tech/tx/"
#else
    static let txInfoServiceBaseUrl = "https://monero-stagenet.exan.tech/tx/"
#endif

    static let telegramChannel: String = "Exa Wallet community"
    static let telegramChannelLink: String = "https://t.me/exawallet"
    static let exantechLink: String = "https://exan.tech/"
}
