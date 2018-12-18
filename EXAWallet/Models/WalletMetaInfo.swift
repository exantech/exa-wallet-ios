//
// Created by Igor Efremov on 04/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SwiftyJSON

enum WalletColor: Int, Codable {
    case orange = 0, almostOrange, blue, magenta, green, pink
    static let all = [orange, almostOrange, blue, magenta, green, pink]

    var value: UIColor {
        switch self {
            case .orange: return UIColor.mainColor
            case .almostOrange: return UIColor.almostOrange
            case .blue: return UIColor.exaBlue
            case .magenta: return UIColor.exaMagenta
            case .green: return UIColor.exaGreen
            case .pink: return UIColor.exaPink
        }
    }
}

class WalletMetaInfo: Codable, Jsonable {
    var name: String
    var uuid: String
    var type: WalletType
    var color: WalletColor
    var blockHeight: UInt64? = nil

    var hideBalance: Bool = false
    var requiredPasswordWhenOpening: Bool = false

    // only for shared wallets
    var signatures: UInt = 0
    var participants: UInt = 0
    var creator: Bool = false
    var sharedReady: Bool = false
    var addedTimestamp: TimeInterval = 0
    var skippedPass: Bool = false

    init(_ name: String) {
        self.name = name
        self.uuid = WalletHelper.generateWalletUUID()
        self.type = .personal
        self.color = WalletColor.orange
        self.blockHeight = nil
    }

    init(_ name: String, color: WalletColor, blockHeight: UInt64? = nil) {
        self.name = name
        self.uuid = WalletHelper.generateWalletUUID()
        self.type = .personal
        self.color = color
        self.blockHeight = blockHeight
    }

    init?(_ name: String, uuid: String? = nil, type: WalletType, color: WalletColor = .orange, blockHeight: UInt64? = nil,
         signatures: UInt = 0, participants: UInt = 0) {
        guard signatures <= participants else { return nil }

        self.name = name
        self.uuid = uuid ?? WalletHelper.generateWalletUUID()
        self.type = type
        self.color = color
        self.blockHeight = blockHeight
        self.signatures = signatures
        self.participants = participants
    }

    init?(_ name: String, uuid: String? = nil, type: WalletType, color: WalletColor = .orange, blockHeight: UInt64? = nil,
          scheme: SharedWalletScheme? = nil) {
        guard signatures <= participants else { return nil }

        self.name = name
        self.uuid = uuid ?? WalletHelper.generateWalletUUID()
        self.type = type
        self.color = color
        self.blockHeight = blockHeight
        if let theScheme = scheme {
            self.signatures = theScheme.signers
            self.participants = theScheme.participants
        }
    }

    func scheme() -> SharedWalletScheme {
        return SharedWalletScheme(signatures, participants)
    }

    func json() -> JSON? {
        let params: JSON

        if type == .shared {
            guard signatures > 0 && participants > 0 && signatures <= participants else {
                print("Incorrect multisignature wallet meta")
                return nil
            }
            let scheme: JSON = ["signatures": signatures, "participants": participants]
            params = ["name": name, "uuid": uuid, "type": type.rawValue, "color": color.rawValue, "blockHeight": blockHeight ?? 0, "hideBalance": hideBalance, "requiredPasswordWhenOpening": requiredPasswordWhenOpening,
                      "scheme": scheme, "creator": creator, "sharedReady": sharedReady, "addedTimestamp": addedTimestamp, "skippedPass": skippedPass]
        } else {
            params = ["name": name, "uuid": uuid, "type": type.rawValue, "color": color.rawValue, "blockHeight": blockHeight ?? 0, "hideBalance": hideBalance, "requiredPasswordWhenOpening": requiredPasswordWhenOpening, "addedTimestamp": addedTimestamp, "skippedPass": skippedPass]
        }

        return params
    }
}
