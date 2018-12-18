//
//  EXAGraphicsResources.swift
//  EXAWallet
//
//  Created by Igor Efremov on 02/02/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit

class EXAGraphicsResources {
    static var copy: UIImage {
        return UIImage(named: "copy.png")!
    }

    static var share: UIImage {
        return #imageLiteral(resourceName: "share")
    }

    static var homeTab: UIImage {
        return #imageLiteral(resourceName: "home_tab")
    }

    static var receiveTab: UIImage {
        return #imageLiteral(resourceName: "receive_tab")
    }

    static var sendTab: UIImage {
        return #imageLiteral(resourceName: "send_tab")
    }

    static var walletSettingsTab: UIImage {
        return #imageLiteral(resourceName: "wallet_settings_tab")
    }

    static var settings: UIImage {
        return #imageLiteral(resourceName: "settings")
    }

    static var validationSuccess: UIImage {
        return #imageLiteral(resourceName: "validation_success")
    }

    static var editMeta: UIImage {
        return #imageLiteral(resourceName: "edit_meta")
    }
    
    static var changePassword: UIImage {
        return #imageLiteral(resourceName: "change_password")
    }

    static var delete: UIImage {
        return #imageLiteral(resourceName: "delete")
    }

    static var remember: UIImage {
        return #imageLiteral(resourceName: "remember")
    }
    
    static var error: UIImage {
        return #imageLiteral(resourceName: "error_sign")
    }
    
    static var logoWithText: UIImage {
        return #imageLiteral(resourceName: "logo_text")
    }

    static var logoPin: UIImage {
        return #imageLiteral(resourceName: "logo_pin")
    }

    static var close: UIImage {
        return #imageLiteral(resourceName: "close")
    }

    static var about: UIImage {
        return #imageLiteral(resourceName: "about")
    }

    static var changePin: UIImage {
        return #imageLiteral(resourceName: "change_pin")
    }

    static var loaderImage: UIImage? {
        return UIImage(named: "logo_loader.png")
    }

    static var logoImage: UIImage? {
        return UIImage(named: "splash_logo.png")
    }

    static var telegram: UIImage {
        return #imageLiteral(resourceName: "telegram")
    }

    static var logoExantech: UIImage {
        return #imageLiteral(resourceName: "logo_exantech")
    }

    static func transactionType(_ type: TransactionType) -> UIImage {
        switch type {
        case .sent:
            return UIImage(named: "sent.png")!
        case .received:
            return UIImage(named: "received.png")!
        }
    }

    static var proposalInProcess: UIImage {
        return #imageLiteral(resourceName: "proposal_process")
    }
    
    static var proposalRejected: UIImage {
        return #imageLiteral(resourceName: "proposal_rejected")
    }

    static var addImage: UIImage {
        return #imageLiteral(resourceName: "add")
    }

    static var personalWalletImage: UIImage {
        return UIImage(named: "personal_wallet.png")!
    }

    static var commonWalletImage: UIImage {
        return UIImage(named: "common_wallet.png")!
    }

    static func walletBigSignImage(_ walletType: WalletType) -> UIImage {
        if walletType == .personal {
            return #imageLiteral(resourceName: "personal_big_sign")
        } else {
            return #imageLiteral(resourceName: "shared_big_sign")
        }
    }

    static func walletCreationOptionImage(_ creationType: EXAMoneroWalletCreateOption, inverted: Bool = false) -> UIImage {
        let imageName = creationType.imageName + ".png"
        let invertedImageName = creationType.imageName + "_inverted.png"
        let result = UIImage(named: imageName)!

        if inverted {
            return UIImage(named: invertedImageName) ?? result.tintImage(UIColor.black)
        } else {
            return result
        }
    }
}
